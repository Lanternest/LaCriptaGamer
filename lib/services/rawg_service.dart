// lib/services/rawg_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/game_data.dart';

class RawgService {
  // Clave de demostración / pública para catálogo abierto de RAWG
  // El usuario puede configurar su propia clave en los ajustes de la app.
  static String apiKey = 'c542e67aec3a4340908f9de9e86038af';
  static const String _baseUrl = 'https://api.rawg.io/api';

  /// Busca videojuegos en el catálogo mundial de RAWG por término de búsqueda
  static Future<List<Juego>> searchGames(String query, {int pageSize = 12}) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_baseUrl/games?key=$apiKey&search=${Uri.encodeComponent(query)}&page_size=$pageSize',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => _mapRawgToJuego(item)).toList();
      }
    } catch (e) {
      // Retorna lista vacía en caso de timeout o falta de conexión
      debugPrint('Error en RawgService.searchGames: $e');
    }
    return [];
  }

  /// Obtiene los juegos más populares / destacados del momento
  static Future<List<Juego>> getPopularGames({int pageSize = 12}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/games?key=$apiKey&ordering=-rating&page_size=$pageSize',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => _mapRawgToJuego(item)).toList();
      }
    } catch (e) {
      debugPrint('Error en RawgService.getPopularGames: $e');
    }
    return [];
  }

  /// Convierte el formato JSON de RAWG a nuestra entidad 'Juego'
  static Juego _mapRawgToJuego(Map<String, dynamic> item) {
    // Géneros
    String genero = 'Acción';
    final genresList = item['genres'] as List?;
    if (genresList != null && genresList.isNotEmpty) {
      final names = genresList.take(2).map((g) => g['name'] as String).toList();
      genero = names.join(' · ');
    }

    // Tienda / Plataforma predominante
    String tienda = 'Steam';
    final platformsList = item['platforms'] as List?;
    if (platformsList != null && platformsList.isNotEmpty) {
      final platNames = platformsList
          .map((p) => (p['platform']?['name'] as String? ?? '').toLowerCase())
          .toList();

      if (platNames.any((p) => p.contains('playstation') || p.contains('ps'))) {
        tienda = 'PS';
      } else if (platNames.any((p) => p.contains('xbox'))) {
        tienda = 'Xbox';
      } else if (platNames.any((p) => p.contains('nintendo') || p.contains('switch'))) {
        tienda = 'Nintendo';
      } else if (platNames.any((p) => p.contains('pc') || p.contains('steam'))) {
        tienda = 'Steam';
      }
    }

    // Modalidad de jugadores (Tags)
    String modalidad = '1 jugador';
    final tags = item['tags'] as List?;
    if (tags != null) {
      final tagNames = tags
          .map((t) => (t['name'] as String? ?? '').toLowerCase())
          .toList();
      if (tagNames.any((t) => t.contains('co-op') || t.contains('coop'))) {
        modalidad = 'Coop';
      } else if (tagNames.any((t) => t.contains('multiplayer') || t.contains('multijugador'))) {
        modalidad = 'Multijugador';
      }
    }

    return Juego(
      nombre: item['name'] as String? ?? 'Desconocido',
      genero: genero,
      tienda: tienda,
      jugadores: modalidad,
      estado: 'Pendiente',
      imageUrl: item['background_image'] as String?,
      id: item['id'] as int?,
      metacritic: item['metacritic'] as int?,
    );
  }
}
