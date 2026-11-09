import 'package:flutter/material.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

enum AppThemeId {
  cozyClassic,
  nocheCalida,
  cafeMedianoche,
  matchaZen,
  tonosTierra,
  nieblaLavanda,
}

class CozyPalette {
  final AppThemeId id;
  final Color fondoSoft;
  final Color naranjaPiel;
  final Color rosaFuerte;
  final Color textoOscuro;
  final Color strokeColor;
  final Color grisHandle;
  final Color? emojiColor;
  final bool isDark;

  const CozyPalette({
    required this.id,
    required this.fondoSoft,
    required this.naranjaPiel,
    required this.rosaFuerte,
    required this.textoOscuro,
    required this.strokeColor,
    required this.grisHandle,
    this.emojiColor,
    this.isDark = false,
  });

  Color get resolvedEmojiColor => emojiColor ?? textoOscuro;

  List<Color> get previewColors => [
        fondoSoft,
        naranjaPiel,
        rosaFuerte,
        resolvedEmojiColor,
      ];

  String getLocalizedName(AppLocalizations l10n) {
    switch (id) {
      case AppThemeId.cozyClassic:
        return l10n.theme_name_cozy_classic;
      case AppThemeId.nocheCalida:
        return l10n.theme_name_noche_calida;
      case AppThemeId.cafeMedianoche:
        return l10n.theme_name_cafe_medianoche;
      case AppThemeId.matchaZen:
        return l10n.theme_name_matcha_zen;
      case AppThemeId.tonosTierra:
        return l10n.theme_name_tonos_tierra;
      case AppThemeId.nieblaLavanda:
        return l10n.theme_name_niebla_lavanda;
    }
  }
}

class AppPalettes {
  static const CozyPalette cozyClassic = CozyPalette(
    id: AppThemeId.cozyClassic,
    fondoSoft: Color(0xFFD8E2DC),
    naranjaPiel: Color(0xFFFFE5D9),
    rosaFuerte: Color(0xFFF4ACB7),
    textoOscuro: Color(0xFF9D8189),
    strokeColor: Color(0xFF9D8189),
    grisHandle: Color(0xFFBDC7C1),
    isDark: false,
  );

  static const CozyPalette nocheCalida = CozyPalette(
    id: AppThemeId.nocheCalida,
    fondoSoft: Color(0xFF101423), 
    naranjaPiel: Color(0xFF1B2236), 
    rosaFuerte: Color(0xFF9BB1FF), 
    textoOscuro: Color(0xFFE2E7F5), 
    strokeColor: Color(0xFF2B3754), 
    grisHandle: Color(0xFF384666), 
    emojiColor: Color(0xFFE2E7F5), 
    isDark: true,
  );

  static const CozyPalette cafeMedianoche = CozyPalette(
    id: AppThemeId.cafeMedianoche,
    fondoSoft: Color(0xFF1C1512), 
    naranjaPiel: Color(0xFF2C221D), 
    rosaFuerte: Color(0xFFE5A869), 
    textoOscuro: Color(0xFFF4EBD9), 
    strokeColor: Color(0xFF1C1512), 
    grisHandle: Color(0xFF564338), 
    emojiColor: Color(0xFFF4EBD9), 
    isDark: true,
  );

  static const CozyPalette matchaZen = CozyPalette(
    id: AppThemeId.matchaZen,
    fondoSoft: Color(0xFFFEFAF3), 
    naranjaPiel: Color(0xFFDCE8D5), 
    rosaFuerte: Color(0xFFDF9CA8), 
    textoOscuro: Color(0xFF476645), 
    strokeColor: Color(0xFF964A5A), 
    grisHandle: Color(0xFFB8CFB3), 
    emojiColor: Color(0xFFDF9CA8), 
    isDark: false,
  );

  static const CozyPalette tonosTierra = CozyPalette(
    id: AppThemeId.tonosTierra,
    fondoSoft: Color(0xFFFAF6EE), 
    naranjaPiel: Color(0xFFF3E4C9), 
    rosaFuerte: Color(0xFFBABF94), 
    textoOscuro: Color(0xFF8C5E47), 
    strokeColor: Color(0xFF8C5E47),
    grisHandle: Color(0xFFBFA28C), 
    isDark: false,
  );

  static const CozyPalette nieblaLavanda = CozyPalette(
    id: AppThemeId.nieblaLavanda,
    fondoSoft: Color(0xFFF5EEFB), 
    naranjaPiel: Color(0xFFFED2E2), 
    rosaFuerte: Color(0xFFC68EFD), 
    textoOscuro: Color(0xFF6E63D8),
    strokeColor: Color(0xFF6E63D8),
    grisHandle: Color(0xFFE9A5F1), 
    isDark: false,
  );

  static const Map<AppThemeId, CozyPalette> all = {
    AppThemeId.cozyClassic: cozyClassic,
    AppThemeId.nocheCalida: nocheCalida,
    AppThemeId.cafeMedianoche: cafeMedianoche,
    AppThemeId.matchaZen: matchaZen,
    AppThemeId.tonosTierra: tonosTierra,
    AppThemeId.nieblaLavanda: nieblaLavanda,
  };

  static CozyPalette fromId(String? id) {
    if (id == null) return cozyClassic;
    for (final entry in all.entries) {
      if (entry.key.name == id) {
        return entry.value;
      }
    }
    return cozyClassic;
  }
}
