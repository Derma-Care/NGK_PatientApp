import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerController extends GetxController {
  final Map<String, RxInt> remainingSecondsMap = {};
  final Map<String, Timer> activeTimers = {}; // ✅ handle multiple screens
  final RxBool isTimeUp = false.obs;
  void startTimer({
    required String doctorId,
    required String slot,
    required BuildContext context, // for navigation
    int durationSeconds = 120, // default = 2 min
  }) {
    final key = "$doctorId-$slot";
    isTimeUp.value = false;
    // cancel any previous timer for same slot
    activeTimers[key]?.cancel();

    // set initial time
    remainingSecondsMap[key] = durationSeconds.obs;

    // start timer
    activeTimers[key] =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingSecondsMap[key]!.value > 0) {
        remainingSecondsMap[key]!.value--;
      } else {
        timer.cancel();
        await _handleTimeUp(context);
        isTimeUp.value = true;
      }
    });
  }

  Future<void> _handleTimeUp(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('customerName') ?? "User";
    final mobileNumber = prefs.getString('mobileNumber') ?? "";

    if (context.mounted) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message:
            "⏰ Time is up! $username, your session has ended. Navigating to home.",
        type: SnackbarType.warning,
        durationInSeconds: 3,
      );

      // wait for snackbar to show
      await Future.delayed(const Duration(seconds: 3));

      // navigate safely
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => BottomNavController(
            mobileNumber: mobileNumber,
            username: username,
            index: 0,
          ),
        ),
        (route) => false,
      );
    }
  }

  RxInt getRemainingSecondsRx(String doctorId, String slot) {
    final key = "$doctorId-$slot";
    if (!remainingSecondsMap.containsKey(key)) {
      remainingSecondsMap[key] = 0.obs;
    }
    return remainingSecondsMap[key]!;
  }

  void stopTimer(String doctorId, String slot) {
    final key = "$doctorId-$slot";
    remainingSecondsMap[key]?.value = 0;
    activeTimers[key]?.cancel();
    isTimeUp.value = false;
  }

  @override
  void onClose() {
    // cancel all active timers when controller is destroyed
    for (var timer in activeTimers.values) {
      timer.cancel();
    }
    activeTimers.clear();
    super.onClose();
  }
}
