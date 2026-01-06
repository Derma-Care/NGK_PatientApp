import 'dart:convert';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Utils/ShowSnackBar.dart';

class HospitalRatingScreen extends StatefulWidget {
  final String hospitalName;
  final String hospitalLogo; // logo image (png/svg/network)
  final String bookingId;
  const HospitalRatingScreen({
    super.key,
    required this.hospitalName,
    required this.hospitalLogo,
    required this.bookingId,
  });

  @override
  State<HospitalRatingScreen> createState() => _HospitalRatingScreenState();
}

class _HospitalRatingScreenState extends State<HospitalRatingScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool isSubmitting = false;

  void _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobileNumber');

    if (_rating == 0) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Please select a rating",
        type: SnackbarType.warning,
        position: SnackbarPosition.top,
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse("${wifiUrl}/booking/rate"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "bookingId": widget.bookingId, // ✅ pass bookingId via widget
          "rating": _rating,
          "review": _commentController.text.trim(), // optional
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessageSnackbar.show(
          context: context,
          message: "Thank you for your feedback!",
          subTitle: "Your feedback helps us improve our services.",
          type: SnackbarType.success,
          position: SnackbarPosition.top,
        );

        Get.offAll(() => BottomNavController(
              mobileNumber: mobile!,
              index: 1,
              appointmentTabIndex: 1,
            ));
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? "Failed to submit rating";
      }
    } catch (e) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: e.toString(),
        type: SnackbarType.error,
        position: SnackbarPosition.top,
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Rate Hospital",
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🏥 Hospital Logo (CENTER)
                Container(
                  height: 90,
                  width: 90,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.memory(
                    base64Decode(
                      widget.hospitalLogo.split(',').last,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                // Hospital Name
                Text(
                  widget.bookingId,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600),
                ),
                Text(
                  widget.hospitalName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: mainColor),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Your feedback helps us improve",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                // ⭐ Rating
                const Text(
                  "Rate your experience",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: mainColor),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      iconSize: 40,
                      onPressed: () {
                        setState(() => _rating = index + 1);
                      },
                      icon: Icon(
                        Icons.star_rounded,
                        color:
                            index < _rating ? mainColor : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // 💬 Comment box
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write your comments...",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 🚀 Submit
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isSubmitting ? null : _submit,
                    child: isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Submit Review",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
