import 'package:cozy_feels_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezoneSelectorDialog extends StatelessWidget {
  final String selectedTimezone;
  final Function(String) onSelect;

  const TimezoneSelectorDialog({
    super.key,
    required this.selectedTimezone,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    final allLocations = tz.timeZoneDatabase.locations.keys.toList();
    final Map<String, String> simplifiedZones = {};

    for (var id in allLocations) {
      final location = tz.getLocation(id);
      final now = tz.TZDateTime.now(location);
      final offset = now.timeZoneOffset.toString();

      if (!simplifiedZones.containsKey(offset)) {
        simplifiedZones[offset] = id;
      }
    }

    final sortedIds = simplifiedZones.values.toList();
    sortedIds.sort((a, b) {
      final offsetA = tz.TZDateTime.now(tz.getLocation(a)).timeZoneOffset;
      final offsetB = tz.TZDateTime.now(tz.getLocation(b)).timeZoneOffset;
      return offsetA.compareTo(offsetB);
    });

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
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortedIds.length,
                itemBuilder: (context, index) {
                  final String locationId = sortedIds[index];
                  final isSelected = selectedTimezone == locationId;

                  final zoneLocation = tz.getLocation(locationId);
                  final zoneNow = tz.TZDateTime.now(zoneLocation);

                  final offsetDuration = zoneNow.timeZoneOffset;
                  final hours =
                      offsetDuration.inHours.abs().toString().padLeft(2, '0');
                  final minutes = (offsetDuration.inMinutes.abs() % 60)
                      .toString()
                      .padLeft(2, '0');
                  final sign = offsetDuration.isNegative ? '-' : '+';
                  final utcTitle = "UTC $sign$hours:$minutes";

                  final relatedCities = allLocations
                      .where((id) {
                        final loc = tz.getLocation(id);
                        return tz.TZDateTime.now(loc).timeZoneOffset ==
                            offsetDuration;
                      })
                      .take(3)
                      .map((id) => id.split('/').last.replaceAll('_', ' '))
                      .join(', ');

                  final timeString = DateFormat('hh:mm a').format(zoneNow);

                  return GestureDetector(
                    onTap: () => onSelect(locationId),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.rosaFuerte
                            : AppColors.naranjaPiel,
                        borderRadius: BorderRadius.circular(25),
                        border:
                            Border.all(color: AppColors.rosaFuerte, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  utcTitle,
                                  style: TextStyle(
                                    fontSize: width * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textoOscuro,
                                  ),
                                ),
                                Text(
                                  relatedCities,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: width * 0.03,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.textoOscuro
                                            .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeString,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textoOscuro,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
