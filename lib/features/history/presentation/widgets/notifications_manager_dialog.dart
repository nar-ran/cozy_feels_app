import 'package:cozy_feels_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/reminder.dart';
import 'package:cozy_feels_app/features/history/domain/services/reminder_storage_service.dart';
import 'package:cozy_feels_app/features/history/domain/services/notification_service.dart';

class NotificationsManagerDialog extends StatefulWidget {
  const NotificationsManagerDialog({Key? key}) : super(key: key);

  @override
  State<NotificationsManagerDialog> createState() =>
      _NotificationsManagerDialogState();
}

class _NotificationsManagerDialogState
    extends State<NotificationsManagerDialog> {
  final ReminderStorageService _storageService = ReminderStorageService();
  final NotificationService _notificationService = NotificationService();

  bool _isFormExpanded = false;

  int _selectedHour = 20;
  int _selectedMinute = 0;
  final List<bool> _selectedDays = [true, true, true, true, true, true, true];
  final List<String> _daysLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  List<Reminder> _remindersList = [];

  @override
  void initState() {
    super.initState();
    _loadSavedReminders();
  }

  Future<void> _loadSavedReminders() async {
    final savedReminders = await _storageService.loadReminders();
    setState(() {
      _remindersList = savedReminders;
    });
  }

  String _formatTime12Hours(int hour, int minute) {
    final int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final String amPm = hour >= 12 ? 'PM' : 'AM';
    final String minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $amPm';
  }

  Future<void> _pickTime() async {
    final TimeOfDay initialTime =
        TimeOfDay(hour: _selectedHour, minute: _selectedMinute);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale(
              'en', 'US'),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });
    }
  }

  void _addReminderAction() async {
    if (!_selectedDays.contains(true)) return;

    final i10n = AppLocalizations.of(context)!;

    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hour: _selectedHour,
      minute: _selectedMinute,
      days: List<bool>.from(_selectedDays),
      isActive: true,
    );

    setState(() {
      _remindersList.add(newReminder);
      _isFormExpanded = false;
      _selectedHour = 20;
      _selectedMinute = 0;
      for (int i = 0; i < _selectedDays.length; i++) _selectedDays[i] = true;
    });

    await _storageService.saveReminders(_remindersList);
    await _notificationService.scheduleReminder(
      newReminder,
      i10n.notifications_push_title,
      i10n.notifications_push_body,
    );
  }

  void _deleteReminderAction(int index) async {
    final reminderToRemove = _remindersList[index];
    await _notificationService.cancelReminder(reminderToRemove.id);

    setState(() {
      _remindersList.removeAt(index);
    });
    await _storageService.saveReminders(_remindersList);
  }

  String _getDaysSummary(List<bool> days) {
    List<String> activeDays = [];
    for (int i = 0; i < days.length; i++) {
      if (days[i]) activeDays.add(_daysLabels[i]);
    }
    return activeDays.isEmpty ? "" : activeDays.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    final String formattedTime =
        _formatTime12Hours(_selectedHour, _selectedMinute);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
          horizontal: 20), 
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
            maxWidth: 400), 
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
                text: i10n.notifications_title,
                fontSize: width * 0.08,
                color: AppColors.rosaFuerte,
                strokeColor: AppColors.textoOscuro,
              ),

              const SizedBox(height: 25),

              // --- BARRA CONTROLADORA DE APERTURA ---
              GestureDetector(
                onTap: () => setState(() => _isFormExpanded = !_isFormExpanded),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.naranjaPiel,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.rosaFuerte, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add_alarm,
                              color: AppColors.textoOscuro, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            i10n.notifications_new_reminder,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoOscuro,
                                fontSize: width * 0.045),
                          ),
                        ],
                      ),
                      Icon(
                        _isFormExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textoOscuro,
                      ),
                    ],
                  ),
                ),
              ),

              // --- ZONA DE CREACIÓN ---
              if (_isFormExpanded) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(i10n.notifications_what_time,
                              style: TextStyle(
                                  color: AppColors.textoOscuro,
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.05)),
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.naranjaPiel,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: AppColors.rosaFuerte, width: 1.5),
                              ),
                              child: Text(
                                formattedTime,
                                style: TextStyle(
                                    color: AppColors.textoOscuro,
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.045),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // --- GRILLA DE DÍAS ---
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(7, (index) {
                          final isSelected = _selectedDays[index];
                          return GestureDetector(
                            onTap: () => setState(() =>
                                _selectedDays[index] = !_selectedDays[index]),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.naranjaPiel
                                    : Colors.transparent,
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.rosaFuerte, width: 1.2)
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _daysLabels[index],
                                style: TextStyle(
                                  color: AppColors.textoOscuro,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  fontSize: width * 0.045,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 25),

                      // --- BOTÓN CONFIRMAR ---
                      GestureDetector(
                        onTap: _addReminderAction,
                        child: Text(
                          i10n.common_confirm,
                          style: TextStyle(
                            fontSize: width * 0.07,
                            color: AppColors.rosaFuerte,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 25),
              const Divider(color: AppColors.textoOscuro, thickness: 1.5),
              const SizedBox(height: 15),

              // --- LISTA DE RECORDATORIOS ---
              _remindersList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        i10n.notifications_no_reminders,
                        style: TextStyle(
                            color: AppColors.textoOscuro.withOpacity(0.5),
                            fontSize: width * 0.04,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _remindersList.length,
                      itemBuilder: (context, index) {
                        final reminder = _remindersList[index];
                        final String timeString =
                            _formatTime12Hours(reminder.hour, reminder.minute);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.naranjaPiel,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: AppColors.rosaFuerte, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        fontSize: width * 0.055,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textoOscuro,
                                      ),
                                    ),
                                    Text(
                                      _getDaysSummary(reminder.days),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: AppColors.textoOscuro
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _deleteReminderAction(index),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.textoOscuro,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
