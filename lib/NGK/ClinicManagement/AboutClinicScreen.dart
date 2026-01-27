import 'dart:convert';
import 'package:cutomer_app/NGK/Service/clinic_service.dart';
import 'package:cutomer_app/Review/HospitalRatingScreen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ClinicModelWithLocation.dart';

class AboutClinicScreen extends StatefulWidget {
  final String clinicId;
  final String? distanceInKm;

  const AboutClinicScreen(
      {super.key, required this.clinicId, this.distanceInKm});

  @override
  State<AboutClinicScreen> createState() => _AboutClinicScreenState();
}

class _AboutClinicScreenState extends State<AboutClinicScreen> {
  late Future<ClinicModelWithLocation> clinicFuture;

  @override
  void initState() {
    super.initState();
    clinicFuture = ClinicService.fetchClinicById(widget.clinicId);
  }

  void _openMap(double lat, double lng) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Clinic"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FutureBuilder<ClinicModelWithLocation>(
        future: clinicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: mainColor),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load clinic"));
          }

          final clinic = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerCard(clinic),
                const SizedBox(height: 16),
                _ratingDistance(clinic),
                const SizedBox(height: 16),
                _linksSection(clinic),
                _locationSection(clinic),
                _timingsSection(clinic),
                _doctorsAccordion(clinic),
                if (_hasSocial(clinic)) _socialSection(clinic),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent),
                    onPressed: () {
                      Get.to(() =>
                          HospitalRatingScreen(clinicId: clinic.clinicId));
                    },
                    child: const Text("Ratings & Comments"),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _headerCard(ClinicModelWithLocation clinic) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.pinkAccent.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _clinicImage(clinic),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clinic.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(clinic.address,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54)),
                  Text("City: ${clinic.city}",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54)),
                  if (clinic.licenseNumber?.isNotEmpty == true)
                    Text("License: ${clinic.licenseNumber}",
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clinicImage(ClinicModelWithLocation clinic) {
    if (clinic.hospitalLogo.startsWith("data:image")) {
      final bytes = base64Decode(clinic.hospitalLogo.split(',').last);
      return Image.memory(bytes, width: 70, height: 70, fit: BoxFit.fill);
    }
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(Icons.local_hospital, size: 36),
    );
  }

  Widget _ratingDistance(ClinicModelWithLocation clinic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          const Icon(Icons.star, color: mainColor, size: 16),
          const SizedBox(width: 4),
          Text(clinic.hospitalOverallRating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        Row(children: [
          const Icon(Icons.location_on, color: mainColor, size: 16),
          const SizedBox(width: 4),
          Text(widget.distanceInKm ?? "0 KM",
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ],
    );
  }

  Widget _linksSection(ClinicModelWithLocation clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Links"),
        if (clinic.website.isNotEmpty)
          _linkTile(Icons.language, "Website", clinic.website),
        if (clinic.walkthrough?.isNotEmpty == true)
          _linkTile(
              Icons.play_circle, "Clinic Virtual Tour", clinic.walkthrough!),
      ],
    );
  }

  Widget _locationSection(ClinicModelWithLocation clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Location"),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.location_on, color: Colors.pinkAccent),
          title: Text(clinic.address,
              maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.map, color: Colors.green),
          onTap: () => _openMap(clinic.latitude, clinic.longitude),
        ),
      ],
    );
  }

  Widget _timingsSection(ClinicModelWithLocation clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Timings"),
        _infoTile(
            Icons.access_time, "${clinic.openingTime} - ${clinic.closingTime}"),
      ],
    );
  }

  Widget _doctorsAccordion(ClinicModelWithLocation clinic) {
    if (clinic.doctorsList.isEmpty) {
      return const Text("No doctors available");
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        "View Doctors (${clinic.doctorsList.length})",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: clinic.doctorsList.map((d) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.pinkAccent.withOpacity(0.3)),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/doctor.png'),
            ),
            title: Text(d.doctorName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${d.specialization}\n${d.associationName}"),
          ),
        );
      }).toList(),
    );
  }

  Widget _socialSection(ClinicModelWithLocation clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Social"),
        if (clinic.facebookHandle?.isNotEmpty == true)
          _linkTile(Icons.facebook, "Facebook", clinic.facebookHandle!),
        if (clinic.instagramHandle?.isNotEmpty == true)
          _linkTile(Icons.camera_alt, "Instagram", clinic.instagramHandle!),
        if (clinic.twitterHandle?.isNotEmpty == true)
          _linkTile(Icons.alternate_email, "Twitter", clinic.twitterHandle!),
      ],
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );

  Widget _infoTile(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(icon, size: 18, color: Colors.pinkAccent),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ]),
      );

  Widget _linkTile(IconData icon, String label, String url) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.pinkAccent),
      title: Text(label),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }

  bool _hasSocial(ClinicModelWithLocation clinic) {
    return (clinic.facebookHandle?.isNotEmpty == true) ||
        (clinic.instagramHandle?.isNotEmpty == true) ||
        (clinic.twitterHandle?.isNotEmpty == true);
  }
}
