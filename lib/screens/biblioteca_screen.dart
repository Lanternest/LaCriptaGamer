// lib/screens/biblioteca_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/game_data.dart';
import '../widgets/game_card.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen>
    with SingleTickerProviderStateMixin {

  final _searchCtrl   = TextEditingController();
  final _tiendasSel   = <String>{};
  final _jugadoresSel = <String>{};
  final _generosSel   = <String>{};
  String _estadoSel   = "Todos";
  bool _filterVisible = false;

  late final AnimationController _animCtrl;
  late final Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
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
    final q = _searchCtrl.text.trim().toLowerCase();
    return juegos.where((j) {
      if (q.isNotEmpty && !j.nombre.toLowerCase().contains(q)) return false;
      if (_tiendasSel.isNotEmpty && !_tiendasSel.contains(j.tienda)) return false;
      if (_jugadoresSel.isNotEmpty && !_jugadoresSel.contains(j.jugadores)) return false;
      if (_generosSel.isNotEmpty &&
          !_generosSel.any((g) => j.genero.toLowerCase().contains(g.toLowerCase())))
        return false;
      if (_estadoSel != "Todos" && j.estado != _estadoSel) return false;
      return true;
    }).toList();
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
              _buildChipsTienda(),
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
            width: 280,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.sports_esports, color: AppColors.accent, size: 36),
          const SizedBox(width: 12),
          const Text("LA CRIPTA\nGAMER", style: AppStyles.title),
          const Spacer(),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: AppStyles.body,
              decoration: InputDecoration(
                hintText: "Buscar juegos...",
                hintStyle: const TextStyle(color: AppColors.fgDim, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.fgDim, size: 18),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
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

  Widget _buildChipsTienda() {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                backgroundColor: AppColors.accentOff,
                selectedColor: AppColors.accent,
                labelStyle: TextStyle(
                  color: AppColors.fg,
                  fontSize: 12,
                  fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                ),
                checkmarkColor: AppColors.fg,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGameList() {
    final lista = _filtrados;
    if (lista.isEmpty) {
      return const Center(
        child: Text("No se encontraron juegos.",
            style: TextStyle(color: AppColors.fgDim)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: lista.length,
      itemBuilder: (_, i) => GameCard(juego: lista[i]),
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
                const Text("Filtros",
                    style: TextStyle(
                        color: AppColors.fg,
                        fontSize: 16,
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
                _filterSection("Tienda", tiendas, _tiendasSel,
                    (v) => setState(() => _tiendasSel.contains(v)
                        ? _tiendasSel.remove(v) : _tiendasSel.add(v))),
                _filterSection("Jugadores", jugadores, _jugadoresSel,
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(titulo,
              style: const TextStyle(
                  color: AppColors.fgDim,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0)),
        ),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((item) {
            final activo = seleccionados.contains(item);
            return GestureDetector(
              onTap: () => onToggle(item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: activo ? AppColors.accent : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item,
                    style: TextStyle(
                        color: activo ? AppColors.fg : AppColors.fgDim,
                        fontSize: 12)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.inputBg),
      ],
    );
  }

  Widget _estadoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("Estado del juego",
              style: TextStyle(
                  color: AppColors.fgDim,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0)),
        ),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: estados.map((e) {
            final activo = _estadoSel == e;
            return GestureDetector(
              onTap: () => setState(() => _estadoSel = e),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: activo ? AppColors.accent : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(e,
                    style: TextStyle(
                        color: activo ? AppColors.fg : AppColors.fgDim,
                        fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}