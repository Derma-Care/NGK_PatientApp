// doctor_bookings_screen.dart
import 'package:cutomer_app/Reports/VisitListScreen.dart';
import 'package:flutter/material.dart';

import 'package:cutomer_app/Utils/Constant.dart';

class DoctorBookingsScreen extends StatelessWidget {
  final String patientId;
  final String patientName;
  final List<Map<String, dynamic>> doctorVisits; // all visits for patient
  final Function previewFn;
  final Function downloadFn;
  final Function buildImageListForVisitFn;
  final Function getReportsByBookingFn;

  const DoctorBookingsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.doctorVisits,
    required this.previewFn,
    required this.downloadFn,
    required this.buildImageListForVisitFn,
    required this.getReportsByBookingFn,
  });

  @override
  Widget build(BuildContext context) {
    // Group visits by doctorName
    final Map<String, List<Map<String, dynamic>>> byDoctor = {};
    for (var v in doctorVisits) {
      final doc = (v['doctorName'] ?? 'Unknown Doctor').toString();
      byDoctor.putIfAbsent(doc, () => []);
      byDoctor[doc]!.add(Map<String, dynamic>.from(v));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patientName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "ID: $patientId",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (var docEntry in byDoctor.entries)
            Card(
              color: Colors.white, // clean white surface
              elevation: 3,
              shadowColor: Colors.black26,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.shade300, // subtle border line
                  width: 0.8,
                ),
              ),
              // margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.medical_services, color: mainColor),
                title: Text(docEntry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(docEntry.value.first['clinicName'] ?? ''),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.arrow_forward_ios,
                      color: mainColor, size: 16),
                ),
                onTap: () {
                  // Navigate to BookingVisitsScreen (grouped by bookingId)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingVisitsScreen(
                        doctorName: docEntry.key,
                        bookingsForDoctor: docEntry.value,
                        previewFn: previewFn,
                        downloadFn: downloadFn,
                        buildImageListForVisitFn: buildImageListForVisitFn,
                        getReportsByBookingFn: getReportsByBookingFn,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
