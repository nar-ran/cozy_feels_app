import 'package:flutter_test/flutter_test.dart';
import 'package:cozy_feels_app/core/theme/app_palettes.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppPalettes contains 6 distinct cozy palettes', () {
    expect(AppPalettes.all.length, 6);
    expect(AppPalettes.all.containsKey(AppThemeId.cozyClassic), isTrue);
    expect(AppPalettes.all.containsKey(AppThemeId.nocheCalida), isTrue);
    expect(AppPalettes.all.containsKey(AppThemeId.cafeMedianoche), isTrue);
    expect(AppPalettes.all.containsKey(AppThemeId.matchaZen), isTrue);
    expect(AppPalettes.all.containsKey(AppThemeId.tonosTierra), isTrue);
    expect(AppPalettes.all.containsKey(AppThemeId.nieblaLavanda), isTrue);
  });

  test('AppPalettes.fromId handles valid and invalid identifiers', () {
    expect(AppPalettes.fromId('nocheCalida').id, AppThemeId.nocheCalida);
    expect(AppPalettes.fromId('matchaZen').id, AppThemeId.matchaZen);
    expect(AppPalettes.fromId('invalid_id').id, AppThemeId.cozyClassic);
    expect(AppPalettes.fromId(null).id, AppThemeId.cozyClassic);
  });

  test('ThemeController switches palettes dynamically and updates AppColors', () async {
    final controller = ThemeController.instance;
    await controller.setTheme(AppThemeId.cozyClassic);

    expect(controller.currentThemeId, AppThemeId.cozyClassic);
    expect(AppColors.fondoSoft, AppPalettes.cozyClassic.fondoSoft);

    // Switch to Noche Cálida
    await controller.setTheme(AppThemeId.nocheCalida);
    expect(controller.currentThemeId, AppThemeId.nocheCalida);
    expect(controller.isDark, isTrue);
    expect(AppColors.fondoSoft, AppPalettes.nocheCalida.fondoSoft);
    expect(AppColors.textoOscuro, AppPalettes.nocheCalida.textoOscuro);

    // Switch to Matcha Zen
    await controller.setTheme(AppThemeId.matchaZen);
    expect(controller.currentThemeId, AppThemeId.matchaZen);
    expect(AppColors.fondoSoft, AppPalettes.matchaZen.fondoSoft);

    // Clean up to default
    await controller.setTheme(AppThemeId.cozyClassic);
  });
}
