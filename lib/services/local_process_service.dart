// lib/services/local_process_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/game_data.dart';

class LocalProcessService {
  /// Base de datos de ejecutables de juegos (Originales y Repacks / Pirata)
  static final Map<String, Map<String, String>> _knownGames = {
    // Valve / Steam populares
    'left4dead2': {'nombre': 'Left 4 Dead 2', 'tienda': 'Steam', 'genero': 'Shooter · Coop', 'appid': '550'},
    'cs2': {'nombre': 'Counter-Strike 2', 'tienda': 'Steam', 'genero': 'Shooter Táctico', 'appid': '730'},
    'dota2': {'nombre': 'Dota 2', 'tienda': 'Steam', 'genero': 'MOBA', 'appid': '570'},
    'portal2': {'nombre': 'Portal 2', 'tienda': 'Steam', 'genero': 'Puzzles · Coop', 'appid': '620'},
    'hl2': {'nombre': 'Half-Life 2', 'tienda': 'Steam', 'genero': 'Acción · Aventura', 'appid': '220'},

    // Juegos instalados del usuario
    'cultofthelamb': {'nombre': 'Cult of the Lamb', 'tienda': 'Steam', 'genero': 'Roguelike · Acción', 'appid': '1313140'},
    'stardew valley': {'nombre': 'Stardew Valley', 'tienda': 'Steam', 'genero': 'Casual · Indie', 'appid': '413150'},
    'stardewvalley': {'nombre': 'Stardew Valley', 'tienda': 'Steam', 'genero': 'Casual · Indie', 'appid': '413150'},
    'graveyard keeper': {'nombre': 'Graveyard Keeper', 'tienda': 'Steam', 'genero': 'Simulación · Rol', 'appid': '599140'},
    'graveyardkeeper': {'nombre': 'Graveyard Keeper', 'tienda': 'Steam', 'genero': 'Simulación · Rol', 'appid': '599140'},
    'valheim': {'nombre': 'Valheim', 'tienda': 'Steam', 'genero': 'Supervivencia · Coop', 'appid': '892970'},
    'ac3rm': {'nombre': 'Assassin\'s Creed III Remastered', 'tienda': 'Steam', 'genero': 'Acción · Aventura', 'appid': '911400'},
    'repo': {'nombre': 'R.E.P.O.', 'tienda': 'Steam', 'genero': 'Indie · Acción', 'appid': '3241660'},

    // Rockstar
    'gta5': {'nombre': 'Grand Theft Auto V', 'tienda': 'Steam', 'genero': 'Acción · Mundo Abierto', 'appid': '271590'},
    'gtav': {'nombre': 'Grand Theft Auto V', 'tienda': 'Steam', 'genero': 'Acción · Mundo Abierto', 'appid': '271590'},
    'playgtav': {'nombre': 'Grand Theft Auto V', 'tienda': 'Steam', 'genero': 'Acción · Mundo Abierto', 'appid': '271590'},
    'rdr2': {'nombre': 'Red Dead Redemption 2', 'tienda': 'Steam', 'genero': 'Acción · Aventura', 'appid': '1174180'},

    // FromSoftware / Soulslike
    'eldenring': {'nombre': 'Elden Ring', 'tienda': 'Steam', 'genero': 'RPG · Acción', 'appid': '1245620'},
    'sekiro': {'nombre': 'Sekiro: Shadows Die Twice', 'tienda': 'Steam', 'genero': 'Acción · Aventura', 'appid': '814380'},
    'darksoulsiii': {'nombre': 'Dark Souls III', 'tienda': 'Steam', 'genero': 'RPG · Acción', 'appid': '374320'},
    'darksouls': {'nombre': 'Dark Souls Remastered', 'tienda': 'Steam', 'genero': 'RPG · Acción', 'appid': '570940'},
    'armoredcore6': {'nombre': 'Armored Core VI', 'tienda': 'Steam', 'genero': 'Acción · Mechas', 'appid': '1888140'},
    'liesofp': {'nombre': 'Lies of P', 'tienda': 'Steam', 'genero': 'Soulslike · Acción', 'appid': '1627720'},

    // CD Projekt Red
    'cyberpunk2077': {'nombre': 'Cyberpunk 2077', 'tienda': 'Steam', 'genero': 'RPG · Acción', 'appid': '1091500'},
    'witcher3': {'nombre': 'The Witcher 3: Wild Hunt', 'tienda': 'Steam', 'genero': 'RPG · Aventura', 'appid': '292030'},

    // Capcom / Resident Evil
    're4': {'nombre': 'Resident Evil 4 Remake', 'tienda': 'Steam', 'genero': 'Terror · Acción', 'appid': '2050650'},
    're4remake': {'nombre': 'Resident Evil 4 Remake', 'tienda': 'Steam', 'genero': 'Terror · Acción', 'appid': '2050650'},
    're8': {'nombre': 'Resident Evil Village', 'tienda': 'Steam', 'genero': 'Terror · Acción', 'appid': '1196590'},
    're2': {'nombre': 'Resident Evil 2', 'tienda': 'Steam', 'genero': 'Terror · Supervivencia', 'appid': '883710'},
    're3': {'nombre': 'Resident Evil 3', 'tienda': 'Steam', 'genero': 'Terror · Acción', 'appid': '952060'},
    're7': {'nombre': 'Resident Evil 7 Biohazard', 'tienda': 'Steam', 'genero': 'Terror · Acción', 'appid': '418370'},
    'biohazard': {'nombre': 'Resident Evil', 'tienda': 'Steam', 'genero': 'Terror', 'appid': '418370'},
    'devilmaycry5': {'nombre': 'Devil May Cry 5', 'tienda': 'Steam', 'genero': 'Acción · Hack & Slash', 'appid': '601150'},
    'dmc5': {'nombre': 'Devil May Cry 5', 'tienda': 'Steam', 'genero': 'Acción · Hack & Slash', 'appid': '601150'},
    'monsterhunterworld': {'nombre': 'Monster Hunter: World', 'tienda': 'Steam', 'genero': 'RPG · Acción', 'appid': '582010'},

    // Larian Studios
    'bg3': {'nombre': 'Baldur\'s Gate 3', 'tienda': 'Steam', 'genero': 'RPG · Rol', 'appid': '1086940'},
    'bg3_dx11': {'nombre': 'Baldur\'s Gate 3', 'tienda': 'Steam', 'genero': 'RPG · Rol', 'appid': '1086940'},

    // PlayStation PC Ports
    'godofwar': {'nombre': 'God of War', 'tienda': 'PS', 'genero': 'Acción · Aventura', 'appid': '1593500'},
    'gow': {'nombre': 'God of War', 'tienda': 'PS', 'genero': 'Acción · Aventura', 'appid': '1593500'},
    'spiderman': {'nombre': 'Marvel\'s Spider-Man Remastered', 'tienda': 'PS', 'genero': 'Acción · Mundo Abierto', 'appid': '1817070'},
    'milesmorales': {'nombre': 'Marvel\'s Spider-Man: Miles Morales', 'tienda': 'PS', 'genero': 'Acción · Aventura', 'appid': '1817190'},
    'tlou-i': {'nombre': 'The Last of Us Part I', 'tienda': 'PS', 'genero': 'Aventura · Acción', 'appid': '1888930'},
    'thelastofus': {'nombre': 'The Last of Us Part I', 'tienda': 'PS', 'genero': 'Aventura · Acción', 'appid': '1888930'},
    'horizonzerodawn': {'nombre': 'Horizon Zero Dawn', 'tienda': 'PS', 'genero': 'Acción · Rol', 'appid': '1151640'},
    'daysgone': {'nombre': 'Days Gone', 'tienda': 'PS', 'genero': 'Mundo Abierto · Supervivencia', 'appid': '1259420'},
    'ghostsoftsushima': {'nombre': 'Ghost of Tsushima', 'tienda': 'PS', 'genero': 'Acción · Aventura', 'appid': '2215430'},

    // Xbox & Bethesda
    'forzahorizon5': {'nombre': 'Forza Horizon 5', 'tienda': 'Xbox', 'genero': 'Carreras', 'appid': '1551360'},
    'forzahorizon4': {'nombre': 'Forza Horizon 4', 'tienda': 'Xbox', 'genero': 'Carreras', 'appid': '1293830'},
    'starfield': {'nombre': 'Starfield', 'tienda': 'Xbox', 'genero': 'RPG · Espacial', 'appid': '1716740'},
    'skyrimse': {'nombre': 'The Elder Scrolls V: Skyrim SE', 'tienda': 'Xbox', 'genero': 'RPG · Aventura', 'appid': '489830'},
    'tesv': {'nombre': 'Skyrim', 'tienda': 'Xbox', 'genero': 'RPG · Aventura', 'appid': '72850'},
    'fallout4': {'nombre': 'Fallout 4', 'tienda': 'Xbox', 'genero': 'RPG · Acción', 'appid': '377160'},
    'doometernal': {'nombre': 'DOOM Eternal', 'tienda': 'Xbox', 'genero': 'Shooter · Acción', 'appid': '782330'},
    'doom': {'nombre': 'DOOM', 'tienda': 'Xbox', 'genero': 'Shooter · Acción', 'appid': '379720'},
    'minecraft': {'nombre': 'Minecraft', 'tienda': 'Xbox', 'genero': 'Sandbox · Aventura', 'cover': 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/413150/header.jpg'},

    // Deportes y Carreras (FIFA, PES, NFS)
    'fc24': {'nombre': 'EA SPORTS FC 24', 'tienda': 'Steam', 'genero': 'Deportes · Fútbol', 'appid': '2195250'},
    'fc25': {'nombre': 'EA SPORTS FC 25', 'tienda': 'Steam', 'genero': 'Deportes · Fútbol', 'appid': '2669320'},
    'fifa23': {'nombre': 'FIFA 23', 'tienda': 'Steam', 'genero': 'Deportes · Fútbol', 'appid': '1811260'},
    'fifa22': {'nombre': 'FIFA 22', 'tienda': 'Steam', 'genero': 'Deportes · Fútbol', 'appid': '1506830'},
    'pes2021': {'nombre': 'eFootball PES 2021', 'tienda': 'Steam', 'genero': 'Deportes · Fútbol', 'appid': '1259970'},
    'nfsunbound': {'nombre': 'Need for Speed Unbound', 'tienda': 'Steam', 'genero': 'Carreras', 'appid': '1846380'},
    'nfsheat': {'nombre': 'Need for Speed Heat', 'tienda': 'Steam', 'genero': 'Carreras', 'appid': '1222680'},
    'rocketleague': {'nombre': 'Rocket League', 'tienda': 'Epic', 'genero': 'Deportes · Acción', 'appid': '252950'},

    // Indie & Plataformas
    'hollow_knight': {'nombre': 'Hollow Knight', 'tienda': 'Epic', 'genero': 'Metroidvania · 2D', 'appid': '367520'},
    'hollowknight': {'nombre': 'Hollow Knight', 'tienda': 'Epic', 'genero': 'Metroidvania · 2D', 'appid': '367520'},
    'celeste': {'nombre': 'Celeste', 'tienda': 'Steam', 'genero': 'Plataformas · Indie', 'appid': '504230'},
    'hades': {'nombre': 'Hades', 'tienda': 'Epic', 'genero': 'Acción · Indie', 'appid': '1145360'},
    'hades2': {'nombre': 'Hades II', 'tienda': 'Steam', 'genero': 'Acción · Roguelike', 'appid': '1145350'},
    'cuphead': {'nombre': 'Cuphead', 'tienda': 'Steam', 'genero': 'Plataformas · Acción', 'appid': '268910'},
    'deadcells': {'nombre': 'Dead Cells', 'tienda': 'Steam', 'genero': 'Roguelike · Acción', 'appid': '588650'},
    'terraria': {'nombre': 'Terraria', 'tienda': 'Steam', 'genero': 'Sandbox · Aventura', 'appid': '105600'},
    'subnautica': {'nombre': 'Subnautica', 'tienda': 'Steam', 'genero': 'Supervivencia', 'appid': '264710'},
    'lethal company': {'nombre': 'Lethal Company', 'tienda': 'Steam', 'genero': 'Terror · Coop', 'appid': '1966720'},
    'lethalcompany': {'nombre': 'Lethal Company', 'tienda': 'Steam', 'genero': 'Terror · Coop', 'appid': '1966720'},
    'palworld': {'nombre': 'Palworld', 'tienda': 'Steam', 'genero': 'Supervivencia · Aventura', 'appid': '1623730'},
    'balatro': {'nombre': 'Balatro', 'tienda': 'Steam', 'genero': 'Roguelike · Cartas', 'appid': '2379780'},
    'ittakestwo': {'nombre': 'It Takes Two', 'tienda': 'Steam', 'genero': 'Aventura · Coop', 'appid': '1426210'},

    // Epic & Riot & Hoyoverse
    'fortniteclient-win64-shipping': {'nombre': 'Fortnite', 'tienda': 'Epic', 'genero': 'Battle Royale · Acción', 'cover': 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg'},
    'fortnite': {'nombre': 'Fortnite', 'tienda': 'Epic', 'genero': 'Battle Royale · Acción', 'cover': 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg'},
    'genshinimpact': {'nombre': 'Genshin Impact', 'tienda': 'Epic', 'genero': 'RPG · Aventura', 'cover': 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1145360/header.jpg'},
    'starrail': {'nombre': 'Honkai: Star Rail', 'tienda': 'Epic', 'genero': 'RPG · Estrategia', 'cover': 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1145360/header.jpg'},
    'valorant': {'nombre': 'VALORANT', 'tienda': 'PC', 'genero': 'Shooter Táctico', 'cover': 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/730/header.jpg'},
    'leagueclient': {'nombre': 'League of Legends', 'tienda': 'PC', 'genero': 'MOBA', 'cover': 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/570/header.jpg'},
    'leagueclientux': {'nombre': 'League of Legends', 'tienda': 'PC', 'genero': 'MOBA', 'cover': 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/570/header.jpg'},
  };

  /// Lista en caché de juegos locales de Steam
  static List<Juego>? _cachedLocalSteamGames;

  /// Lee los manifiestos de Steam locales en Windows (C:\Program Files (x86)\Steam\steamapps)
  static List<Juego> getInstalledSteamGames() {
    if (kIsWeb || !Platform.isWindows) return [];
    if (_cachedLocalSteamGames != null) return _cachedLocalSteamGames!;

    final List<Juego> list = [];
    final paths = [
      r'C:\Program Files (x86)\Steam\steamapps',
      r'C:\Program Files\Steam\steamapps',
      r'D:\SteamLibrary\steamapps',
      r'E:\SteamLibrary\steamapps',
    ];

    for (final p in paths) {
      final dir = Directory(p);
      if (!dir.existsSync()) continue;

      try {
        for (final entity in dir.listSync()) {
          if (entity is File && entity.path.toLowerCase().endsWith('.acf')) {
            final content = entity.readAsStringSync();
            final nameMatch = RegExp(r'"name"\s+"([^"]+)"').firstMatch(content);
            final idMatch = RegExp(r'"appid"\s+"([^"]+)"').firstMatch(content);

            if (nameMatch != null && idMatch != null) {
              final appid = idMatch.group(1)!;
              final name = nameMatch.group(1)!;

              if (appid != '228980' && !name.toLowerCase().contains('steamworks')) {
                list.add(Juego(
                  nombre: name,
                  genero: 'Steam Local',
                  tienda: 'Steam',
                  jugadores: '1 jugador',
                  estado: 'Jugando',
                  id: int.tryParse(appid),
                  imageUrl: 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/$appid/header.jpg',
                ));
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error leyendo directorio de Steam: $e');
      }
    }

    _cachedLocalSteamGames = list;
    return list;
  }

  /// Importa juegos instalados ya sea en Windows nativo o a través del monitor local en Web
  static Future<List<Juego>> getInstalledSteamGamesAsync() async {
    if (!kIsWeb) {
      return getInstalledSteamGames();
    }

    // Si estamos en Web (Edge / Chrome), consultamos el monitor local en 127.0.0.1:38291
    try {
      final res = await http.get(Uri.parse('http://127.0.0.1:38291/installed')).timeout(const Duration(milliseconds: 1500));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final list = data['installed'] as List? ?? [];
        return list.map((item) => Juego.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  /// Escanea los procesos en ejecución en Windows para detectar si hay algún juego activo
  static Future<Juego?> scanRunningGame() async {
    // 1. Si estamos en Web (Edge / Chrome), consultamos el monitor local por HTTP
    if (kIsWeb) {
      try {
        final res = await http.get(Uri.parse('http://127.0.0.1:38291/status')).timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['running'] != null) {
            return Juego.fromJson(data['running']);
          }
        }
      } catch (_) {}
      return null;
    }

    // 2. Si estamos en Windows nativo de escritorio
    if (!Platform.isWindows) {
      return null;
    }

    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        '(Get-Process).ProcessName',
      ]);

      if (result.exitCode != 0) return null;

      final stdout = (result.stdout as String).toLowerCase();
      final processLines = stdout
          .split(RegExp(r'[\r\n]+'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toSet();

      // Comparar contra juegos de Steam instalados
      final localSteam = getInstalledSteamGames();
      for (final g in localSteam) {
        final simpleGame = g.nombre.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        for (final proc in processLines) {
          final simpleProc = proc.replaceAll(RegExp(r'[^a-z0-9]'), '');
          if (simpleProc.isNotEmpty && (simpleProc == simpleGame || (simpleProc.length >= 5 && simpleGame.contains(simpleProc)))) {
            return g.copyWith(isLivePlaying: true);
          }
        }
      }

      // Comparar contra base conocida
      for (final entry in _knownGames.entries) {
        final key = entry.key.toLowerCase().replaceAll('.exe', '').trim();
        if (processLines.contains(key)) {
          final data = entry.value;
          final appid = data['appid'];
          final coverUrl = appid != null
              ? 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/$appid/header.jpg'
              : data['cover'];

          return Juego(
            nombre: data['nombre']!,
            genero: data['genero']!,
            tienda: data['tienda']!,
            jugadores: '1 jugador',
            estado: 'Jugando',
            imageUrl: coverUrl,
            id: appid != null ? int.tryParse(appid) : null,
            isLivePlaying: true,
          );
        }
      }

      // Heurística Unreal Engine
      for (final proc in processLines) {
        if (proc.endsWith('-win64-shipping') || proc.endsWith('_shipping')) {
          final raw = proc
              .replaceAll('-win64-shipping', '')
              .replaceAll('_shipping', '')
              .replaceAll('_', ' ')
              .replaceAll('-', ' ');

          final cleanName = raw.split(' ').map((w) {
            return w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '';
          }).join(' ').trim();

          if (cleanName.length > 2) {
            return Juego(
              nombre: cleanName,
              genero: 'Juego de PC',
              tienda: 'PC',
              jugadores: '1 jugador',
              estado: 'Jugando',
              isLivePlaying: true,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error en LocalProcessService.scanRunningGame: $e');
    }

    return null;
  }

  /// Retorna la lista de procesos activos que no son del sistema para vincular manualmente
  static Future<List<String>> getCandidateRunningProcesses() async {
    if (!kIsWeb && Platform.isWindows) {
      try {
        final result = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          r'Get-Process | Where-Object { $_.MainWindowTitle -ne "" -or $_.WS -gt 50000000 } | Select-Object -ExpandProperty ProcessName | Sort-Object -Unique',
        ]);

        if (result.exitCode == 0) {
          final ignoreList = {
            'explorer', 'chrome', 'msedge', 'code', 'flutter', 'dart', 'powershell',
            'cmd', 'conhost', 'system', 'idle', 'svchost', 'taskmgr', 'antigravity',
            'brave', 'firefox', 'discord', 'spotify', 'devenv'
          };

          final lines = (result.stdout as String)
              .split(RegExp(r'[\r\n]+'))
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty && !ignoreList.contains(p.toLowerCase()))
              .toList();

          return lines;
        }
      } catch (e) {
        debugPrint('Error en getCandidateRunningProcesses: $e');
      }
    }

    return [];
  }
}
