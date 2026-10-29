// lib/services/game_aggregator.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/game_data.dart';
import 'rawg_service.dart';
import 'steam_service.dart';
import 'local_process_service.dart';

class GameAggregator extends ChangeNotifier {
  static final GameAggregator _instance = GameAggregator._internal();
  factory GameAggregator() => _instance;
  GameAggregator._internal();

  final List<Juego> _myLibrary = List.from(juegosIniciales);
  List<Juego> _catalogExplore = [];
  Juego? _currentlyPlaying;
  bool _isSimulationActive = false;
  bool _isLoading = false;
  bool _isCatalogMode = false;
  Timer? _detectionTimer;

  List<Juego> get myLibrary => _myLibrary;
  List<Juego> get catalogExplore => _catalogExplore;
  Juego? get currentlyPlaying => _currentlyPlaying;
  bool get isLoading => _isLoading;
  bool get isCatalogMode => _isCatalogMode;
  bool get isSimulationActive => _isSimulationActive;

  /// Inicializa el monitor en segundo plano
  void init() {
    // Escaneo inicial inmediato
    checkLivePlaying();

    // Verificación periódica cada 8 segundos
    _detectionTimer?.cancel();
    _detectionTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      checkLivePlaying();
    });
  }

  void toggleCatalogMode(bool value) {
    _isCatalogMode = value;
    notifyListeners();
  }

  /// Limpia cualquier marca de en vivo en las tarjetas de la biblioteca
  void _clearLiveFlagsInLibrary() {
    for (int i = 0; i < _myLibrary.length; i++) {
      if (_myLibrary[i].isLivePlaying) {
        _myLibrary[i] = _myLibrary[i].copyWith(isLivePlaying: false);
      }
    }
  }

  /// Marca únicamente un juego REAL en la biblioteca si se detectó corriendo
  void _markRealGameAsPlaying(Juego game) {
    _clearLiveFlagsInLibrary();
    final idx = _myLibrary.indexWhere(
      (j) => j.nombre.toLowerCase() == game.nombre.toLowerCase(),
    );

    if (idx != -1) {
      _myLibrary[idx] = _myLibrary[idx].copyWith(
        estado: 'Jugando',
        isLivePlaying: true,
      );
    }
  }

  /// Verifica si el usuario está jugando a algo (Escaneo local de Windows o Steam)
  Future<void> checkLivePlaying() async {
    // Si hay una simulación manual activa para demostración, no la sobreescribimos
    if (_isSimulationActive) return;

    // 1. Intentar detectar proceso local (Windows Desktop)
    final localGame = await LocalProcessService.scanRunningGame();
    if (localGame != null) {
      _currentlyPlaying = localGame;
      _markRealGameAsPlaying(localGame);
      notifyListeners();
      return;
    }

    // 2. Si no hay proceso local pero hay Steam ID configurado
    final steamGame = await SteamService.checkCurrentlyPlaying();
    if (steamGame != null) {
      _currentlyPlaying = steamGame;
      _markRealGameAsPlaying(steamGame);
      notifyListeners();
      return;
    }

    // 3. Si no hay nada detectado
    if (_currentlyPlaying != null) {
      _currentlyPlaying = null;
      _clearLiveFlagsInLibrary();
      notifyListeners();
    }
  }

  /// Permite simular una sesión de juego en vivo (SOLO activa el banner superior)
  /// NO añade elementos falsos a la biblioteca ni coloca recuadros verdes en las tarjetas
  void simulateLivePlaying(String nombre, String tienda, String coverUrl) {
    if (nombre.isEmpty || _currentlyPlaying?.nombre == nombre) {
      _currentlyPlaying = null;
      _isSimulationActive = false;
      _clearLiveFlagsInLibrary();
    } else {
      _isSimulationActive = true;
      _currentlyPlaying = Juego(
        nombre: nombre,
        genero: 'En Vivo',
        tienda: tienda,
        jugadores: '1 jugador',
        estado: 'Jugando',
        imageUrl: coverUrl,
        isLivePlaying: true,
      );
      // La biblioteca se mantiene limpia sin recuadros verdes falsos
      _clearLiveFlagsInLibrary();
    }
    notifyListeners();
  }

  /// Importa directamente los juegos instalados en esta PC desde Steam (appmanifest)
  Future<int> importLocalInstalledGames() async {
    _isLoading = true;
    notifyListeners();

    final localGames = await LocalProcessService.getInstalledSteamGamesAsync();
    int added = 0;

    for (final lg in localGames) {
      final exists = _myLibrary.any(
        (j) => j.nombre.toLowerCase() == lg.nombre.toLowerCase(),
      );
      if (!exists) {
        _myLibrary.add(lg);
        added++;
      }
    }

    _isLoading = false;
    notifyListeners();
    return added;
  }

  /// Sincroniza e importa la biblioteca de Steam del usuario
  Future<int> syncSteamLibrary(String steamId, String apiKey) async {
    _isLoading = true;
    notifyListeners();

    SteamService.steamId = steamId;
    SteamService.apiKey = apiKey;

    // Obtiene juegos de Steam (tanto instalados locales como vía Web API)
    final steamGames = await SteamService.getOwnedGames(
      customSteamId: steamId,
      customApiKey: apiKey,
    );

    int added = 0;
    if (steamGames.isNotEmpty) {
      for (final sg in steamGames) {
        final exists = _myLibrary.any(
          (j) => j.nombre.toLowerCase() == sg.nombre.toLowerCase(),
        );
        if (!exists) {
          _myLibrary.add(sg);
          added++;
        }
      }
    }

    // Consulta estado en vivo
    await checkLivePlaying();

    _isLoading = false;
    notifyListeners();
    return added > 0 ? added : steamGames.length;
  }

  /// Busca en el catálogo mundial de RAWG
  Future<void> searchGlobalCatalog(String query) async {
    _isLoading = true;
    notifyListeners();

    if (query.trim().isEmpty) {
      _catalogExplore = await RawgService.getPopularGames();
    } else {
      _catalogExplore = await RawgService.searchGames(query);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Añade un juego del catálogo mundial a la biblioteca personal
  void addGameToLibrary(Juego game) {
    final exists = _myLibrary.any(
      (j) => j.nombre.toLowerCase() == game.nombre.toLowerCase(),
    );
    if (!exists) {
      _myLibrary.add(game.copyWith(estado: 'Pendiente', isLivePlaying: false));
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    super.dispose();
  }
}
