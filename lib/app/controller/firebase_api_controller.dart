import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/notification_controller.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_local_controller.dart';
import '../helper/router.dart';

bool _firebaseInitialized = false;

@pragma('vm:entry-point')
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!_firebaseInitialized) {
    try {
      await Firebase.initializeApp();
      _firebaseInitialized = true;
    } catch (e) {
      debugPrint('Firebase background initialization skipped: $e');
      return;
    }
  }
  debugPrint("Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    try {
      HomeController homeController = Get.find<HomeController>();
      homeController.updateShowNotification('true');
    } catch (e) {
      debugPrint('HomeController not found: $e');
    }
    FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
    NotificationLocalController.showBigTextNotification(
        title: message.notification!.title.toString(),
        body: message.notification!.body.toString(),
        fln: fln);
  }
}

class FirebaseApiController extends GetxController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _firebaseMessaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  void _initLocalNotifications() {
    NotificationLocalController.initialize(flutterLocalNotificationsPlugin);
  }

  @pragma('vm:entry-point')
  Future<void> initNotifications() async {
    _initLocalNotifications();
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //check user login register token
    String tokenUser = prefs.getString("token") ?? "";
    if (tokenUser.isNotEmpty) {
      Future.delayed(Duration.zero, () async {
        if (isClosed) return;
        try {
          NotificationController notificationController =
              Get.find<NotificationController>();
          if (fCMToken != null) {
            notificationController.registerFCMToken(fCMToken);
          }
        } catch (e) {
          debugPrint('NotificationController not found: $e');
        }
      });
    }

    if (fCMToken != null) {
      prefs.setString(SharedPreferencesManager.keyFcmToken, fCMToken);
    }

    _onTokenRefreshSubscription =
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed');
      _registerToken(newToken);
    });

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        try {
          HomeController homeController = Get.find<HomeController>();
          homeController.updateShowNotification('true');
        } catch (e) {
          debugPrint('HomeController not found: $e');
        }
        NotificationLocalController.showBigTextNotification(
            title: message.notification!.title.toString(),
            body: message.notification!.body.toString(),
            fln: flutterLocalNotificationsPlugin);
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _onMessageOpenedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      if (data.containsKey('course_id')) {
        Get.toNamed(AppRouter.getCourseDetailRoute(),
            arguments: [data['course_id'], null]);
      } else {
        Get.toNamed(AppRouter.getNotificationRoute());
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _firebaseMessagingBackgroundHandler(message);
      }
    });
  }

  Future<void> _registerToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPreferencesManager.keyFcmToken, token);
    String tokenUser = prefs.getString("token") ?? "";
    if (tokenUser.isNotEmpty) {
      try {
        NotificationController notificationController =
            Get.find<NotificationController>();
        notificationController.registerFCMToken(token);
      } catch (e) {
        debugPrint('NotificationController not found: $e');
      }
    }
  }

  @override
  void onClose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedSubscription?.cancel();
    _onTokenRefreshSubscription?.cancel();
    super.onClose();
  }
}
