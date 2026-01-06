import 'dart:convert';

import 'package:cutomer_app/BottomNavigation/Appoinments/PostBooingModel.dart';
import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';

import 'package:cutomer_app/Loading/FullScreeenLoader.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/BookingRequestModel.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/BookingService.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:cutomer_app/NGK/Screens/BookingSuccessScreen.dart';
import 'package:cutomer_app/Toasters/Toaster.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:cutomer_app/Widget/GobelTimer.dart';
import 'package:cutomer_app/Widget/TimerController.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../PatientsDetails/PatientModel.dart';

import '../Utils/ScaffoldMessageSnacber.dart';

class RazorpaySubscription extends StatefulWidget {
  final VoidCallback? onPaymentInitiated;
  final BookingRequestModel bookingData;
  final double amount;
  final String mobileNumber;

  final BuildContext context;

  const RazorpaySubscription({
    super.key,
    required this.onPaymentInitiated,
    required this.bookingData,
    required this.amount,
    required this.context,
    required this.mobileNumber,
  });

  @override
  State<RazorpaySubscription> createState() => _RazorpaySubscriptionState();
}

class _RazorpaySubscriptionState extends State<RazorpaySubscription> {
  var _razorpay = Razorpay();
  Map<String, dynamic> options = {};
  bool _isLoading = true; // To manage loading state
  late String? paymentId;

  @override
  void initState() {
    super.initState();
    print("PayAmount to be customer ${widget.amount}");
    // handleBookAppoint();
    // Payment options
    options = {
      'key': 'rzp_test_sor33NEn9vHr3Q',
      'amount': (widget.amount * 100), // Amount in paise

      'name': "Neeha's GlowKart",
      'description': 'Service Charges',
      'prefill': {
        'contact': '7842259803',
        'email': 'prashanthr803@gmail.com',
      },
    };
    final timerController = Get.find<TimerController>();

// Listen for timeout
    ever(timerController.isTimeUp, (isTimeUp) {
      if (isTimeUp == true) {
        try {
          _razorpay.clear(); // Close Razorpay if open
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => BottomNavController(
                      mobileNumber: widget.mobileNumber,
                      // username: "User",
                      index: 0,
                    )),
            (route) => false,
          );
        } catch (e) {
          debugPrint("Error closing Razorpay on timeout: $e");
        }
      }
    });

    // Razorpay event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Start payment process
    if (widget.onPaymentInitiated != null) {
      widget.onPaymentInitiated!();
      Future.delayed(Duration.zero, () {
        _razorpay.open(options);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Payment Gateway",
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Your main content here
                Center(
                  child: Text(
                    "Payment Details Here",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    // 1️⃣ Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FullscreenLoader(
        message: "Processing Booking...",
        logoPath: "assets/ic_launcher.png",
      ),
    );

    try {
      // 2️⃣ Create booking after payment success
      final BookingModel bookingResponse =
          await BookingService.createBooking(widget.bookingData);

      if (!mounted) return;

      // 3️⃣ Close loader
      Navigator.of(context).pop();

      // 4️⃣ Navigate to success screen with REAL DATA
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(
            clinicName: bookingResponse.clinicName,
            serviceName: bookingResponse.serviceName ?? "",
            appointmentDate: bookingResponse.appointmentDate,
            clinicAddress: bookingResponse.clinicAddress,
            mobile: bookingResponse.mobileNumber,
            bookingId: bookingResponse.bookingId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // 5️⃣ Close loader
      Navigator.of(context).pop();

      // 6️⃣ Show error
      showSnackbar(
        "Booking Failed",
        e.toString(),
        "error",
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isLoading = false;
    });

    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      // ScaffoldMessageSnackbar.show(
      //   context: context, // Use the new context from builder
      //   message: "Payment Cancelled by User",
      //   type: SnackbarType.warning,
      //   durationInSeconds: 5,
      // );
      // Fluttertoast.showToast(msg: "Payment Cancelled by User");
      showSuccessToast(msg: "Payment Cancelled by User");
      Navigator.pop(context);

      // (route) => false,

      print("User cancelled the payment.");
    } else {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Payment Failed: ${response.message}",
        type: SnackbarType.error,
      );
      print("Payment Failed: ${response.message}");
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessageSnackbar.show(
      context: context,
      message: "External Wallet Selected: ${response.walletName}",
      type: SnackbarType.success,
    );
    print("External Wallet Selected: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    if (Get.isRegistered<TimerController>()) {
      Get.delete<TimerController>();
    }
    super.dispose();
  }
}
