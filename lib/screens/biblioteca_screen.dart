// lib/screens/biblioteca_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/game_data.dart';
import '../widgets/game_card.dart';
import '../services/game_aggregator.dart';
import '../services/local_process_service.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen>
    with SingleTickerProviderStateMixin {

  final _searchCtrl    = TextEditingController();
  final _tiendasSel    = <String>{};
  final _jugadoresSel  = <String>{};
  final _generosSel    = <String>{};
  String _estadoSel    = "Todos";
  bool _filterVisible  = false;
  bool _isCatalogMode  = false; // true = Explorar RAWG, false = Mi Biblioteca

  late final AnimationController _animCtrl;
  late final Animation<Offset>   _slideAnim;
  final GameAggregator           _aggregator = GameAggregator();

  @override
  void initState() {
    super.initState();
    _aggregator.init();
    _aggregator.addListener(_onAggregatorChange);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  void _onAggregatorChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _aggregator.removeListener(_onAggregatorChange);
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() => _filterVisible = !_filterVisible);
    _filterVisible ? _animCtrl.forward() : _animCtrl.reverse();
  }

  void _toggleTienda(String t) => setState(() =>
      _tiendasSel.contains(t) ? _tiendasSel.remove(t) : _tiendasSel.add(t));

  List<Juego> get _filtrados {
    final baseList = _isCatalogMode
        ? _aggregator.catalogExplore
        : _aggregator.myLibrary;

    final q = _searchCtrl.text.trim().toLowerCase();
    return baseList.where((j) {
      if (q.isNotEmpty && !j.nombre.toLowerCase().contains(q)) return false;
      if (_tiendasSel.isNotEmpty && !_tiendasSel.contains(j.tienda)) return false;
      if (_jugadoresSel.isNotEmpty && !_jugadoresSel.contains(j.jugadores)) return false;
      if (_generosSel.isNotEmpty &&
          !_generosSel.any((g) => j.genero.toLowerCase().contains(g.toLowerCase()))) {
        return false;
      }
      if (_estadoSel != "Todos" && j.estado != _estadoSel) return false;
      return true;
    }).toList();
  }

  void _onSearchSubmitted(String query) {
    if (_isCatalogMode) {
      _aggregator.searchGlobalCatalog(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              if (_aggregator.currentlyPlaying != null)
                _buildLivePlayingBanner(_aggregator.currentlyPlaying!),
              _buildTabSelector(),
              if (!_isCatalogMode) _buildChipsTienda(),
              Expanded(child: _buildGameList()),
            ],
          ),
          if (_filterVisible)
            GestureDetector(
              onTap: _toggleFilter,
              child: Container(color: Colors.black45),
            ),
          Positioned(
            top: 0, right: 0, bottom: 0,
            width: 290,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildFilterPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.sports_esports, color: AppColors.accent, size: 34),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("LA CRIPTA", style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
              Text("GAMER", style: TextStyle(color: AppColors.accentH, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 2.0)),
            ],
          ),
          const Spacer(),

          // Input de búsqueda
          SizedBox(
            width: 230,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                if (!_isCatalogMode) {
                  setState(() {});
                }
              },
              onSubmitted: _onSearchSubmitted,
              style: AppStyles.body,
              decoration: InputDecoration(
                hintText: _isCatalogMode ? "Buscar en RAWG..." : "Buscar en biblioteca...",
                hintStyle: const TextStyle(color: AppColors.fgDim, fontSize: 12.5),
                prefixIcon: const Icon(Icons.search, color: AppColors.fgDim, size: 18),
                suffixIcon: _isCatalogMode
                    ? IconButton(
                        icon: const Icon(Icons.arrow_forward, color: AppColors.accentH, size: 18),
                        onPressed: () => _onSearchSubmitted(_searchCtrl.text),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón de Sincronización y Configuración
          IconButton(
            tooltip: "Sincronización y Detección de Juegos",
            onPressed: _showSettingsDialog,
            icon: const Icon(Icons.sync_alt, color: AppColors.fg),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.inputBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),

          // Botón de Filtros
          IconButton(
            tooltip: "Filtros",
            onPressed: _toggleFilter,
            icon: const Icon(Icons.tune, color: AppColors.fg),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.inputBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  /// Banner animado que exhibe en tiempo real el juego que se está ejecutando
  Widget _buildLivePlayingBanner(Juego juego) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E24),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF00E676), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF00E676), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "JUGANDO EN VIVO AHORA",
                      style: TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        juego.tienda,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  juego.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 14, color: AppColors.fgDim),
            label: const Text("Re-escanear", style: TextStyle(color: AppColors.fgDim, fontSize: 11)),
            onPressed: () async {
              await _aggregator.checkLivePlaying();
              if (mounted) {
                final playing = _aggregator.currentlyPlaying;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(playing != null
                        ? "🟢 Detectado en vivo: ${playing.nombre} (${playing.tienda})"
                        : "No se detectaron juegos activos en este momento."),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.cardBg,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Selector de pestañas: Mi Biblioteca vs Explorar Catálogo (RAWG)
  Widget _buildTabSelector() {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        children: [
          _tabButton(
            title: "Mi Biblioteca (${_aggregator.myLibrary.length})",
            icon: Icons.bookmark_added,
            active: !_isCatalogMode,
            onTap: () => setState(() => _isCatalogMode = false),
          ),
          const SizedBox(width: 10),
          _tabButton(
            title: "Explorar Catálogo RAWG",
            icon: Icons.public,
            active: _isCatalogMode,
            onTap: () {
              setState(() => _isCatalogMode = true);
              if (_aggregator.catalogExplore.isEmpty) {
                _aggregator.searchGlobalCatalog("");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.accentH : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.fgDim),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : AppColors.fgDim,
                fontSize: 12.5,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipsTienda() {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tiendas.map((t) {
            final activo = _tiendasSel.contains(t);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(t),
                selected: activo,
                onSelected: (_) => _toggleTienda(t),
                backgroundColor: AppColors.cardBg,
                selectedColor: AppColors.accent,
                labelStyle: TextStyle(
                  color: activo ? Colors.white : AppColors.fgDim,
                  fontSize: 12,
                  fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                ),
                checkmarkColor: Colors.white,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGameList() {
    if (_aggregator.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accentH),
            SizedBox(height: 12),
            Text("Consultando catálogo en vivo...", style: TextStyle(color: AppColors.fgDim, fontSize: 13)),
          ],
        ),
      );
    }

    final lista = _filtrados;
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.fgDim),
            const SizedBox(height: 10),
            Text(
              _isCatalogMode
                  ? "No se hallaron resultados en RAWG para esta búsqueda."
                  : "No se encontraron juegos con los filtros seleccionados.",
              style: const TextStyle(color: AppColors.fgDim, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: lista.length,
      itemBuilder: (_, i) {
        final juego = lista[i];
        return GameCard(
          juego: juego,
          showAddButton: _isCatalogMode,
          onAdd: () {
            _aggregator.addGameToLibrary(juego);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("¡${juego.nombre} añadido a tu biblioteca!"),
                backgroundColor: AppColors.accent,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  /// Diálogo de Sincronización y Configuración de Fuentes
  void _showSettingsDialog() {
    // Detecta el SteamID64 real local si existe
    final steamIdCtrl = TextEditingController(text: "76561199286908375");
    final apiKeyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Row(
          children: [
            Icon(Icons.hub, color: AppColors.accentH),
            SizedBox(width: 10),
            Text("Conexión y Detección de Juegos", style: TextStyle(color: AppColors.fg, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alerta si corre en Web
                if (kIsWeb)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF332A15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Estás en Chrome (Web). La lectura de ejecutables de PC (.exe) de Windows solo funciona al ejecutar la aplicación de escritorio nativa: 'flutter run -d windows'.",
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 1. Detección Local de Windows
                const Text(
                  "Detección de Juegos en esta PC (Windows):",
                  style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download_for_offline, size: 16),
                        label: const Text("Importar Juegos Instalados"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2838),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final count = await _aggregator.importLocalInstalledGames();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("¡Éxito! Se importaron $count juegos instalados en tu PC."),
                                backgroundColor: AppColors.accent,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text("Escanear Juego Abierto"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00E676),
                          side: const BorderSide(color: Color(0xFF00E676)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final game = await LocalProcessService.scanRunningGame();
                          if (game != null) {
                            await _aggregator.checkLivePlaying();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("🟢 ¡Juego detectado!: ${game.nombre} (${game.tienda})"),
                                  backgroundColor: const Color(0xFF0F1E24),
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              _showProcessPickerModal();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const Divider(color: AppColors.inputBg, height: 24),

                // 2. Sincronización Steam Web API
                const Text(
                  "Sincronizar Steam Web API (Perfil Público):",
                  style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Nota: En Steam, la opción 'Detalles de los juegos' debe estar en PÚBLICO para permitir la lectura externa.",
                  style: TextStyle(color: AppColors.fgDim, fontSize: 10.5),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: steamIdCtrl,
                  style: const TextStyle(color: AppColors.fg, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: "Steam ID64",
                    labelStyle: TextStyle(color: AppColors.fgDim, fontSize: 12),
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: apiKeyCtrl,
                  style: const TextStyle(color: AppColors.fg, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: "Steam Web API Key (steamcommunity.com/dev/apikey)",
                    labelStyle: TextStyle(color: AppColors.fgDim, fontSize: 12),
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_sync, size: 16),
                  label: const Text("Sincronizar Cuenta Steam"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 38),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final count = await _aggregator.syncSteamLibrary(
                      steamIdCtrl.text.trim(),
                      apiKeyCtrl.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(count > 0
                              ? "Sincronización finalizada. $count juegos importados."
                              : "No se encontraron juegos públicos o API Key no provista. Se importaron los juegos locales."),
                          backgroundColor: count > 0 ? AppColors.accent : Colors.amber.shade900,
                        ),
                      );
                    }
                  },
                ),

                const Divider(color: AppColors.inputBg, height: 24),

                // 3. Simulación rápida para evaluación
                const Text(
                  "Simular Estado en Vivo (Para Demostración / Defensa):",
                  style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Activa solo el banner superior para mostrar la interfaz sin alterar tu lista:",
                  style: TextStyle(color: AppColors.fgDim, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text("Cyberpunk 2077 (Steam)", style: TextStyle(fontSize: 10.5, color: Colors.white)),
                      backgroundColor: const Color(0xFF1B2838),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _aggregator.simulateLivePlaying(
                          "Cyberpunk 2077",
                          "Steam",
                          "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg",
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text("Hollow Knight (Epic)", style: TextStyle(fontSize: 10.5, color: Colors.white)),
                      backgroundColor: const Color(0xFF2F2F2F),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _aggregator.simulateLivePlaying(
                          "Hollow Knight",
                          "Epic",
                          "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/367520/header.jpg",
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text("Counter-Strike 2 (Steam)", style: TextStyle(fontSize: 10.5, color: Colors.white)),
                      backgroundColor: const Color(0xFF1B2838),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _aggregator.simulateLivePlaying(
                          "Counter-Strike 2",
                          "Steam",
                          "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/730/header.jpg",
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text("Detener Simulación", style: TextStyle(fontSize: 10.5, color: Colors.redAccent)),
                      backgroundColor: AppColors.inputBg,
                      onPressed: () {
                        Navigator.pop(ctx);
                        _aggregator.simulateLivePlaying("", "", "");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cerrar", style: TextStyle(color: AppColors.fgDim)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  /// Modal que muestra los procesos activos de Windows para vincular cualquier juego (pirata o desconocido)
  Future<void> _showProcessPickerModal() async {
    final procs = await LocalProcessService.getCandidateRunningProcesses();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text("Procesos activos en tu PC", style: TextStyle(color: Colors.white, fontSize: 15)),
        content: SizedBox(
          width: 360,
          height: 300,
          child: procs.isEmpty
              ? const Center(
                  child: Text("No se encontraron procesos activos externos o estás en Web.",
                      style: TextStyle(color: AppColors.fgDim, fontSize: 12), textAlign: TextAlign.center),
                )
              : ListView.builder(
                  itemCount: procs.length,
                  itemBuilder: (_, i) {
                    final p = procs[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.gamepad, color: Color(0xFF00E676), size: 18),
                      title: Text(p, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text("Tocar para vincular como juego en vivo", style: TextStyle(color: AppColors.fgDim, fontSize: 10)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _aggregator.simulateLivePlaying(p, "PC", "");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("🟢 Vinculado en vivo: $p")),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            child: const Text("Cerrar", style: TextStyle(color: AppColors.fgDim)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: AppColors.panelBg,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
            child: Row(
              children: [
                const Text("Filtros Avanzados",
                    style: TextStyle(
                        color: AppColors.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: _toggleFilter,
                  icon: const Icon(Icons.close, color: AppColors.fgDim),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.inputBg, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _filterSection("Tienda / Plataforma", tiendas, _tiendasSel,
                    (v) => setState(() => _tiendasSel.contains(v)
                        ? _tiendasSel.remove(v) : _tiendasSel.add(v))),
                _filterSection("Modalidad de Jugadores", jugadores, _jugadoresSel,
                    (v) => setState(() => _jugadoresSel.contains(v)
                        ? _jugadoresSel.remove(v) : _jugadoresSel.add(v))),
                _filterSection("Género", generos, _generosSel,
                    (v) => setState(() => _generosSel.contains(v)
                        ? _generosSel.remove(v) : _generosSel.add(v))),
                _estadoSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterSection(String titulo, List<String> items,
      Set<String> seleccionados, void Function(String) onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(titulo,
              style: const TextStyle(
                  color: AppColors.fgDim,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0)),
        ),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: items.map((item) {
            final activo = seleccionados.contains(item);
            return GestureDetector(
              onTap: () => onToggle(item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: activo ? AppColors.accent : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item,
                    style: TextStyle(
                        color: activo ? AppColors.fg : AppColors.fgDim,
                        fontSize: 11.5)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        const Divider(color: AppColors.inputBg),
      ],
    );
  }

  Widget _estadoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text("Estado del juego",
              style: TextStyle(
                  color: AppColors.fgDim,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0)),
        ),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: estados.map((e) {
            final activo = _estadoSel == e;
            return GestureDetector(
              onTap: () => setState(() => _estadoSel = e),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: activo ? AppColors.accent : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(e,
                    style: TextStyle(
                        color: activo ? AppColors.fg : AppColors.fgDim,
                        fontSize: 11.5)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
