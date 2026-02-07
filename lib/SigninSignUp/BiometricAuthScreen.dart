import 'dart:convert';
import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/NGK/service/customer_service.dart';
import 'package:cutomer_app/Utils/LocationService.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../SigninSignUp/LoginScreen.dart';

class BiometricAuthScreen extends StatefulWidget {
  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkAndAuthenticate();
  }

  // -------------------------------------------------------------------
  // CHECK BIOMETRICS
  // -------------------------------------------------------------------
  Future<void> _checkAndAuthenticate() async {
    setState(() => _loading = true);

    try {
      final canCheck = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();

      if (!canCheck || !supported) {
        _goToLogin();
        return;
      }

      await _authenticateBiometric();
    } catch (e) {
      debugPrint("Biometric check error: $e");
      _goToLogin();
    }
  }

  // -------------------------------------------------------------------
  // AUTHENTICATE USER
  // -------------------------------------------------------------------
  Future<void> _authenticateBiometric() async {
    try {
      final isAuth = await auth.authenticate(
        localizedReason: "Authenticate to continue",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!isAuth) {
        _goToLogin();
        return;
      }

      _afterBiometricSuccess();
    } catch (e) {
      debugPrint("Biometric error: $e");
      _goToLogin();
    }
  }

  // -------------------------------------------------------------------
  // AFTER BIOMETRIC SUCCESS → VALIDATE USER
  // -------------------------------------------------------------------
  Future<void> _afterBiometricSuccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString('mobileNumber');

      if (mobile == null) {
        _goToLogin();
        return;
      }

      // 🔍 FETCH USER DATA
      final customer = await CustomerService.getCustomer(mobile);
      await prefs.setString('customer_full_name', customer?.fullName ?? "");
      await prefs.setString('customer_Id', customer?.customerId ?? "");
      if (customer == null) {
        // ❌ No customer exists → Login again
        _goToLogin();
        return;
      }

      // 🌍 Fetch Location (Optional)
      try {
        LocationService.showFetchingLocationDialog(context);
        await LocationService.fetchAndStoreLocation();
      } catch (_) {}

      // ✅ SUCCESS → Proceed to Home
      Get.offAll(() => BottomNavController(
            mobileNumber: mobile,
            index: 0,
          ));
    } catch (e) {
      debugPrint("Error after biometric: $e");
      _goToLogin();
    }
  }

  // -------------------------------------------------------------------
  // GO TO LOGIN SCREEN
  // -------------------------------------------------------------------
  void _goToLogin() {
    Get.offAll(() => const Loginscreen());
  }

  // -------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Center(
        child: _loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SpinKitFadingCircle(
                    color: Colors.white,
                    size: 40.0,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Authenticating...",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fingerprint, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    "Biometric Authentication Required",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _authenticateBiometric,
                    icon: const Icon(Icons.lock_open),
                    label: const Text("Authenticate"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: mainColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _goToLogin,
                    child: const Text(
                      "Login with OTP",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
