import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class NotificationsService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channelWeekly = AndroidNotificationChannel(
      'reminisce_weekly',
      'Weekly Digest',
      description: 'Your weekly storage cleaning summary',
      importance: Importance.high,
    );

    const AndroidNotificationChannel channelNudge = AndroidNotificationChannel(
      'reminisce_nudge',
      'Group Nudge',
      description: 'Alerts when a group exceeds storage limits',
      importance: Importance.high,
    );

    const AndroidNotificationChannel channelCelebration =
        AndroidNotificationChannel(
          'reminisce_celebration',
          'Post-clean Celebration',
          description: 'Celebrate your storage cleaning wins',
          importance: Importance.low,
        );

    final plugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (plugin != null) {
      await plugin.createNotificationChannel(channelWeekly);
      await plugin.createNotificationChannel(channelNudge);
      await plugin.createNotificationChannel(channelCelebration);
    }
  }

  Future<void> scheduleWeeklyDigest() async {
    await Workmanager().registerPeriodicTask(
      'reminisce_weekly_digest',
      'weekly_digest_task',
      frequency: const Duration(days: 7),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }

  Future<void> sendGroupNudge(String groupName, double mb) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminisce_nudge',
          'Group Nudge',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _notificationsPlugin.show(
      1,
      'Heavy Group Alert',
      '$groupName has ${mb.toStringAsFixed(1)}MB of uncleaned files. Clean now?',
      details,
    );
  }

  Future<void> sendCelebration(int files, double mb) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminisce_celebration',
          'Post-clean Celebration',
          importance: Importance.low,
          priority: Priority.low,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _notificationsPlugin.show(
      2,
      'Great Job!',
      'You just freed ${mb.toStringAsFixed(1)}MB! $files files deleted.',
      details,
    );
  }
}
