import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:cutomer_app/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

void showInAppBanner({
  required String title,
  required String body,
}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;

  messenger.hideCurrentMaterialBanner();

  messenger.showMaterialBanner(
    MaterialBanner(
      backgroundColor: Colors.black87,
      content: Text(
        "$title\n$body",
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () {
            messenger.hideCurrentMaterialBanner();
            Get.to(() => NotificationScreen());
          },
          child: const Text("OPEN", style: TextStyle(color: Colors.pink)),
        ),
      ],
    ),
  );

  Future.delayed(const Duration(seconds: 4), () {
    messenger.hideCurrentMaterialBanner();
  });
}
