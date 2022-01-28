import 'dart:async';

import 'package:analog_clock_flutter/ui/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationService{
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService(){
    return _notificationService;
  }

  NotificationService._internal();

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //initialize notification
  Future<void> init(BuildContext context)async {
    //android init setting
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    //IOS init setting
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,requestBadgePermission: false,requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload)async{
        await Navigator.push(context, MaterialPageRoute(builder: (_)=>DetailScreen(
          hour: int.parse(payload!.split(':')[0]),
          minutes: int.parse(payload.split(':')[1]),
        )));
      }
    );

    // request permission IOS
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,badge: true,sound: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS,);
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    //init flutter local notification
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload){
      selectNotification(payload,context);
    });
  }

  //when user click notification
  void selectNotification(String? payload,BuildContext context) async {
    print('notification payload: $payload');
    if (payload != null) {
      await Navigator.push(context, MaterialPageRoute(builder: (_)=>DetailScreen(
        hour: int.parse(payload.split(':')[0]),
        minutes: int.parse(payload.split(':')[1]),
      )));
    }
  }

  //show notification
  Future<void> showNotification(TimeOfDay selectedTime)async{
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('1', 'alarm', channelDescription: 'android alarm description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Wake Up!',
    );

    int hour = selectedTime.hour;
    int minute = selectedTime.minute;
    final now = DateTime.now();
    final time = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute,);

    await _flutterLocalNotificationsPlugin.zonedSchedule(1, 'Alarm', "you've set alarm at $hour:$minute", time, NotificationDetails(
      android: androidPlatformChannelSpecifics,iOS: IOSNotificationDetails(
    )), uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,matchDateTimeComponents: DateTimeComponents.time,payload:'$hour:$minute',);
  }
}