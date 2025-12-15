import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnableBiometricScreen extends StatefulWidget {
  final String mobileNumber;
  final String? fullname;
  final String? deviceId;

  const EnableBiometricScreen({
    super.key,
    required this.mobileNumber,
    this.fullname,
    this.deviceId,
  });

  @override
  _EnableBiometricScreenState createState() => _EnableBiometricScreenState();
}

class _EnableBiometricScreenState extends State<EnableBiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  /// --------------------- ENABLE BIOMETRICS ----------------------
  Future<void> _authenticate() async {
    try {
      final bool canCheck = await auth.canCheckBiometrics;

      if (!canCheck) {
        ScaffoldMessageSnackbar.show(
          context: context,
          message: "Biometric sensor not available",
          type: SnackbarType.error,
        );
        return;
      }

      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstLoginDone', true);
        await prefs.setBool('isAuthenticated', true);

        ScaffoldMessageSnackbar.show(
          context: context,
          message: "Biometric login enabled",
          type: SnackbarType.success,
        );

        // Navigate to home
        Get.offAll(() => BottomNavController(
              mobileNumber: widget.mobileNumber,
              index: 0,
            ));
      }
    } catch (e) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Biometric authentication failed: $e",
        type: SnackbarType.error,
      );
    }
  }

  /// --------------------- SKIP BIOMETRIC ----------------------
  Future<void> _skipBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLoginDone', true);
    await prefs.setBool('isAuthenticated', false);

    Get.offAll(() => BottomNavController(
          mobileNumber: widget.mobileNumber,
          index: 0,
        ));
  }

  /// --------------------- UI ----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 30),

            // Header section
            Column(
              children: [
                Text(
                  "Enable Biometrics",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Secure your account with biometric login",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Fingerprint GIF
                Image.asset(
                  'assets/fin.gif',
                  height: 130,
                ),
              ],
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                children: [
                  // Skip Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: mainColor),
                      ),
                      onPressed: _skipBiometrics,
                      child: Text("Skip", style: TextStyle(color: mainColor)),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Allow Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                      ),
                      onPressed: _authenticate,
                      child: const Text(
                        "Allow",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
