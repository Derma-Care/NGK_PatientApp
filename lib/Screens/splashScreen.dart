 

import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:cutomer_app/Notification/notification_intent.dart';
import 'package:cutomer_app/SigninSignUp/BiometricAuthScreen.dart';
import 'package:cutomer_app/SigninSignUp/BiometricPermissionScreen.dart';
import 'package:cutomer_app/SigninSignUp/LoginScreen.dart';
 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _moveUpAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _moveUpAnimation = Tween<double>(begin: 0, end: -200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(seconds: 2), () => _controller.forward());

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isFirstLoginDone = prefs.getBool('isFirstLoginDone') ?? false;

    final bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    final String? mobileNumber = prefs.getString('mobileNumber');

    bool biometricAvailable = false;

    try {
      final canCheck = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();

      if (canCheck && supported) {
        final biometrics = await auth.getAvailableBiometrics();
        biometricAvailable = biometrics.isNotEmpty;
      }
    } catch (e) {
      print("Biometric check error: $e");
    }

    if (!mounted) return;

    // ---------------- FINAL NAVIGATION LOGIC ---------------- //

    // 🔴 USER LOGGED OUT → LOGIN SCREEN
    if (mobileNumber == null) {
      Get.offAll(() => const Loginscreen());
      return;
    }

    // 🟡 FIRST LOGIN → ASK BIOMETRIC PERMISSION
    if (!isFirstLoginDone && biometricAvailable) {
      Get.offAll(() => EnableBiometricScreen(
            mobileNumber: mobileNumber,
          ));
      return;
    }
    // ✅ AUTHENTICATED
    if (NotificationIntent.openedFromNotification) {
      NotificationIntent.openedFromNotification = false;
      Get.offAll(() => NotificationScreen());
    } else {
      Get.offAll(() => BottomNavController(
            mobileNumber: mobileNumber,
            index: 0,
          ));
    }

    // 🟢 BIOMETRIC ENABLED → AUTH SCREEN
    if (isAuthenticated && biometricAvailable) {
      Get.offAll(() => BiometricAuthScreen());
      return;
    }

    // 🔵 BIOMETRIC DISABLED → DIRECT HOME
    Get.offAll(() => Loginscreen());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------- UI ---------------------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _moveUpAnimation.value),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- 3D IMAGE ----------
              Stack(
                children: [
                  // Shadow Layer
                  Transform.translate(
                    offset: const Offset(3, 3),
                    child: Image.asset(
                      'assets/ic_launcher.png',
                      height: 150,
                      colorBlendMode: BlendMode.srcATop,
                    ),
                  ),
                   
                ],
              ),

              const SizedBox(height: 20),

             
            ],
          ),
        ),
      ),
    );
  }
}
