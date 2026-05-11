import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:intl/intl.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class HistoryBottomSheet extends StatelessWidget {
  final List<HistoryEntry> entries;
  final String selectedTimezone;
  final Function(int index, HistoryEntry entry) onEdit;

  const HistoryBottomSheet({
    super.key,
    required this.entries,
    required this.selectedTimezone,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final double emojiSize = width * 0.1;

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.naranjaPiel,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 100,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.fondoSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: StrokeText(
                        text: l10n.history_title,
                        fontSize: width * 0.12,
                        color: AppColors.rosaFuerte,
                        strokeColor: AppColors.textoOscuro,
                      ),
                    ),
                  ],
                ),
              ),
              if (entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      l10n.history_empty_state,
                      style: TextStyle(
                          color: AppColors.textoOscuro,
                          fontFamily: 'Dongle',
                          fontSize: width * 0.06),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];

                        String getFixedPath(String originalPath) {
                          if (originalPath.contains('/feelings/')) {
                            return originalPath;
                          }

                          return originalPath.replaceAll('assets/icons/svg/',
                              'assets/icons/svg/feelings/');
                        }

                        // --- ZONA HORARIA ---
                        final location = tz.getLocation(selectedTimezone);
                        final dateInZone =
                            tz.TZDateTime.from(entry.date, location);
                        var formattedDate =
                            DateFormat('MMMM dd, yyyy').format(dateInZone);

                        if (formattedDate.isNotEmpty) {
                          formattedDate = formattedDate[0].toUpperCase() +
                              formattedDate.substring(1);
                        }

                        return GestureDetector(
                          onTap: () => onEdit(index, entry),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .stretch,
                              children: [
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      getFixedPath(entry.emojiPath),
                                      width: emojiSize,
                                      height: emojiSize,
                                      colorFilter: const ColorFilter.mode(
                                          AppColors.textoOscuro,
                                          BlendMode.srcIn),
                                    ),
                                    if (index != entries.length - 1)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: AppColors.textoOscuro
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                              fontSize: width * 0.07,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textoOscuro,
                                              height:
                                                  1.2),
                                        ),
                                        Text(
                                          entry.message.isEmpty
                                              ? l10n.history_no_words
                                              : entry.message,
                                          style: TextStyle(
                                              fontSize: width * 0.055,
                                              color: AppColors.textoOscuro
                                                  .withOpacity(0.7),
                                              height: 1.1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: entries.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
        );
      },
    );
  }
}
