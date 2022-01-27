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
  Timer? _timer;

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //initialize notification
  Future<void> init(BuildContext context)async {
    //android init setting
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    //IOS init setting
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,requestBadgePermission: false,requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload){
        print('IOS Payload ===> $payload',);
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
      final _alarmTime = TimeOfDay(hour: int.parse(payload!.split(':')[0]), minute: int.parse(payload.split(':')[1]));
      selectNotification(payload,context);
    });
  }

  // method when user click notification
  void selectNotification(String? payload,BuildContext context) async {
    if (payload != null) {
      print('notification payload: $payload');
      await Navigator.push(context, MaterialPageRoute(builder: (_)=>DetailScreen(
        hour: int.parse(payload.split(':')[0]),
        minutes: int.parse(payload.split(':')[1]),
      )));
      _timer?.cancel();
    }
  }

  // method for show notification
  Future<void> showNotification(TimeOfDay selectedTime)async{
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('1', 'alarm', channelDescription: 'android alarm description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Wake Up!',
    );

    int hour = selectedTime.hour;
    int minute = selectedTime.minute;
    final now = DateTime.now();
    final time = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute,);

    await _flutterLocalNotificationsPlugin.zonedSchedule(1, 'Alarm', "you've set alarm at $hour:$minute", time, NotificationDetails(
      android: androidPlatformChannelSpecifics), uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,matchDateTimeComponents: DateTimeComponents.time,payload:'$hour:$minute',);
  }
}