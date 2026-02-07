import 'package:flutter/material.dart';
import 'package:cutomer_app/Help/Numbers.dart';
import 'package:url_launcher/url_launcher.dart';

// Replace with your actual functions
void customerWhatsupNumber() {}
void emailID() {}
void customerNumber() {}

class HelpSupportSheet extends StatelessWidget {
  const HelpSupportSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  whatsUpChat(); // Call your WhatsApp chat function
                },
                child: const Icon(Icons.message, color: Colors.green),
              ),
              const SizedBox(height: 8),
              const Text("WhatsApp"),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  emailSupport(); // Call your email function
                },
                child: const Icon(Icons.email, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text("E-mail"),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  customerCare(); // Call your Contact Us function
                },
                child: const Icon(Icons.phone, color: Colors.orange),
              ),
              const SizedBox(height: 8),
              const Text("Contact Us"),
            ],
          ),
        ],
      ),
    );
  }
}
