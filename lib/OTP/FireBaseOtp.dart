import 'dart:async';
import 'dart:convert';
import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/NGK/Service/customer_service.dart';
 
import 'package:cutomer_app/SigninSignUp/BiometricPermissionScreen.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/Constant.dart';
import '../Utils/CopyRigths.dart';

import '../SigninSignUp/LoginScreen.dart';
import '../Utils/Header.dart'; // Your CommonHeader widget
import '../APIs/BaseUrl.dart'; // where your `registerUrl` is defined

class OTPLoginScreen extends StatefulWidget {
  final String mobileNumber;

  final String? deviceId;

  const OTPLoginScreen({
    super.key,
    required this.mobileNumber,
    this.deviceId,
  });

  @override
  _OTPLoginScreenState createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final TextEditingController otpController = TextEditingController();
  String verificationId = '';
  bool codeSent = false;
  bool isLoading = false;
  bool canResend = false;
  int timerSeconds = 60;
  int failedAttempts = 0;
  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    sendOTP();
    startTimer();
  }

  void startTimer() {
    canResend = false;
    timerSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${widget.mobileNumber}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Auto-verified");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  //resend otp

  Future<void> resendOtp(String mobileNumber, String deviceId) async {
    print("Resend Otpn: ${deviceId}");
    print("~ ${mobileNumber}");
    final url = Uri.parse('$registerUrl/resendOtp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mobileNumber': mobileNumber,
          'deviceId': deviceId,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print('OTP resent successfully');
        // You can show a success message
      } else {
        print('Failed to resend OTP: ${responseData['message']}');
        // Show error message from backend
      }
    } catch (e) {
      print('Error resending OTP: $e');
      // Handle network error
    }
  }

  //verfy oTP
  Future<void> verifyOTP(String otp) async {
    setState(() => isLoading = true);

    try {
      // ------------------- VERIFY OTP -------------------
      final response = await http.post(
        Uri.parse('http://3.6.119.57:9090/api/customer/verifyOtp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "mobileNumber": widget.mobileNumber,
          "otp": otp,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        ScaffoldMessageSnackbar.show(
          context: context,
          message: data['message'] ?? "Invalid OTP",
          type: SnackbarType.error,
        );
        return;
      }

      // ------------------- OTP SUCCESS -------------------
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLoginDone', true);

      final bool biometricEnabled = prefs.getBool('isAuthenticated') ?? false;

      // ------------------- CHECK CUSTOMER EXIST -------------------
      final customer = await CustomerService.getCustomer(widget.mobileNumber);

      final token = prefs.getString('fcm');

      // If customer exists
      if (customer != null) {
        if (biometricEnabled) {
          // USER ALREADY ENABLED BIOMETRIC → DIRECT LOGIN
          Get.offAll(() => BottomNavController(
                mobileNumber: widget.mobileNumber,
                index: 0,
              ));
        } else {
          // ASK USER TO ENABLE BIOMETRIC
          Get.to(() => EnableBiometricScreen(
                mobileNumber: widget.mobileNumber,
                deviceId: token,
              ));
        }
      } else {
        // New user → Go to home directly OR registration
        Get.offAll(() => BottomNavController(
              mobileNumber: widget.mobileNumber,
              index: 0,
            ));
      }

      // Success message
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Login successful",
        type: SnackbarType.success,
      );
    } catch (e) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeader(title: 'Verify Phone Number'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Image.asset('assets/ic_launcher.png', width: 120),
                SizedBox(height: 24),
                Text(
                  "Enter the OTP sent to +91-${widget.mobileNumber}",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Pinput(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  length: 6,
                  onCompleted: verifyOTP,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '00:${timerSeconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: failedAttempts >= 2
                      ? () => Get.toNamed('/gethelp')
                      : (canResend
                          ? () {
                              // sendOTP();
                              resendOtp(widget.mobileNumber, widget.deviceId!);
                              startTimer();
                            }
                          : null),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: failedAttempts >= 2
                              ? "You have made 2 unsuccessful attempts. "
                              : "Didn't receive OTP? Resend ",
                          style: TextStyle(
                            color: (canResend || failedAttempts >= 2)
                                ? Colors.red
                                : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        if (failedAttempts >= 2)
                          TextSpan(
                            text: "Get Help",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isLoading) ...[
                  SizedBox(height: 10),
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 5),
                  Text(
                    "Validating OTP...",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
                TextButton(
                  onPressed: () => Get.to(Loginscreen()),
                  child: Text(
                    'Change Mobile Number',
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Copyrights(),
              ],
            ),
          ),
        )
        // : Center(child: CircularProgressIndicator()),
        );
  }
}
