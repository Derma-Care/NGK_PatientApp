import 'package:flutter/material.dart';

Widget filterButton(String title, dynamic controller) {
  return ValueListenableBuilder(
    valueListenable: controller.selectedFilter,
    builder: (context, selected, _) {
      bool active = selected == title;

      return Padding(
        padding: const EdgeInsets.only(
          right: 5,
        ),
        child: GestureDetector(
          onTap: () => controller.applyFilter(title),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: active ? Colors.pink : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : Colors.pink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    },
  );
}
