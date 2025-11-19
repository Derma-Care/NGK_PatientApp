// visits_for_booking_screen.dart
import 'package:cutomer_app/Reports/VisitDetailsSheet.dart';
import 'package:flutter/material.dart';

import 'package:cutomer_app/Utils/Constant.dart';
import 'package:intl/intl.dart';

class VisitsForBookingScreen extends StatelessWidget {
  final String bookingId;
  final List<Map<String, dynamic>> visits;
  final Function previewFn;
  final Function downloadFn;
  final Function buildImageListForVisitFn;
  final Function getReportsByBookingFn;

  const VisitsForBookingScreen({
    super.key,
    required this.bookingId,
    required this.visits,
    required this.previewFn,
    required this.downloadFn,
    required this.buildImageListForVisitFn,
    required this.getReportsByBookingFn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$bookingId',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        backgroundColor: mainColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          final visitType = visit['visitType'] ?? 'Visit';
          // final visitDate = visit['visitDateTime'] ?? '';
          final doctor = visit['doctorName'] ?? '';
          String visitDate = '';
          final rawDate = visit['visitDateTime']?.toString();
          if (rawDate != null && rawDate.isNotEmpty) {
            try {
              final parsedDate = DateTime.parse(rawDate).toLocal();
              visitDate = DateFormat('dd MMM yyyy  hh:mm a').format(parsedDate);
            } catch (_) {
              visitDate = rawDate; // fallback if parsing fails
            }
          }

          return Card(
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
            child: ListTile(
              leading: const Icon(Icons.local_hospital, color: mainColor),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visitType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    visitDate,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54, // lighter color for date/time
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '$doctor',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                // ONLY when the user taps a visit we open the bottom sheet
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => VisitDetailsSheet(
                    visit: visit,
                    previewFn: previewFn,
                    downloadFn: downloadFn,
                    buildImageListForVisitFn: buildImageListForVisitFn,
                    getReportsByBookingFn: getReportsByBookingFn,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
