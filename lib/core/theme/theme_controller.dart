import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_palettes.dart';
import 'package:cozy_feels_app/features/history/domain/services/mood_storage_service.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();
  ThemeController._internal();

  final MoodStorageService _storage = MoodStorageService();
  CozyPalette _palette = AppPalettes.cozyClassic;

  CozyPalette get currentPalette => _palette;
  AppThemeId get currentThemeId => _palette.id;
  bool get isDark => _palette.isDark;

  Future<void> init() async {
    final savedThemeId = await _storage.loadTheme();
    if (savedThemeId != null) {
      _palette = AppPalettes.fromId(savedThemeId);
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeId themeId) async {
    if (_palette.id == themeId) return;
    _palette = AppPalettes.all[themeId] ?? AppPalettes.cozyClassic;
    notifyListeners();
    await _storage.saveTheme(themeId.name);
  }

  ThemeData get themeData {
    return ThemeData(
      fontFamily: 'Dongle',
      useMaterial3: true,
      brightness: _palette.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: _palette.fondoSoft,
      canvasColor: _palette.fondoSoft,
      colorScheme: ColorScheme(
        brightness: _palette.isDark ? Brightness.dark : Brightness.light,
        primary: _palette.rosaFuerte,
        onPrimary: _palette.isDark ? _palette.fondoSoft : Colors.white,
        secondary: _palette.rosaFuerte,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: _palette.naranjaPiel,
        onSurface: _palette.textoOscuro,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _palette.naranjaPiel,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _palette.naranjaPiel,
        indicatorColor: _palette.rosaFuerte.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: 'Dongle',
            fontSize: 22,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.bold
                : FontWeight.normal,
            color: states.contains(WidgetState.selected)
                ? _palette.rosaFuerte
                : _palette.textoOscuro,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? _palette.rosaFuerte
                : _palette.textoOscuro,
            size: 26,
          );
        }),
      ), dialogTheme: DialogThemeData(backgroundColor: _palette.fondoSoft),
    );
  }
}
