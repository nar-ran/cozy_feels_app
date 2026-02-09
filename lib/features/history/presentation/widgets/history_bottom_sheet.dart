import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/history_entry.dart';

class HistoryBottomSheet extends StatelessWidget {
  final List<HistoryEntry> entries;
  final Function(int index, HistoryEntry entry) onEdit;

  const HistoryBottomSheet({
    super.key,
    required this.entries,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final double emojiSize =
        ((MediaQuery.of(context).size.width - 130) / 7) - 8;

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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: StrokeText(
                        text: 'History',
                        fontSize: 45,
                        color: AppColors.rosaFuerte,
                        strokeColor: AppColors.textoOscuro,
                      ),
                    ),
                  ],
                ),
              ),
              if (entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No entries yet...",
                      style: TextStyle(
                          color: AppColors.textoOscuro,
                          fontFamily: 'Dongle',
                          fontSize: 24),
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
                        final formattedDate =
                            DateFormat('MMMM dd, yyyy').format(entry.date);

                        return GestureDetector(
                          onTap: () => onEdit(index, entry),
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      entry.emojiPath,
                                      width: emojiSize,
                                      height: emojiSize,
                                      colorFilter: const ColorFilter.mode(
                                          AppColors.textoOscuro,
                                          BlendMode.srcIn),
                                    ),
                                    if (index != entries.length - 1)
                                      Container(
                                        width: 2,
                                        height: 50,
                                        color: AppColors.textoOscuro
                                            .withOpacity(0.5),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textoOscuro,
                                            height: 1.0),
                                      ),
                                      Text(
                                        entry.message,
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: AppColors.textoOscuro
                                                .withOpacity(0.7),
                                            height: 1.0),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
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
