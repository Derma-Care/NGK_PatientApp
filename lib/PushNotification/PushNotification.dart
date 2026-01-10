// lib/services/notification_service.dart
import 'dart:io';

import 'package:cutomer_app/Notification/LocalNotification.dart';
import 'package:cutomer_app/Notification/NotificationController.dart';
import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:cutomer_app/Notification/notification_intent.dart';
import 'package:cutomer_app/Services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _flutterLocal = FlutterLocalNotificationsPlugin();

/// ---------- BACKGROUND / TERMINATED ------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔕 Background message: ${message.data}");
}

/// ---------- PUBLIC API -------------------------
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final NotificationController controller = Get.find<NotificationController>();

  Future<void> init() async {
    await _requestPermission();
    _setupListeners();
    _printFCMToken();
  }

  void _setupListeners() async {
    /// 🟢 FOREGROUND → IN-APP BANNER
    FirebaseMessaging.onMessage.listen((message) {
      controller.handleNotification(message);

      showInAppBanner(
        title: message.notification?.title ?? "Notification",
        body: message.notification?.body ?? "",
      );
    });

    /// 🟡 BACKGROUND → TAP
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationIntent.openedFromNotification = true;
      controller.handleNotification(message);
    });

    /// 🔴 TERMINATED → APP OPEN
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      NotificationIntent.openedFromNotification = true;
      controller.handleNotification(message);
    }
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _printFCMToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('📲 FCM TOKEN: $token');
  }
}

/// ---------- LOW‑LEVEL HELPER --------------------
class _NotificationHelper {
  static bool _initDone = false;

  /* Create 3 Android channels that match your RN version */
  static Future<void> _ensureInitialized() async {
    if (_initDone) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _flutterLocal.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Channels: general, appointment, critical
    await _createChannel(
      id: 'general',
      name: 'General',
      importance: Importance.defaultImportance,
    );
    await _createChannel(
      id: 'appointment',
      name: 'Appointments',
      importance: Importance.high,
    );
    await _createChannel(
      id: 'critical',
      name: 'Critical',
      importance: Importance.max,
    );

    _initDone = true;
  }

  static Future<void> _createChannel({
    required String id,
    required String name,
    required Importance importance,
    String? sound,
  }) async {
    final androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
      description: '$name notifications',
      importance: importance,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
      playSound: sound != null,
    );

    await _flutterLocal
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  /* === Public helpers === */
  static Future<void> requestUserPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true, // mirrors AuthorizationStatus.PROVISIONAL
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('✅ Notification permission granted');
    }
  }
}
