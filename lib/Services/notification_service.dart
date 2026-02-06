import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:cutomer_app/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

// void showInAppBanner({
//   required String title,
//   required String body,
// }) {
//   final messenger = rootScaffoldMessengerKey.currentState;
//   if (messenger == null) return;

//   messenger.hideCurrentMaterialBanner();

//   messenger.showMaterialBanner(
//     MaterialBanner(
//       backgroundColor: Colors.black87,
//       content: Text(
//         "$title\n$body",
//         style: const TextStyle(color: Colors.white),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             messenger.hideCurrentMaterialBanner();
//             Get.to(() => NotificationScreen());
//           },
//           child: const Text("OPEN", style: TextStyle(color: Colors.pink)),
//         ),
//       ],
//     ),
//   );

//   Future.delayed(const Duration(seconds: 4), () {
//     messenger.hideCurrentMaterialBanner();
//   });
// }
void showTopNotificationModal({
  required String title,
  required String body,
}) {
  final navigator = rootNavigatorKey.currentState;
  if (navigator == null) return;

  final overlay = navigator.overlay;
  if (overlay == null) return;

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      top: MediaQuery.of(overlay.context).padding.top + 10,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            overlayEntry.remove();
            Get.to(() => NotificationScreen());
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                  Image.asset(
  'assets/ic_launcher.png',
  width: 24,
  height: 24,
  color: Colors.pinkAccent,
),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 4), () {
    overlayEntry.remove();
  });
}
