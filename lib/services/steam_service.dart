// lib/services/steam_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/game_data.dart';
import 'local_process_service.dart';

class SteamService {
  // Clave de Steam Web API y SteamID64 del usuario (configurables en la UI)
  static String apiKey = '';
  static String steamId = '';

  /// Resuelve la URL adecuada considerando el bloqueo de CORS en navegadores Web
  static Uri _buildUri(String rawUrl) {
    if (kIsWeb) {
      // En Web, usamos proxy público para evitar que Chrome bloquee por CORS
      return Uri.parse('https://api.allorigins.win/raw?url=${Uri.encodeComponent(rawUrl)}');
    }
    return Uri.parse(rawUrl);
  }

  /// Consulta el estado actual del jugador para detectar si está jugando en vivo
  static Future<Juego?> checkCurrentlyPlaying({String? customSteamId, String? customApiKey}) async {
    final sId = (customSteamId ?? steamId).trim();
    final key = (customApiKey ?? apiKey).trim();

    if (sId.isEmpty || key.isEmpty) return null;

    try {
      final rawUrl = 'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=$key&steamids=$sId';
      final response = await http.get(_buildUri(rawUrl)).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final players = data['response']?['players'] as List?;
        if (players != null && players.isNotEmpty) {
          final player = players[0];
          final gameName = player['gameextrainfo'] as String?;
          final gameId = player['gameid']?.toString();

          if (gameName != null && gameName.isNotEmpty) {
            final coverUrl = gameId != null
                ? 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/$gameId/header.jpg'
                : null;

            return Juego(
              nombre: gameName,
              genero: 'Steam Live',
              tienda: 'Steam',
              jugadores: '1 jugador',
              estado: 'Jugando',
              imageUrl: coverUrl,
              id: gameId != null ? int.tryParse(gameId) : null,
              isLivePlaying: true,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error en SteamService.checkCurrentlyPlaying: $e');
    }
    return null;
  }

  /// Importa la biblioteca de juegos que posee el usuario en su cuenta de Steam
  /// Si está en PC, también lee automáticamente los juegos instalados localmente.
  static Future<List<Juego>> getOwnedGames({String? customSteamId, String? customApiKey}) async {
    final sId = (customSteamId ?? steamId).trim();
    final key = (customApiKey ?? apiKey).trim();

    final List<Juego> imported = [];

    // 1. Importar los juegos instalados en la PC (funciona en Windows nativo y en Web vía monitor)
    try {
      final localSteam = await LocalProcessService.getInstalledSteamGamesAsync();
      if (localSteam.isNotEmpty) {
        imported.addAll(localSteam);
      }
    } catch (_) {}

    // 2. Si se ingresó una API Key y un SteamID, consultar la API Web de Valve
    if (sId.isNotEmpty && key.isNotEmpty) {
      try {
        final rawUrl = 'https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=$key&steamid=$sId&include_appinfo=1&format=json';
        final response = await http.get(_buildUri(rawUrl)).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final games = data['response']?['games'] as List? ?? [];

          for (final g in games) {
            final appId = g['appid']?.toString() ?? '';
            final name = g['name'] as String? ?? 'Juego de Steam';
            final playtime = g['playtime_forever'] as int? ?? 0;
            final coverUrl = appId.isNotEmpty
                ? 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/$appId/header.jpg'
                : null;

            // Evitar duplicados con los ya leídos localmente
            if (!imported.any((j) => j.nombre.toLowerCase() == name.toLowerCase())) {
              imported.add(Juego(
                nombre: name,
                genero: 'Steam Collection',
                tienda: 'Steam',
                jugadores: '1 jugador',
                estado: playtime > 60 ? 'Jugando' : 'Pendiente',
                imageUrl: coverUrl,
                id: int.tryParse(appId),
                playtimeMinutes: playtime,
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('Error en SteamService.getOwnedGames (Web API): $e');
      }
    }

    return imported;
  }
}
