import 'package:awesome_notifications/awesome_notifications.dart';

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

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {}
}
