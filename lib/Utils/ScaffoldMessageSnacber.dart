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
    String actionLabel = "OK",
    int durationInSeconds = 5,
    String serviceName = '',
    String? imagePath,
    double imageSize = 32,
    SnackbarPosition position =
        SnackbarPosition.bottom, // ✅ new optional position
  }) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData icon;

    // Define styles based on snackbar type
    switch (type) {
      case SnackbarType.success:
        backgroundColor = mainColor;
        textColor = Colors.white;
        iconColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = mainColor;
        textColor = Colors.white;
        iconColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = mainColor;
        textColor = Colors.white;
        iconColor = Colors.white;
        icon = Icons.warning;
        break;
    }

    // ✅ Adjust margin based on position
    EdgeInsetsGeometry margin;
    if (position == SnackbarPosition.top) {
      margin = const EdgeInsets.only(top: 80, left: 16, right: 16);
    } else {
      margin = const EdgeInsets.only(bottom: 80, left: 16, right: 16);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: margin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (serviceName.isNotEmpty)
                    Text(
                      serviceName,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  if (subTitle.isNotEmpty)
                    Text(
                      subTitle,
                      style: TextStyle(
                          color: textColor.withOpacity(0.8), fontSize: 13),
                    ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: Duration(seconds: durationInSeconds),
      ),
    );
  }
}

// ✅ Enum for snackbar types
enum SnackbarType { success, error, warning }

// ✅ Enum for snackbar position
enum SnackbarPosition { top, bottom }
