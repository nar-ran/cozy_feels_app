import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/calendar/calendar_day_cell.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/calendar/calendar_day_detail_sheet.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/calendar/calendar_month_header.dart';
import 'package:cozy_feels_app/features/history/presentation/widgets/calendar/month_year_picker_dialog.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  final List<HistoryEntry> entries;
  final String selectedTimezone;
  final Function(int index, HistoryEntry entry) onEdit;
  final VoidCallback onOpenSettings;
  final VoidCallback onTimezoneTap;

  const CalendarScreen({
    super.key,
    required this.entries,
    required this.selectedTimezone,
    required this.onEdit,
    required this.onOpenSettings,
    required this.onTimezoneTap,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final location = tz.getLocation(widget.selectedTimezone);
    final now = tz.TZDateTime.now(location);
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (context) => MonthYearPickerDialog(
        initialDate: _focusedMonth,
        entries: widget.entries,
        selectedTimezone: widget.selectedTimezone,
        onMonthSelected: (newMonth) {
          setState(() {
            _focusedMonth = newMonth;
          });
        },
      ),
    );
  }

  void _onDayTapped(DateTime date, HistoryEntry? entry) {
    if (entry == null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: AppColors.textoOscuro.withValues(alpha: 0.25),
        constraints: const BoxConstraints(minWidth: double.infinity),
        builder: (context) => CalendarDayDetailSheet(
          date: date,
          entry: null,
          emojis: AppAssets.sentimentEmojis.entries.toList(),
        ),
      );
      return;
    }

    final entryIndex = widget.entries.indexOf(entry);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textoOscuro.withValues(alpha: 0.25),
      constraints: const BoxConstraints(minWidth: double.infinity),
      builder: (context) => CalendarDayDetailSheet(
        date: date,
        entry: entry,
        emojis: AppAssets.sentimentEmojis.entries.toList(),
        onSaveEditedEntry: entryIndex != -1
            ? (updatedEntry) {
                widget.onEdit(entryIndex, updatedEntry);
                setState(() {});
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final location = tz.getLocation(widget.selectedTimezone);
    final now = tz.TZDateTime.now(location);

    final String locale = Localizations.localeOf(context).languageCode;
    var formattedDate = DateFormat('EEEE, MMM d', locale).format(now);

    if (formattedDate.isNotEmpty) {
      formattedDate =
          formattedDate[0].toUpperCase() + formattedDate.substring(1);
    }

    formattedDate = formattedDate.split(' ').map((word) {
      if (word.length > 1) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');

    // Pre-index entries for instant O(1) lookup
    final Map<String, HistoryEntry> entryMap = {};
    for (final entry in widget.entries) {
      final tzDate = tz.TZDateTime.from(entry.date, location);
      final key = '${tzDate.year}-${tzDate.month}-${tzDate.day}';
      entryMap[key] = entry;
    }

    // Calculate calendar grid dates
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekdayOffset = firstDayOfMonth.weekday - 1; // Mon = 0, Sun = 6
    final totalCells = ((startWeekdayOffset + daysInMonth) / 7).ceil() * 7;

    return Scaffold(
      backgroundColor: AppColors.fondoSoft,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onOpenSettings,
                    child: SvgPicture.asset(
                      AppAssets.featureIcons['Settings']!,
                      width: 28,
                      colorFilter: ColorFilter.mode(
                          AppColors.textoOscuro, BlendMode.srcIn),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTimezoneTap,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: AppColors.rosaFuerte,
                          fontSize: width * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Title
            StrokeText(
              text: l10n.calendar_title,
              fontSize: width * 0.15,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.strokeColor,
            ),

            // Month Navigation & Weekday labels
            CalendarMonthHeader(
              currentMonth: _focusedMonth,
              onPreviousMonth: _previousMonth,
              onNextMonth: _nextMonth,
              onMonthTitleTap: _showMonthYearPicker,
            ),

            // Calendar Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: totalCells,
                  itemBuilder: (context, index) {
                    final dayOffset = index - startWeekdayOffset;
                    final date = DateTime(_focusedMonth.year, _focusedMonth.month, 1 + dayOffset);

                    final isCurrentMonth = date.month == _focusedMonth.month;
                    final isToday = date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;

                    final key = '${date.year}-${date.month}-${date.day}';
                    final entry = entryMap[key];

                    return CalendarDayCell(
                      dayNumber: date.day,
                      isCurrentMonth: isCurrentMonth,
                      isToday: isToday,
                      entry: isCurrentMonth ? entry : null,
                      onTap: () => _onDayTapped(date, isCurrentMonth ? entry : null),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
