import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification notification) async {
    print('Notification Created: ${notification.title}');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification notification) async {
    print('Notification Displayed: ${notification.title}');
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedNotification notification) async {
    print('Notification Dismissed');
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction action) async {
    print('Notification Clicked with payload: ${action.payload}');
  }
}