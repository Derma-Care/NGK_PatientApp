import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

LinearGradient getMembershipGradient(String membership) {
  switch (membership) {
    case "Silver":
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFBFC9D1), // light silver
          Color(0xFF8E9EAB), // dark silver
        ],
      );

    case "Gold":
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFE082), // soft gold
          Color(0xFFFFB300), // deep gold
        ],
      );

    case "Platinum":
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF7F7FD5), // royal violet
          Color(0xFF86A8E7),
          Color(0xFF91EAE4),
        ],
      );

    default: // Basic
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          mainColor,
          secondaryColor,
        ],
      );
  }
}
