import 'dart:convert';
import 'package:cutomer_app/Review/HospitalRatingScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ClinicModelWithLocation.dart';

class AboutClinicScreen extends StatelessWidget {
  final ClinicModelWithLocation clinic;

  const AboutClinicScreen({super.key, required this.clinic});
  void _openMap(double lat, double lng) async {
    final googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

    final uri = Uri.parse(googleMapUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Clinic"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 HEADER CARD
            _headerCard(),

            const SizedBox(height: 16),

            /// 🔹 RATING + DISTANCE
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  clinic.hospitalOverallRating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(clinic.distanceInKm),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 LINKS
            _sectionTitle("Links"),
            if (clinic.website.isNotEmpty)
              _linkTile(Icons.language, "Website", clinic.website),

            if (clinic.walkthrough != null && clinic.walkthrough!.isNotEmpty)
              _linkTile(Icons.play_circle, "Walkthrough", clinic.walkthrough!),

            _sectionTitle("Location"),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.location_on,
                color: Colors.pinkAccent,
              ),
              title: Text(
                clinic.address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.green.withOpacity(0.15),
                backgroundImage: const AssetImage(
                  'assets/map.png',
                ),
              ),
              onTap: () {
                _openMap(clinic.latitude, clinic.longitude);
              },
            ),

            /// 🔹 TIMINGS
            _sectionTitle("Timings"),
            _infoTile(
              Icons.access_time,
              "${clinic.openingTime} - ${clinic.closingTime}",
            ),

            /// 🔹 DOCTORS
            // _sectionTitle("Doctors (${clinic.doctorsList.length})"),
            _doctorsAccordion(),

            /// 🔹 SOCIAL (ONLY IF AVAILABLE)
            if (_hasSocial()) ...[
              _sectionTitle("Social"),
              if (clinic.facebookHandle?.isNotEmpty == true)
                _linkTile(
                  Icons.facebook,
                  "Facebook",
                  clinic.facebookHandle!,
                ),
              if (clinic.instagramHandle?.isNotEmpty == true)
                _linkTile(
                  Icons.camera_alt,
                  "Instagram",
                  clinic.instagramHandle!,
                ),
              if (clinic.twitterHandle?.isNotEmpty == true)
                _linkTile(
                  Icons.alternate_email,
                  "Twitter",
                  clinic.twitterHandle!,
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => HospitalRatingScreen());
                  },
                  child: const Text("Ratings & Comments"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _headerCard() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.pinkAccent.withOpacity(0.4), // 🔹 border color
          width: 1.2, // 🔹 border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LOGO
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _clinicImage(),
            ),
            const SizedBox(width: 12),

            /// DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    clinic.address,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    "City: ${clinic.city}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  if (clinic.licenseNumber?.isNotEmpty == true) ...[
                    Text(
                      "License: ${clinic.licenseNumber}",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clinicImage() {
    if (clinic.hospitalLogo.startsWith('data:image')) {
      final bytes = base64Decode(clinic.hospitalLogo.split(',').last);
      return Image.memory(bytes, width: 70, height: 70, fit: BoxFit.cover);
    }
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(Icons.local_hospital, size: 36),
    );
  }

  Widget _doctorsAccordion() {
    if (clinic.doctorsList.isEmpty) {
      return const Text("No doctors available");
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        "View Doctors (${clinic.doctorsList.length})",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      children: clinic.doctorsList.map((d) {
        return Card(
          color: Colors.white,
          elevation: 0, // 👈 flat medical style
          // margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Colors.pinkAccent.withOpacity(0.3), // 👈 border
              width: 1,
            ),
          ),
          child: ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

            /// 👨‍⚕️ DOCTOR IMAGE
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.pinkAccent.withOpacity(0.15),
              backgroundImage: const AssetImage('assets/doctor.png'),
            ),

            /// NAME
            title: Text(
              d.doctorName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            /// DETAILS
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.specialization,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  d.associationName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.pinkAccent),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _linkTile(IconData icon, String label, String url) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.pinkAccent),
      title: Text(label),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () => _launch(url),
    );
  }

  bool _hasSocial() {
    return (clinic.facebookHandle?.isNotEmpty == true) ||
        (clinic.instagramHandle?.isNotEmpty == true) ||
        (clinic.twitterHandle?.isNotEmpty == true);
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
