import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:cutomer_app/Help/Numbers.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  whatsUpChat(); // Call your WhatsApp chat function
                },
                child: const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              const Text("WhatsApp"),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: emailSupport, // your phone function
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      const Color.fromARGB(255, 134, 92, 96), // circle color
                  child: Image.asset(
                    'assets/gmail.png',
                    width: 34,
                    height: 34,
                    // optional tint (remove if you want original colors)
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Email"),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  customerCare(); // Call your Contact Us function
                },
                child: const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color.fromARGB(255, 110, 174, 216),
                  child: Icon(FontAwesomeIcons.phone,
                      color:
                          mainColor), // Use your main color for the phone icon
                ),
              ),
              const SizedBox(height: 8),
              const Text("Call"),
            ],
          ),
        ],
      ),
    );
  }
}
