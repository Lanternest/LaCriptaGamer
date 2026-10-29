// lib/widgets/game_card.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/game_data.dart';

class GameCard extends StatefulWidget {
  final Juego juego;
  final VoidCallback? onAdd;
  final bool showAddButton;

  const GameCard({
    super.key,
    required this.juego,
    this.onAdd,
    this.showAddButton = false,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isLive = widget.juego.isLivePlaying;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isLive
              ? const Color(0xFF1E2238)
              : (_hovered ? AppColors.inputBg : AppColors.cardBg),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isLive
                ? const Color(0xFF00E676)
                : (_hovered ? AppColors.accentH : Colors.transparent),
            width: isLive ? 1.5 : 1.0,
          ),
          boxShadow: isLive
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : (_hovered
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        blurRadius: 8,
                      )
                    ]
                  : null),
        ),
        child: Row(
          children: [
            // Portada / Carátula de juego o placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 90,
                height: 65,
                color: const Color(0xFF333355),
                child: widget.juego.imageUrl != null && widget.juego.imageUrl!.isNotEmpty
                    ? Image.network(
                        widget.juego.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholder(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            ),
                          );
                        },
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 14),

            // Metadatos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.juego.nombre,
                          style: const TextStyle(
                            color: AppColors.fg,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 6),
                        _liveBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.juego.genero,
                    style: const TextStyle(
                      color: AppColors.fgDim,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Badges inferiores
                  Row(
                    children: [
                      _badge(widget.juego.tienda, isStore: true),
                      const SizedBox(width: 6),
                      _badge(widget.juego.estado),
                      if (widget.juego.metacritic != null) ...[
                        const SizedBox(width: 6),
                        _metaBadge(widget.juego.metacritic!),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Botón de acción opcional (para agregar desde catálogo)
            if (widget.showAddButton && widget.onAdd != null)
              IconButton(
                icon: const Icon(Icons.playlist_add, color: AppColors.accentH),
                tooltip: 'Añadir a mi biblioteca',
                onPressed: widget.onAdd,
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(Icons.sports_esports, color: AppColors.fgDim, size: 28),
    );
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withValues(alpha: 0.15),
        border: Border.all(color: const Color(0xFF00E676)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(0xFF00E676), size: 7),
          SizedBox(width: 4),
          Text(
            'EN VIVO',
            style: TextStyle(
              color: Color(0xFF00E676),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String texto, {bool isStore = false}) {
    Color bg = AppColors.accentOff;
    Color fg = AppColors.fg;

    if (isStore) {
      if (texto == 'Steam') bg = const Color(0xFF1B2838);
      if (texto == 'Epic') bg = const Color(0xFF2F2F2F);
      if (texto == 'Xbox') bg = const Color(0xFF107C10);
      if (texto == 'PS') bg = const Color(0xFF003791);
      if (texto == 'Nintendo') bg = const Color(0xFFE60012);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _metaBadge(int score) {
    Color scoreColor = score >= 75
        ? const Color(0xFF66CC33)
        : (score >= 50 ? const Color(0xFFFFCC33) : const Color(0xFFFF3333));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: scoreColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$score',
        style: TextStyle(
          color: scoreColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
