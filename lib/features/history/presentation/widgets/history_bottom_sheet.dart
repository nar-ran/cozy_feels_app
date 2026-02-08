import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/history_entry.dart';

class HistoryBottomSheet extends StatelessWidget {
  final List<HistoryEntry> entries;

  const HistoryBottomSheet({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10))
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: StrokeText(text: 'History', fontSize: 45, color: AppColors.rosaFuerte, strokeColor: AppColors.textoOscuro),
              ),
              Expanded(
                child: entries.isEmpty
                    ? const Center(child: Text("No entries yet...", style: TextStyle(fontFamily: 'Dongle', fontSize: 24)))
                    : ListView.builder(
                  controller: scrollController,
                  itemCount: entries.length,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final formattedDate = DateFormat('MMMM dd, yyyy').format(entry.date);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna del Timeline (Icono + Línea)
                        Column(
                          children: [
                            // CORRECCIÓN: Usamos SvgPicture en lugar de Icon
                            SvgPicture.asset(
                              entry.emojiPath,
                              width: 35,
                              height: 35,
                              colorFilter: const ColorFilter.mode(AppColors.textoOscuro, BlendMode.srcIn),
                            ),
                            if (index != entries.length - 1)
                              Container(
                                  width: 2,
                                  height: 50,
                                  color: AppColors.textoOscuro.withOpacity(0.5)
                              ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  formattedDate,
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textoOscuro.withOpacity(0.7),
                                      height: 1.0
                                  )
                              ),
                              Text(
                                  entry.message,
                                  style: const TextStyle(fontSize: 22, color: AppColors.textoOscuro, height: 1.0)
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}