import 'package:flutter/material.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

enum AppThemeId {
  cozyClassic,
  nocheCalida,
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
  final Color grisHandle;
  final bool isDark;

  const CozyPalette({
    required this.id,
    required this.fondoSoft,
    required this.naranjaPiel,
    required this.rosaFuerte,
    required this.textoOscuro,
    required this.grisHandle,
    this.isDark = false,
  });

  List<Color> get previewColors => [
        fondoSoft,
        naranjaPiel,
        rosaFuerte,
        textoOscuro,
      ];

  String getLocalizedName(AppLocalizations l10n) {
    switch (id) {
      case AppThemeId.cozyClassic:
        return l10n.theme_name_cozy_classic;
      case AppThemeId.nocheCalida:
        return l10n.theme_name_noche_calida;
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
    grisHandle: Color(0xFFBDC7C1),
    isDark: false,
  );

  static const CozyPalette nocheCalida = CozyPalette(
    id: AppThemeId.nocheCalida,
    fondoSoft: Color(0xFF1E1E2A),
    naranjaPiel: Color(0xFF2C2A3E),
    rosaFuerte: Color(0xFFFF8A9E),
    textoOscuro: Color(0xFFE8E5EE),
    grisHandle: Color(0xFF55516D),
    isDark: true,
  );

  static const CozyPalette matchaZen = CozyPalette(
    id: AppThemeId.matchaZen,
    fondoSoft: Color(0xFFEAF1EB),
    naranjaPiel: Color(0xFFD8E4DA),
    rosaFuerte: Color(0xFF8BAA99),
    textoOscuro: Color(0xFF3F5448),
    grisHandle: Color(0xFFB4C7BA),
    isDark: false,
  );

  static const CozyPalette tonosTierra = CozyPalette(
    id: AppThemeId.tonosTierra,
    fondoSoft: Color(0xFFF6EFE9),
    naranjaPiel: Color(0xFFE7D8CC),
    rosaFuerte: Color(0xFFCF8569),
    textoOscuro: Color(0xFF5E4233),
    grisHandle: Color(0xFFC7B3A3),
    isDark: false,
  );

  static const CozyPalette nieblaLavanda = CozyPalette(
    id: AppThemeId.nieblaLavanda,
    fondoSoft: Color(0xFFEFEBF6),
    naranjaPiel: Color(0xFFE0D8EE),
    rosaFuerte: Color(0xFFA98EC7),
    textoOscuro: Color(0xFF4E4163),
    grisHandle: Color(0xFFBCB0D1),
    isDark: false,
  );

  static const Map<AppThemeId, CozyPalette> all = {
    AppThemeId.cozyClassic: cozyClassic,
    AppThemeId.nocheCalida: nocheCalida,
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
