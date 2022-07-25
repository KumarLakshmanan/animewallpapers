import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  int id = 10;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/notification_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {});
  }

  Future showNotify({
    required Map<String, dynamic> body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id++,
      body["title"] ?? "New Notification Arrived",
      body["desc"] ?? body["message"] ?? "",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'textId',
          'textName',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          channelDescription: 'Text Notification',
        ),
      ),
      payload: body['module'],
    );
  }
}
