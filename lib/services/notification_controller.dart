import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChanngelsProperties {
  static String notificationsChannelKey = "RunRouteNotification";
  static String notificationsChannelName = "RunRoute";
  static String notificationsChannelDescription =
      "RunRoute channel to warn users of when they have reached the desired time and distance for that session";

  static String foregroundServiceChannelKey = "RunRouteFGS";
  static String foregroundServiceChannelName = "RunRoute Foreground Service";
  static String foregroundServiceChannelDescription =
      "RunRoute channel to keep the session active even when the app is closed or minimized";
}

const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId:
          NotificationChanngelsProperties.foregroundServiceChannelKey,
      initialNotificationTitle: 'Session OnGoing',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onBackground,
      autoStart: false,
    ),
  );
}

Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  service.on("stopService").listen((event) {
    service.stopSelf();
  });

  service.on("update").listen((event) async {
    String content = "updating";
    if (event != null) {
      content = event["content"];
    }

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'Session OnGoing',
          content,
          NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationChanngelsProperties.foregroundServiceChannelKey,
              NotificationChanngelsProperties.foregroundServiceChannelName,
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
}

@pragma("vm:entry-point")
Future<bool> onBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}
