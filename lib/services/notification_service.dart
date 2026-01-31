import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions (Android 13+)
  static Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if permissions are granted
  static Future<bool> arePermissionsGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to appropriate screen based on payload
    print('Notification tapped: ${response.payload}');
  }

  /// Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      _getNotificationDetails(channel),
      payload: payload,
    );
  }

  /// Show weather alert
  static Future<void> showWeatherAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '☁️ $title',
      body: body,
      payload: payload,
      channel: NotificationChannel.weather,
    );
  }

  /// Show irrigation reminder
  static Future<void> showIrrigationReminder({
    required String cropName,
    required String amount,
    String? payload,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '💧 Irrigation Reminder',
      body: '$cropName needs irrigation today ($amount)',
      payload: payload,
      channel: NotificationChannel.irrigation,
    );
  }

  /// Show fertilization reminder
  static Future<void> showFertilizationReminder({
    required String cropName,
    required String fertilizer,
    required String quantity,
    String? payload,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🌱 Fertilization Due',
      body: '$cropName: Apply $fertilizer ($quantity)',
      payload: payload,
      channel: NotificationChannel.fertilization,
    );
  }

  /// Schedule daily notification
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      _getNotificationDetails(channel),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Schedule periodic notification (every 6 hours)
  static Future<void> schedulePeriodicWeatherUpdate() async {
    // Note: For true 6-hour intervals, we'll use workmanager
    // This schedules daily weather updates
    await scheduleDailyNotification(
      id: 1001,
      title: '☁️ Weather Update',
      body: 'Check today\'s weather forecast',
      hour: 7,
      minute: 0,
      channel: NotificationChannel.weather,
    );
  }

  /// Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Get notification details based on channel
  static NotificationDetails _getNotificationDetails(
      NotificationChannel channel) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Get next instance of specific time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}

/// Notification channels enum
enum NotificationChannel {
  general('general', 'General', 'General notifications'),
  weather('weather', 'Weather', 'Weather alerts and forecasts'),
  irrigation('irrigation', 'Irrigation', 'Irrigation reminders'),
  fertilization('fertilization', 'Fertilization', 'Fertilization reminders'),
  crops('crops', 'Crops', 'Crop management alerts');

  final String id;
  final String name;
  final String description;

  const NotificationChannel(this.id, this.name, this.description);
}
