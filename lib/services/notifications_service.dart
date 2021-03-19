import 'package:flutter/animation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//TODO: Store all notification id's in Firebase and in the respective notes
class NotificationHelper {
  static Future<dynamic> notificationSelected(String? payload) {
    // showDialog(
    //   context: context
    // )
    return Future.value(3);
  }

  static Future<dynamic>? showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidDetails = AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.high);
    var generalNotificationDetails = NotificationDetails(android: androidDetails);
    // await flutterLocalNotificationsPlugin.show(0, "Task", "body", generalNotificationDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(0, "scheduled title", "body",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)), generalNotificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: false);
  }
  // final BehaviorSubject<ReminderNotification> didReceiveLocalNotificationSubject =
  //     BehaviorSubject<ReminderNotification>();
  //
  // final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();
}
