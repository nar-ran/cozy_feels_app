import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ImportPreviewDialog extends StatelessWidget {
  final List<HistoryEntry> importedEntries;
  final List<HistoryEntry> currentEntries;

  const ImportPreviewDialog({
    super.key,
    required this.importedEntries,
    required this.currentEntries,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final newEntries = importedEntries.where((imported) {
      return !currentEntries.any((existing) =>
          existing.date.year == imported.date.year &&
          existing.date.month == imported.date.month &&
          existing.date.day == imported.date.day);
    }).toList();

    final int duplicates = importedEntries.length - newEntries.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.fondoSoft,
          borderRadius: BorderRadius.circular(25),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StrokeText(
                text: "Import Preview",
                fontSize: width * 0.08,
                color: AppColors.rosaFuerte,
                strokeColor: AppColors.textoOscuro,
              ),
              const SizedBox(height: 25),

              Text(
                newEntries.isEmpty
                    ? "Everything is up to date!"
                    : "Found ${newEntries.length} new entries:",
                style: TextStyle(
                  color: AppColors.textoOscuro,
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              if (newEntries.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: newEntries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = newEntries[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.naranjaPiel,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.rosaFuerte.withOpacity(0.5),
                              width: 1),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: entry.emojiPath.contains('.svg')
                                  ? SvgPicture.asset(
                                      entry.emojiPath,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.textoOscuro,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : Center(
                                      child: Text(entry.emojiPath,
                                          style:
                                              const TextStyle(fontSize: 20))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.message.isEmpty
                                        ? "No words..."
                                        : entry.message,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textoOscuro,
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMMM dd, yyyy')
                                        .format(entry.date),
                                    style: TextStyle(
                                      color: AppColors.textoOscuro
                                          .withOpacity(0.6),
                                      fontSize: width * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              if (duplicates > 0)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.rosaFuerte.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "$duplicates days already exist in your history and will be skipped.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.rosaFuerte,
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, null),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                        fontSize: width * 0.05,
                        color: AppColors.textoOscuro.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (newEntries.isNotEmpty)
                    GestureDetector(
                      onTap: () => Navigator.pop(context, newEntries),
                      child: Text(
                        "IMPORT",
                        style: TextStyle(
                          fontSize: width * 0.06,
                          color: AppColors.rosaFuerte,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
