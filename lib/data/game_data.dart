// lib/data/game_data.dart
import 'package:flutter/foundation.dart';

@immutable
class Juego {
  final String nombre;
  final String genero;
  final String tienda;
  final String jugadores;
  final String estado;
  final String? imageUrl;
  final int? id;
  final int? metacritic;
  final bool isLivePlaying;
  final int? playtimeMinutes;

  const Juego({
    required this.nombre,
    required this.genero,
    required this.tienda,
    required this.jugadores,
    required this.estado,
    this.imageUrl,
    this.id,
    this.metacritic,
    this.isLivePlaying = false,
    this.playtimeMinutes,
  });

  Juego copyWith({
    String? nombre,
    String? genero,
    String? tienda,
    String? jugadores,
    String? estado,
    String? imageUrl,
    int? id,
    int? metacritic,
    bool? isLivePlaying,
    int? playtimeMinutes,
  }) {
    return Juego(
      nombre: nombre ?? this.nombre,
      genero: genero ?? this.genero,
      tienda: tienda ?? this.tienda,
      jugadores: jugadores ?? this.jugadores,
      estado: estado ?? this.estado,
      imageUrl: imageUrl ?? this.imageUrl,
      id: id ?? this.id,
      metacritic: metacritic ?? this.metacritic,
      isLivePlaying: isLivePlaying ?? this.isLivePlaying,
      playtimeMinutes: playtimeMinutes ?? this.playtimeMinutes,
    );
  }

  factory Juego.fromJson(Map<String, dynamic> json) {
    return Juego(
      nombre: json['nombre'] as String? ?? 'Sin nombre',
      genero: json['genero'] as String? ?? 'Varios',
      tienda: json['tienda'] as String? ?? 'PC',
      jugadores: json['jugadores'] as String? ?? '1 jugador',
      estado: json['estado'] as String? ?? 'Pendiente',
      imageUrl: json['imageUrl'] as String?,
      id: json['id'] as int?,
      metacritic: json['metacritic'] as int?,
      isLivePlaying: json['isLivePlaying'] as bool? ?? false,
      playtimeMinutes: json['playtimeMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'genero': genero,
    'tienda': tienda,
    'jugadores': jugadores,
    'estado': estado,
    'imageUrl': imageUrl,
    'id': id,
    'metacritic': metacritic,
    'isLivePlaying': isLivePlaying,
    'playtimeMinutes': playtimeMinutes,
  };
}

const List<Juego> juegosIniciales = [
  Juego(
    nombre: "Cyberpunk 2077",
    genero: "RPG · Acción",
    tienda: "Steam",
    jugadores: "1 jugador",
    estado: "Jugando",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg",
    id: 1091500,
    metacritic: 86,
  ),
  Juego(
    nombre: "Hollow Knight",
    genero: "Metroidvania · 2D",
    tienda: "Epic",
    jugadores: "1 jugador",
    estado: "Completado",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/367520/header.jpg",
    id: 367520,
    metacritic: 90,
  ),
  Juego(
    nombre: "Elden Ring",
    genero: "RPG · Acción",
    tienda: "PS",
    jugadores: "1 jugador",
    estado: "Pendiente",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1245620/header.jpg",
    id: 1245620,
    metacritic: 96,
  ),
  Juego(
    nombre: "It Takes Two",
    genero: "Aventura · Coop",
    tienda: "Steam",
    jugadores: "Coop",
    estado: "Jugando",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1426210/header.jpg",
    id: 1426210,
    metacritic: 89,
  ),
  Juego(
    nombre: "Forza Horizon 5",
    genero: "Carreras",
    tienda: "Xbox",
    jugadores: "Multijugador",
    estado: "Jugando",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1551360/header.jpg",
    id: 1551360,
    metacritic: 92,
  ),
  Juego(
    nombre: "Stardew Valley",
    genero: "Casual · Indie",
    tienda: "Steam",
    jugadores: "Multi local",
    estado: "Completado",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/413150/header.jpg",
    id: 413150,
    metacritic: 89,
  ),
  Juego(
    nombre: "God of War",
    genero: "Acción · Aventura",
    tienda: "PS",
    jugadores: "1 jugador",
    estado: "Pendiente",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1593500/header.jpg",
    id: 1593500,
    metacritic: 94,
  ),
  Juego(
    nombre: "Hades",
    genero: "Acción · Indie",
    tienda: "Epic",
    jugadores: "1 jugador",
    estado: "Jugando",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1145360/header.jpg",
    id: 1145360,
    metacritic: 93,
  ),
  Juego(
    nombre: "Sea of Thieves",
    genero: "Aventura",
    tienda: "Xbox",
    jugadores: "Multijugador",
    estado: "Pendiente",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1172620/header.jpg",
    id: 1172620,
    metacritic: 82,
  ),
  Juego(
    nombre: "Celeste",
    genero: "Plataformas · Indie",
    tienda: "Steam",
    jugadores: "1 jugador",
    estado: "Completado",
    imageUrl: "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/504230/header.jpg",
    id: 504230,
    metacritic: 92,
  ),
];

// Alias para compatibilidad con código anterior
const List<Juego> juegos = juegosIniciales;

const tiendas   = ["Steam", "Epic", "Xbox", "Ubisoft", "PS", "Nintendo"];
const jugadores = ["1 jugador", "Multijugador", "Coop", "Multi local"];
const generos   = ["Acción", "Aventura", "Casual", "Indie", "Carreras",
                   "Rol", "Simulación", "Multi masivo", "Estrategia", "Deportes"];
const estados   = ["Todos", "Jugando", "Pendiente", "Completado"];
