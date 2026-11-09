import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/theme_controller.dart';
import 'package:cozy_feels_app/core/theme/app_palettes.dart';

class AppColors {
  static CozyPalette get current => ThemeController.instance.currentPalette;

  static Color get fondoSoft => current.fondoSoft;
  static Color get naranjaPiel => current.naranjaPiel;
  static Color get rosaFuerte => current.rosaFuerte;
  static Color get textoOscuro => current.textoOscuro;
  static Color get strokeColor => current.strokeColor;
  static Color get grisHandle => current.grisHandle;
  static Color get emojiColor => current.resolvedEmojiColor;
}