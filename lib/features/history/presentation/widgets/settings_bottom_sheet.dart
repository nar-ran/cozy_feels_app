import 'package:cozy_feels_app/features/history/presentation/widgets/language_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/main.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class SettingsBottomSheet extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;

  const SettingsBottomSheet(
      {super.key, required this.onExport, required this.onImport});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: AppColors.naranjaPiel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: AppColors.fondoSoft,
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 25),

          _buildOption(
            icon: AppAssets.featureIcons['Upload']!,
            title: l10n.settings_export_title,
            subtitle: l10n.settings_export_subtitle,
            onTap: onExport,
          ),
          const SizedBox(height: 15),
          _buildOption(
            icon: AppAssets.featureIcons['Restore']!,
            title: l10n.settings_import_title,
            subtitle: l10n.settings_import_subtitle,
            onTap: onImport,
          ),
          const SizedBox(height: 15),

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
          
          const SizedBox(height: 30),
        ],
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
      leading: SvgPicture.asset(icon,
          width: 30,
          colorFilter:
              const ColorFilter.mode(AppColors.rosaFuerte, BlendMode.srcIn)),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textoOscuro.withOpacity(0.6))),
    );
  }
}
