import 'package:cutomer_app/NGK/ClinicManagement/ClinicControllerLocation.dart';
import 'package:cutomer_app/NGK/ClinicManagement/clinic_slot_controller.dart';
import 'package:cutomer_app/NGK/Contoller/customer_controller.dart';
import 'package:cutomer_app/NGK/Contoller/referral_wallet_controller.dart';
import 'package:cutomer_app/NGK/Packges/PackageController.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureController.dart';
import 'package:cutomer_app/Notification/NotificationController.dart';
import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:cutomer_app/PushNotification/PushNotification.dart';
import 'package:cutomer_app/Routes/Navigation.dart';
import 'package:cutomer_app/Screens/splashScreen.dart';

import 'package:cutomer_app/TreatmentAndServices/SubserviceController.dart';
import 'package:cutomer_app/Widget/ControllerInitializer.dart';
import 'package:cutomer_app/Widget/TimerController.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'APIs/FetchServices.dart';

import 'Controller/CustomerController.dart';
import 'Dashboard/DashBoardController.dart';

import 'NetworkCheck/NetworkService.dart';

import 'SigninSignUp/BiometricAuthScreen.dart';
import 'SigninSignUp/LoginScreen.dart';
import 'TreatmentAndServices/ServiceSelectionController.dart';
import 'Utils/Constant.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_tts/flutter_tts.dart';

// ✅ Global Instances
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final FlutterTts flutterTts = FlutterTts();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initializeControllers();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // ✅ Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  // ✅ Android notification channel settings
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // ✅ Updated callback for v12+
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print('[🔔] Notification tapped: ${response.payload}');
      // Handle navigation if needed
      if (Get.currentRoute != '/NotificationScreen') {
        await Get.to(() => NotificationScreen());
      }
    },
  );

  // ✅ Configure TTS
  await flutterTts.setLanguage('en-US');
  await flutterTts.setSpeechRate(0.4);
  await flutterTts.setPitch(1.0);

  // ✅ Your service/controller initialization
  NetworkService().initialize();

  Get.put(Dashboardcontroller());
  Get.put(Serviceselectioncontroller());

  Get.put(NotificationController());
  Get.put(ServiceFetcher());

  Get.put(SubServiceController());
  Get.put(SelectedServicesController());

  Get.put(PackageController());
  Get.put(Procedurecontroller());
  Get.put(CustomerGetController(), permanent: true);
  Get.put(ReferralWalletController(), permanent: true);
  Get.put(TimerController(), permanent: true);
  Get.put(ClinicControllerLocation(), permanent: true);
  Get.put(ClinicSlotController(), permanent: true);

  // ✅ FCM Notification tap handling
  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  final notificationController = Get.put(NotificationController());
  await NotificationService.instance.init();
  // FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //   notificationController.handleNotification(message);
  // });

  // if (initialMessage != null) {
  //   notificationController.handleNotification(initialMessage);
  // }
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // ✅ Check login state
  final prefs = await SharedPreferences.getInstance();
  final isFirstLoginDone = prefs.getBool('isFirstLoginDone') ?? false;
  final biometricEnabled = prefs.getBool('isAuthenticated') ?? false;

  runApp(MyApp(
    isFirstLoginDone: isFirstLoginDone,
    biometricEnabled: biometricEnabled,
    initialMessage: initialMessage,
  ));
}

class MyApp extends StatelessWidget {
  final bool isFirstLoginDone;
  final bool biometricEnabled;
  final RemoteMessage? initialMessage;

  const MyApp({
    super.key,
    required this.isFirstLoginDone,
    this.initialMessage,
    required this.biometricEnabled,
  });

  @override
  Widget build(BuildContext context) {
    // Choose initial screen
    Widget homeScreen;

    homeScreen = SplashScreen(); // Always start splash

    return GetMaterialApp(
      title: 'Derma Care',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: homeScreen,
      scaffoldMessengerKey: rootScaffoldMessengerKey, // ✅ ADD THIS
      // home: SkinCareConsentFormScreen(),
      // SkinCareConsentFormScreen
      onGenerateRoute: onGenerateRoute,
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      fontFamily: 'LeagueSpartan',
      colorScheme: ColorScheme.fromSeed(seedColor: mainColor),
      primaryColor: mainColor,
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF4C3C7D),
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
    );
  }
}
