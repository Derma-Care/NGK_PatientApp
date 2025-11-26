import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:flutter/material.dart';

class ProfileModalCard extends StatelessWidget {
  final CustomerProfileModel profile;

  const ProfileModalCard({super.key, required this.profile});

  String safe(dynamic value) {
    if (value == null) return "-";
    if (value is String && value.trim().isEmpty) return "-";
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 55,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Customer Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _info("Customer ID", safe(profile.customerId)),
            _info("Full Name", safe(profile.fullName)),
            _info("Mobile", safe(profile.mobile)),
            _info("Email", safe(profile.email)),
            _info("City", safe(profile.city)),
            _info("DOB", safe(profile.dob)),
            _info("Clinic Name", safe(profile.clinicName)),
            _info("Clinic City Area", safe(profile.clinicCityArea)),
            _info("Last Visit", safe(profile.dateOfLastVisit)),
            _info("Service Type", profile.serviceType?.join(", ") ?? "-"),
            _info("Blood Group", safe(profile.blood)),
            _info("Registration Code", safe(profile.registrationCode)),
            _info("Referred By", safe(profile.referBy)),
            _info("Aadhar Number", safe(profile.aadharNumber)),
            _info("Address", safe(profile.address)),

            _info("Code Verified",
                profile.registrationCodeVerified ? "Yes" : "No"),
            _info("Registration Done",
                profile.registrationCompleted ? "Yes" : "No"),
            _info("Spin Wheel Completed",
                profile.spinWheelCompleted ? "Yes" : "No"),
            _info("Profile Completed",
                profile.userProfileCompleted ? "Yes" : "No"),

            const SizedBox(height: 15),

            // Prescription image view
            if (profile.prescription != null)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: Image.memory(
                        Uri.parse(profile.prescription!).data!.contentAsBytes(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "View Prescription",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}
