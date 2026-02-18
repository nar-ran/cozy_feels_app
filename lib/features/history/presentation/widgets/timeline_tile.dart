import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TimelineTile extends StatelessWidget {
  final String date;
  final String? note;
  final String iconPath;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.date,
    this.note,
    required this.iconPath,
    this.isLast = false
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Icon(Icons.sentiment_satisfied, color: AppColors.textoOscuro, size: 30),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.textoOscuro,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                  if (note != null)
                    Text(note!, style: const TextStyle(fontSize: 18, color: AppColors.textoOscuro, height: 1.1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}