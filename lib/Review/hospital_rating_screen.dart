import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';

import 'package:flutter/material.dart';

import '../Utils/ShowSnackBar.dart';

class HospitalRatingScreen extends StatefulWidget {
  final String hospitalName;
  final String hospitalLogo; // logo image (png/svg/network)

  const HospitalRatingScreen({
    super.key,
    required this.hospitalName,
    required this.hospitalLogo,
  });

  @override
  State<HospitalRatingScreen> createState() => _HospitalRatingScreenState();
}

class _HospitalRatingScreenState extends State<HospitalRatingScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool isSubmitting = false;

  void _submit() async {
    if (_rating == 0) {
      ScaffoldMessageSnackbar.show(
          context: context,
          message: "Please select a rating",
          type: SnackbarType.warning,
          position: SnackbarPosition.top);

      // _showMsg("Please select a rating");
      return;
    }
    // if (_commentController.text.trim().isEmpty) {
    //   _showMsg("Please enter your comment");
    //   return;
    // }

    setState(() => isSubmitting = true);

    // TODO: API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => isSubmitting = false);
    Navigator.pop(context);
    Navigator.pop(context);

    showSnackbar(
      "Feedback Submitted",
      "Thank you for sharing your experience. Your feedback helps us improve our services.",
      "success",
    );
    // ScaffoldMessageSnackbar.show(
    //   context: context,
    //   message: "Thank you for your feedback!",
    //   type: SnackbarType.success,
    // );
    // _showMsg("Thank you for your feedback!");
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
                  child: Image.network(
                    widget.hospitalLogo,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                // Hospital Name
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
