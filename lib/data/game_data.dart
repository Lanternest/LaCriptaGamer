// lib/data/game_data.dart

class Juego {
  final String nombre;
  final String genero;
  final String tienda;
  final String jugadores;
  final String estado;

  const Juego({
    required this.nombre,
    required this.genero,
    required this.tienda,
    required this.jugadores,
    required this.estado,
  });
}

const List<Juego> juegos = [
  Juego(nombre: "Cyberpunk 2077",  genero: "RPG · Acción",        tienda: "Steam", jugadores: "1 jugador",    estado: "Jugando"),
  Juego(nombre: "Hollow Knight",   genero: "Metroidvania · 2D",   tienda: "Epic",  jugadores: "1 jugador",    estado: "Completado"),
  Juego(nombre: "Elden Ring",      genero: "RPG · Acción",        tienda: "PS",    jugadores: "1 jugador",    estado: "Pendiente"),
  Juego(nombre: "It Takes Two",    genero: "Aventura · Coop",     tienda: "Steam", jugadores: "Coop",         estado: "Jugando"),
  Juego(nombre: "Forza Horizon 5", genero: "Carreras",            tienda: "Xbox",  jugadores: "Multijugador", estado: "Jugando"),
  Juego(nombre: "Stardew Valley",  genero: "Casual · Indie",      tienda: "Steam", jugadores: "Multi local",  estado: "Completado"),
  Juego(nombre: "God of War",      genero: "Acción · Aventura",   tienda: "PS",    jugadores: "1 jugador",    estado: "Pendiente"),
  Juego(nombre: "Hades",           genero: "Acción · Indie",      tienda: "Epic",  jugadores: "1 jugador",    estado: "Jugando"),
  Juego(nombre: "Sea of Thieves",  genero: "Aventura",            tienda: "Xbox",  jugadores: "Multijugador", estado: "Pendiente"),
  Juego(nombre: "Celeste",         genero: "Plataformas · Indie", tienda: "Steam", jugadores: "1 jugador",    estado: "Completado"),
];

const tiendas   = ["Steam", "Epic", "Xbox", "Ubisoft", "PS", "Nintendo"];
const jugadores = ["1 jugador", "Multijugador", "Coop", "Multi local"];
const generos   = ["Acción", "Aventura", "Casual", "Indie", "Carreras",
                   "Rol", "Simulación", "Multi masivo", "Estrategia", "Deportes"];
const estados   = ["Todos", "Jugando", "Pendiente", "Completado"];