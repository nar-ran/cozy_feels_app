import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cozy_feels_app/features/history/domain/entities/reminder.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // --- INICIALIZAR NOTIFICACIONES ---
  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(settings: initializationSettings);

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // --- PROGRAMAR NOTIFICACIÓN REPETITIVA POR DÍAS ---
  Future<void> scheduleReminder(Reminder reminder) async {
    await cancelReminder(reminder.id);
    if (!reminder.isActive) return;

    String deviceTimezone;
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      deviceTimezone = timezoneInfo.identifier;
    } catch (e) {
      deviceTimezone = 'America/New_York';
    }

    final tz.Location deviceLocation = tz.getLocation(deviceTimezone);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'cozy_reminders_channel',
      'Recordatorios Diarios',
      channelDescription:
          'Canal para las notificaciones de bienestar de Cozy Feels',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    for (int i = 0; i < reminder.days.length; i++) {
      if (reminder.days[i]) {
        int dayOfWeek = i + 1;
        int notificationId = (reminder.id.hashCode + dayOfWeek).toSigned(32);

        try {
          final scheduledDate = _nextInstanceOfDayAndTime(
              reminder.hour, reminder.minute, dayOfWeek, deviceLocation);
          
          debugPrint('Scheduling notification ID $notificationId for day $dayOfWeek at $scheduledDate (device timezone is $deviceTimezone)');

          await _notificationsPlugin.zonedSchedule(
            id: notificationId,
            title: '¿Cómo te sientes hoy? 🌟',
            body: 'Es momento de tomar un respiro y registrar tus emociones.',
            scheduledDate: scheduledDate,
            notificationDetails: platformDetails,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (e) {
          debugPrint('Error scheduling notification for day $dayOfWeek: $e');
        }
      }
    }
  }

  // --- CANCELAR NOTIFICACIÓN ---
  Future<void> cancelReminder(String reminderId) async {
    for (int dayOfWeek = 1; dayOfWeek <= 7; dayOfWeek++) {
      await _notificationsPlugin.cancel(id: (reminderId.hashCode + dayOfWeek).toSigned(32));
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int hour, int minute, int dayOfWeek, tz.Location location) {
    final tz.TZDateTime now = tz.TZDateTime.now(location);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // --- PROBAR NOTIFICACIÓN INMEDIATA ---
  Future<void> showInstantNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'cozy_reminders_channel',
      'Recordatorios Diarios',
      channelDescription:
          'Canal para las notificaciones de bienestar de Cozy Feels',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    await _notificationsPlugin.show(
      id: 999,
      title: '¡Funciona perfectamente! 🌟',
      body: 'El motor de notificaciones básico está activo en tu celular.',
      notificationDetails: platformDetails,
    );
  }
}
