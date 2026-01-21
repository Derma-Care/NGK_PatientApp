import 'package:flutter/material.dart';

class WhatsAppPreviewCard extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.check_box,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "NGK Health",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Text(
                    "Now",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// TITLE
              const Text(
                "✅ Appointment Confirmed",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 6),

              /// MESSAGE BODY
              const Text(
                "Hi Prashanth 👋\n"
                "Your appointment has been successfully booked.\n\n"
                "🏥 Clinic: Apollo Clinic\n"
                "🩺 Service: General Consultation\n"
                "📅 Date: 20 Jan 2026\n"
                "⏰ Time: 10:30 AM\n"
                "📍 Address: Hyderabad\n\n"
                "Please arrive 10 minutes early.",
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              /// ACTION
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text("OPEN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
