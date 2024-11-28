import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qilowatt/main.dart';
import 'package:qilowatt/screens/home/home.dart';
import 'package:qilowatt/screens/home/home_controller.dart';

class NotificationService {
  static Future<void> initNotifications() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    await AwesomeNotifications().initialize("resource://drawable/ic_launcher", [
      NotificationChannel(
          channelGroupKey: "high_importance_channel",
          channelKey: "high_importance_channel",
          channelName: "HIN",
          channelDescription: "High importance notification channel")
    ], channelGroups: [
      NotificationChannelGroup(
          channelGroupKey: "high_importance_channel",
          channelGroupName: "High importance channel group")
    ]);

    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);

    bool isAllowedToSendNotifications =
        await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowedToSendNotifications) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) => buildNotificationWithActions(message));
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    MyApp.navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) {
        String? redirectUrl = receivedAction.buttonKeyPressed.isNotEmpty
            ? receivedAction.buttonKeyPressed
            : receivedAction.payload?['onclick'];

        return Home(
          redirectUrl: redirectUrl,
        );
      }),
    );
  }

  static void buildNotificationWithActions(RemoteMessage message) {
    Map<String, dynamic> data = message.data;

    List<Map<String, dynamic>> actionsList = data["actions"] != null
        ? List<Map<String, dynamic>>.from(jsonDecode(data["actions"]))
        : [];

    List<NotificationActionButton> listOfButtons = actionsList
        .map((e) => NotificationActionButton(
            key: e['url'] ?? baseUri,
            label: e['title'] ?? "ERROR",
            actionType: ActionType.Default))
        .toList();

    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(100000),
          channelKey: 'high_importance_channel',
          actionType: ActionType.Default,
          color: data["color"] != null ? Color(int.parse(data["color"])) : null,
          title: data["title"],
          body: data["body"],
          payload: {'onclick': data['onclick']},
          wakeUpScreen: true,
        ),
        actionButtons: listOfButtons);
  }
}
