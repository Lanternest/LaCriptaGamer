// lib/widgets/game_card.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/game_data.dart';

class GameCard extends StatefulWidget {
  final Juego juego;
  const GameCard({super.key, required this.juego});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.inputBg : AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Imagen placeholder
            Container(
              width: 80, height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF333355),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.sports_esports,
                  color: AppColors.fgDim, size: 30),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.juego.nombre,
                      style: const TextStyle(
                          color: AppColors.fg,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(widget.juego.genero,
                      style: const TextStyle(
                          color: AppColors.fgDim, fontSize: 12)),
                  const SizedBox(height: 8),

                  // Badges
                  Row(
                    children: [
                      _badge(widget.juego.tienda),
                      const SizedBox(width: 6),
                      _badge(widget.juego.estado),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentOff,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(texto,
          style: const TextStyle(color: AppColors.fg, fontSize: 11)),
    );
  }
}