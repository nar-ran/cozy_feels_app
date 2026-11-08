import 'package:cozy_feels_app/core/theme/theme_controller.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/language_selector_dialog.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/notifications_manager_dialog.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/theme_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/main.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class SettingsBottomSheet extends StatelessWidget {
  final VoidCallback onOpenBackupCenter;

  const SettingsBottomSheet({
    super.key,
    required this.onOpenBackupCenter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.naranjaPiel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(25, 14, 25, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.fondoSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              _buildOption(
                icon: AppAssets.featureIcons['Language'] ??
                    AppAssets.featureIcons['Translate']!,
                title: l10n.settings_language,
                subtitle: l10n.settings_current_language_label,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => LanguageSelectorDialog(
                      currentLocale: currentLocale,
                      onLocaleSelected: (newLocale) {
                        CozyFeelsApp.setLocale(context, newLocale);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              ListenableBuilder(
                listenable: ThemeController.instance,
                builder: (context, _) {
                  return _buildOption(
                    icon: AppAssets.featureIcons['Palette']!,
                    title: l10n.settings_theme_title,
                    subtitle: ThemeController.instance.currentPalette
                        .getLocalizedName(l10n),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ThemeSelectorDialog(),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 8),

              _buildOption(
                icon: AppAssets.featureIcons['Notifications']!,
                title: l10n.settings_notifications_title,
                subtitle: l10n.settings_notifications_subtitle,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const NotificationsManagerDialog(),
                  );
                },
              ),

              const SizedBox(height: 8),

              _buildOption(
                icon: AppAssets.featureIcons['Upload']!,
                title: l10n.settings_backup_center_title,
                subtitle: l10n.settings_backup_center_subtitle,
                onTap: () {
                  Navigator.pop(context);
                  onOpenBackupCenter();
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
      {required String icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      leading: SvgPicture.asset(icon,
          width: 28,
          colorFilter:
              ColorFilter.mode(AppColors.rosaFuerte, BlendMode.srcIn)),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textoOscuro.withValues(alpha: 0.6))),
    );
  }
}
