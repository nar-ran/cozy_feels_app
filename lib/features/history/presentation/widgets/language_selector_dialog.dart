import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class LanguageSelectorDialog extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) onLocaleSelected;

  const LanguageSelectorDialog({
    super.key,
    required this.currentLocale,
    required this.onLocaleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    final languages = [
      {'name': 'English', 'locale': const Locale('en'), 'flag': '🇺🇸'},
      {'name': 'Español', 'locale': const Locale('es'), 'flag': '🇪🇸'},
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.fondoSoft,
          borderRadius: BorderRadius.circular(30), 
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StrokeText(
              text: i10n.language_title,
              fontSize: width * 0.08,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.textoOscuro,
            ),
            const SizedBox(height: 20),
            Column(
              children: languages.map((lang) {
                final locale = lang['locale'] as Locale;
                final isSelected =
                    currentLocale.languageCode == locale.languageCode;

                return GestureDetector(
                  onTap: () {
                    onLocaleSelected(locale);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.rosaFuerte
                          : AppColors.naranjaPiel,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppColors.rosaFuerte,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang['name'] as String,
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textoOscuro,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
