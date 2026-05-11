import 'package:cozy_feels_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezoneSelectorDialog extends StatelessWidget {
  final Map<String, String> timezoneMap;
  final String selectedTimezone;
  final Function(String) onSelect;

  const TimezoneSelectorDialog({
    super.key,
    required this.timezoneMap,
    required this.selectedTimezone,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColors.fondoSoft,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StrokeText(
              text: i10n.timezone_title,
              fontSize: width * 0.08,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.textoOscuro,
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: timezoneMap.entries.map((entry) {
                    final isSelected = selectedTimezone == entry.value;
                    final zoneLocation = tz.getLocation(entry.value);
                    final zoneNow = tz.TZDateTime.now(zoneLocation);
                    final timeString = DateFormat('hh:mm a').format(zoneNow);

                    return GestureDetector(
                      onTap: () => onSelect(entry.value),
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
                              color: AppColors.rosaFuerte, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textoOscuro,
                                ),
                              ),
                            ),
                            Text(
                              timeString,
                              style: TextStyle(
                                fontSize: width * 0.035,
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.textoOscuro.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
