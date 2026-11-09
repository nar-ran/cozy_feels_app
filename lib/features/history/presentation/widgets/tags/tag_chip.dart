import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/entities/app_tag.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class TagChip extends StatelessWidget {
  final String tagId;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isCompact;

  const TagChip({
    super.key,
    required this.tagId,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final icon = AppTag.getIconForTag(tagId);
    final label = AppTag.getLabelForTag(tagId, l10n);

    if (isCompact) {
      // Modo lectura compacto para las tarjetas de historial y calendario
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.naranjaPiel.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.rosaFuerte.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: AppColors.textoOscuro.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 18,
                height: 1.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textoOscuro,
              ),
            ),
          ],
        ),
      );
    }

    // Modo interactivo (Píldora seleccionable)
    final backgroundColor = isSelected
        ? AppColors.rosaFuerte
        : AppColors.naranjaPiel.withValues(alpha: 0.85);

    final foregroundColor = isSelected ? Colors.white : AppColors.textoOscuro;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.rosaFuerte
                : AppColors.rosaFuerte.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.rosaFuerte.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: foregroundColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 22,
                height: 1.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
