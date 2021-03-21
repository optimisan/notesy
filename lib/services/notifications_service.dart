import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notesy/models/note_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants.dart';

//TODO: Store all notification id's in Firebase and in the respective notes
class NotificationHelper {
  static var androidDetails = AndroidNotificationDetails(
      "channelId", "Note reminders", "Your note reminders",
      importance: Importance.high);

  static Future<dynamic>? handleReminderNotification(
      {required DateTime dateTime, required Note? note}) async {
    print(note?.hashCode.toString());
    var difference = dateTime.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    if (difference > 100) {
      var differenceDuration = Duration(milliseconds: difference);
      await showReminderNotification(
        differenceDuration: differenceDuration,
        title: note?.title,
        content: note?.content,
        id: note == null ? 0 : note.hashCode,
      );
      note?.setReminder(dateTime).then((value) => null);
    } else {
      print(difference.toString());
    }
  }

  static Future<dynamic> cancelNotification(int id) async {
    return await flutterLocalNotificationsPlugin1?.cancel(id);
  }

  static Future<dynamic> notificationSelected(String? payload) {
    // showDialog(
    //   context: context
    // )
    return Future.value(3);
  }

  static Future<dynamic>? showReminderNotification(
      {required Duration differenceDuration, String? title, String? content, int id = 0}) async {
    if (title == null && content == null) title = "A note reminder";

    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin1?.zonedSchedule(
      id,
      title,
      content,
      tz.TZDateTime.now(tz.local).add(differenceDuration),
      // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      generalNotificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: false,
    );
  }

  static Future<dynamic>? showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidDetails = AndroidNotificationDetails(
        "channelId", "Note reminders", "channelDescription",
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
