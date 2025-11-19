// booking_visits_screen.dart
import 'package:cutomer_app/Reports/VisitsForBookingScreen.dart';
import 'package:flutter/material.dart';

import 'package:cutomer_app/Utils/Constant.dart';
import 'package:intl/intl.dart';

class BookingVisitsScreen extends StatelessWidget {
  final String doctorName;
  final List<Map<String, dynamic>>
      bookingsForDoctor; // visits list which contain bookingId
  final Function previewFn;
  final Function downloadFn;
  final Function buildImageListForVisitFn;
  final Function getReportsByBookingFn;

  const BookingVisitsScreen({
    super.key,
    required this.doctorName,
    required this.bookingsForDoctor,
    required this.previewFn,
    required this.downloadFn,
    required this.buildImageListForVisitFn,
    required this.getReportsByBookingFn,
  });

  @override
  Widget build(BuildContext context) {
    // Group by bookingId
    final Map<String, List<Map<String, dynamic>>> byBooking = {};
    for (var v in bookingsForDoctor) {
      final bId = (v['bookingId'] ?? 'Unknown').toString();
      byBooking.putIfAbsent(bId, () => []);
      byBooking[bId]!.add(Map<String, dynamic>.from(v));
    }

    final entries = byBooking.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$doctorName'),
        backgroundColor: mainColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        itemBuilder: (context, idx) {
          final bookingEntry = entries[idx];
          final bookingId = bookingEntry.key;
          final visits = bookingEntry.value;
          final clinic =
              visits.isNotEmpty ? visits.first['clinicName'] ?? '' : '';
          final displayDate =
              visits.isNotEmpty ? (visits.first['visitDateTime'] ?? '') : '';

          String visitDate = '';
          final rawDate = visits.first['visitDateTime']?.toString();
          if (rawDate != null && rawDate.isNotEmpty) {
            try {
              final parsedDate = DateTime.parse(rawDate).toLocal();
              visitDate = DateFormat('dd MMM yyyy-hh:mm a').format(parsedDate);
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
              leading: const Icon(Icons.event_note, color: mainColor),
              title: Text('Booking: $bookingId'),
              subtitle: Text('$clinic\n$visitDate', maxLines: 2),
              isThreeLine: true,
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
                // Navigate to visits list for this booking
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VisitsForBookingScreen(
                      bookingId: bookingId,
                      visits: visits,
                      previewFn: previewFn,
                      downloadFn: downloadFn,
                      buildImageListForVisitFn: buildImageListForVisitFn,
                      getReportsByBookingFn: getReportsByBookingFn,
                    ),
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
