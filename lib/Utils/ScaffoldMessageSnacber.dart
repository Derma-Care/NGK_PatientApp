import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

class ScaffoldMessageSnackbar {
  ScaffoldMessageSnackbar(
      BuildContext context, SnackbarType type, String message);

  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    String subTitle = '',
    String actionLabel = "X",
    int durationInSeconds = 3,
    String serviceName = '',
    SnackbarPosition position = SnackbarPosition.bottom,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = mainColor;
        icon = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = mainColor;
        icon = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = mainColor;
        icon = Icons.warning;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars(); // ✅ FIX

    EdgeInsetsGeometry margin = position == SnackbarPosition.top
        ? const EdgeInsets.only(top: 80, left: 16, right: 16)
        : const EdgeInsets.only(bottom: 80, left: 16, right: 16);

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: margin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    subTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: Duration(seconds: durationInSeconds), // ✅ auto close

        // action: actionLabel.isEmpty
        //     ? null
        //     : SnackBarAction(
        //         label: actionLabel,
        //         textColor: Colors.white,
        //         onPressed: () {
        //           messenger.hideCurrentSnackBar(); // close immediately
        //         },
        //       ),
      ),
    );
    Future.delayed(Duration(seconds: durationInSeconds), () {
      if (context.mounted) {
        messenger.hideCurrentSnackBar();
      }
    });
  }
}

// ✅ Enum for snackbar types
enum SnackbarType { success, error, warning }

// ✅ Enum for snackbar position
enum SnackbarPosition { top, bottom }
