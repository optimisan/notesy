import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notesy/models/note_model.dart';
import 'package:notesy/services/notifications_service.dart';
import 'package:notesy/services/add_note.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TimePicker extends StatefulWidget {
  TimePicker(this.note, this.uid);
  final Note? note;
  final String? uid;
  @override
  _TimePickerState createState() => _TimePickerState(note, uid);
}

class _TimePickerState extends State<TimePicker> {
  _TimePickerState(this.note, this.uid);
  Note? note;
  String? uid;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool timeEdited = false;

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    return picked;
    // if (picked != null && picked != selectedDate)
    //   setState(() {
    //     print("sel");
    //     selectedDate = picked;
    //   });
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedS = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      // builder: (BuildContext context, Widget child) {
      //   return MediaQuery(
      //     data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
      //     child: child,
      //   );
      // },
    );
    return pickedS;
  }

  Future<void> showDateTimePicker(BuildContext context) async {
    late var checkDate, checkTime;
    this.selectedTime = checkTime = TimeOfDay.now();
    this.selectedDate = checkDate = DateTime.now();
    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.zero,
              scrollable: true,
              titleTextStyle: const TextStyle(color: const Color(0xFFFEFEFE), fontSize: 20.0),
              title: Text("Add reminder"),
              content: DefaultTextStyle(
                style: TextStyle(color: const Color(0xFFFEFEFE)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      // ListTile(
                      //   onTap: () {},
                      //   leading: Icon(Icons.add),
                      //   title: Text("Tomorrow"),
                      // ),
                      ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)),
                        onTap: () async {
                          this.timeEdited = false;
                          this.selectedDate = DateTime.now();
                          final date = await _selectDate(context);
                          setState(() {
                            if (date != null && date.day != DateTime.now().day) {
                              this.selectedDate = date;
                              this.timeEdited = true;
                            }
                          });
                        },
                        // leading: Icon(Icons.add),
                        trailing: Icon(Icons.calendar_today_rounded),
                        title: Text(
                          this.selectedDate == checkDate
                              ? "Choose Date"
                              : "${DateFormat.EEEE().format(this.selectedDate)}, ${this.selectedDate.day}",
                          style: TextStyle(color: const Color(0xFFFEFEFE)),
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          this.timeEdited = false;
                          final s = await _selectTime(context);
                          setState(() {
                            if (s != null && s != TimeOfDay.now()) {
                              this.selectedTime = s;
                              this.timeEdited = true;
                            }
                          });
                        },
                        trailing: Icon(Icons.access_time),
                        title: Text(
                          this.selectedTime == checkTime
                              ? "Choose Time"
                              : "${this.selectedTime.hour} : ${this.selectedTime.minute}",
                          style: const TextStyle(color: const Color(0xFFFEFEFE)),
                        ),
                      ),
                      SizedBox(height: 20),
                      // if (this.selectedDate == checkDate)
                      //   Center(
                      //       child: Container(
                      //           padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
                      //           color: Colors.green,
                      //           child: Text(
                      //             "${this.selectedDate.millisecondsSinceEpoch}",
                      //             style: const TextStyle(
                      //               color: const Color(0xFFFEFEFE),
                      //               fontSize: 20.0,
                      //             ),
                      //           ))),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                if (this.timeEdited)
                  Container(
                    height: 38.0,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: TextButton(
                      child: Text("Save",
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      onPressed: () async {
                        if (this.selectedDate != DateTime.now() ||
                            this.selectedTime != TimeOfDay.now()) {
                          print("Creating notification...");
                          try {
                            await NotificationHelper.handleReminderNotification(
                                dateTime: DateTime(
                                  this.selectedDate.year,
                                  this.selectedDate.month,
                                  this.selectedDate.day,
                                  this.selectedTime.hour,
                                  this.selectedTime.minute,
                                ),
                                note: this.note);
                            if (uid != null) await this.note?.addReminder(uid!);
                          } catch (e) {
                            print(e.toString());
                          } finally {
                            print("Done");
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: "Notification created",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        }
                      },
                    ),
                  )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: this.note!.reminderExists
          ? Icon(
              Icons.alarm_rounded,
              color: Colors.green.shade400,
            )
          : Icon(Icons.alarm_add_rounded),
      onPressed: () async {
        await showDateTimePicker(context);
      },
    );
  }
}
