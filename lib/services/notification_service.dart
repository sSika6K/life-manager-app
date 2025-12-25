import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> scheduleTaskReminder(int id, String title, DateTime deadline) async {
    // Notification 1 jour avant
    final oneDayBefore = deadline.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        id * 10 + 1,
        'Rappel de tâche',
        'N\'oublie pas : $title (échéance demain)',
        tz.TZDateTime.from(oneDayBefore, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Rappels de tâches',
            channelDescription: 'Notifications pour les tâches à venir',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // Notification le jour même (9h du matin)
    final sameDayMorning = DateTime(deadline.year, deadline.month, deadline.day, 9, 0);
    if (sameDayMorning.isAfter(DateTime.now()) && deadline.isAfter(sameDayMorning)) {
      await _notifications.zonedSchedule(
        id * 10 + 2,
        'Tâche à faire aujourd\'hui',
        title,
        tz.TZDateTime.from(sameDayMorning, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Rappels de tâches',
            channelDescription: 'Notifications pour les tâches à venir',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelTaskReminder(int id) async {
    await _notifications.cancel(id * 10 + 1);
    await _notifications.cancel(id * 10 + 2);
  }

  Future<void> showDailySummary(List<String> incompleteTasks) async {
    if (incompleteTasks.isEmpty) return;

    final tasksText = incompleteTasks.take(3).join('\n• ');

    await _notifications.show(
      999,
      'Tâches incomplètes',
      'N\'oublie pas :\n• $tasksText',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Résumé quotidien',
          channelDescription: 'Résumé quotidien des tâches',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
