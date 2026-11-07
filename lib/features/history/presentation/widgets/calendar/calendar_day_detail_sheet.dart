import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/mood_editor_dialog.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class CalendarDayDetailSheet extends StatefulWidget {
  final DateTime date;
  final HistoryEntry? entry;
  final List<MapEntry<String, String>> emojis;
  final Function(HistoryEntry updatedEntry)? onSaveEditedEntry;

  const CalendarDayDetailSheet({
    super.key,
    required this.date,
    this.entry,
    required this.emojis,
    this.onSaveEditedEntry,
  });

  @override
  State<CalendarDayDetailSheet> createState() => _CalendarDayDetailSheetState();
}

class _CalendarDayDetailSheetState extends State<CalendarDayDetailSheet> {
  late HistoryEntry? _currentEntry;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
  }

  String _getFixedPath(String originalPath) {
    if (originalPath.contains('/feelings/')) {
      return originalPath;
    }
    return originalPath.replaceAll('assets/icons/svg/', 'assets/icons/svg/feelings/');
  }

  void _openEditDialog() {
    if (_currentEntry == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) => MoodEditorDialog(
        date: widget.date,
        initialMessage: _currentEntry!.message,
        initialEmoji: _currentEntry!.emojiPath,
        emojis: widget.emojis,
        onSave: (newMessage, newEmoji) {
          final updated = HistoryEntry(
            date: _currentEntry!.date,
            message: newMessage,
            emojiPath: newEmoji,
          );
          setState(() {
            _currentEntry = updated;
          });
          widget.onSaveEditedEntry?.call(updated);
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final width = MediaQuery.of(context).size.width;

    var formattedDate = DateFormat('EEEE, d MMMM yyyy', locale).format(widget.date);
    if (formattedDate.isNotEmpty) {
      formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
      decoration: BoxDecoration(
        color: AppColors.naranjaPiel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle bar (matching HistoryBottomSheet width 100)
            Container(
              width: 100,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.fondoSoft,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Date Header (clean, spacious, matching the rest of the app's dates)
            Text(
              formattedDate,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: width * 0.085,
                fontWeight: FontWeight.bold,
                color: AppColors.textoOscuro,
                letterSpacing: 0.8,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 14),

            if (_currentEntry != null) ...[
              // Direct Emoji without heavy inner boxes
              SvgPicture.asset(
                _getFixedPath(_currentEntry!.emojiPath),
                width: 64,
                height: 64,
                colorFilter: ColorFilter.mode(
                  AppColors.emojiColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 12),

              // Note Message directly over the cozy peach background
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _currentEntry!.message.trim().isNotEmpty
                      ? _currentEntry!.message
                      : l10n.history_no_words,
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 26,
                    fontStyle: _currentEntry!.message.trim().isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: _currentEntry!.message.trim().isEmpty
                        ? AppColors.textoOscuro.withValues(alpha: 0.6)
                        : AppColors.textoOscuro,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),

              // Cozy Edit Button matching app aesthetics (opens dialog on top without closing sheet)
              if (widget.onSaveEditedEntry != null)
                GestureDetector(
                  onTap: _openEditDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.fondoSoft,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.rosaFuerte, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color: AppColors.textoOscuro,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.calendar_edit_entry,
                          style: TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              // Clean empty state for day without entry
              const SizedBox(height: 8),
              Icon(
                Icons.spa_rounded,
                size: 42,
                color: AppColors.textoOscuro.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.calendar_no_entry_day,
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 26,
                  color: AppColors.textoOscuro.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
