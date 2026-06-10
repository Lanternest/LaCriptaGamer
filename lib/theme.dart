import 'package:flutter/material.dart';

class AppColors {
  static const bg        = Color(0xFF1a1a2e);
  static const cardBg    = Color(0xFF16213e);
  static const panelBg   = Color(0xFF0f0f1a);
  static const accent    = Color(0xFF7b2fbe);
  static const accentH   = Color(0xFF9d4edd);
  static const accentOff = Color(0xFF3a1a6e);
  static const fg        = Color(0xFFffffff);
  static const fgDim     = Color(0xFFaaaaaa);
  static const inputBg   = Color(0xFF2a2a3e);
}

class AppStyles {
  static const title = TextStyle(
    color: AppColors.fg,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  static const body = TextStyle(
    color: AppColors.fg,
    fontSize: 14,
  );

  static const dim = TextStyle(
    color: AppColors.fgDim,
    fontSize: 13,
  );

  static const label = TextStyle(
    color: AppColors.fg,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );
}