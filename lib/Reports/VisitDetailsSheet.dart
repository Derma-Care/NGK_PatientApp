// visit_details_sheet.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:intl/intl.dart';

class VisitDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> visit;
  final Function previewFn; // (BuildContext, String, {String? name})
  final Function downloadFn; // (String, {String? name})
  final Function buildImageListForVisitFn; // (Map) -> List<String>
  final Function getReportsByBookingFn; // (String) -> List<Map>

  const VisitDetailsSheet({
    super.key,
    required this.visit,
    required this.previewFn,
    required this.downloadFn,
    required this.buildImageListForVisitFn,
    required this.getReportsByBookingFn,
  });

  @override
  Widget build(BuildContext context) {
    final bookingId = visit['bookingId']?.toString() ?? '';
    final reports =
        getReportsByBookingFn(bookingId) as List<Map<String, dynamic>>;
    final images = buildImageListForVisitFn(visit) as List<String>;
    final prescriptions = (visit['prescriptionPdf'] ?? []) as List;

    String visitDate = '';
    final rawDate = visit['visitDateTime']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(rawDate).toLocal();
        visitDate = DateFormat('dd MMM yyyy-hh:mm a').format(parsedDate);
      } catch (_) {
        visitDate = rawDate; // fallback if parsing fails
      }
    }
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.98,
      expand: false,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              '${visit['visitType'] ?? 'Visit'}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: mainColor),
            ),
            Text(
              '${visitDate}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: secondaryColor),
            ),
            const SizedBox(height: 12),

            // Prescriptions
            if (prescriptions.isNotEmpty) ...[
              const Text('🩺 Prescription',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              for (var p in prescriptions)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text('Prescription')),
                      IconButton(
                        tooltip: 'View',
                        onPressed: () => previewFn(context, p.toString(),
                            name: 'Prescription'),
                        icon: const Icon(Icons.visibility, color: mainColor),
                      ),
                      IconButton(
                        tooltip: 'Download',
                        onPressed: () =>
                            downloadFn(p.toString(), name: 'Prescription'),
                        icon: const Icon(Icons.download, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              const Divider(),
            ],

            // Reports
            const Text('📄 Reports',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (reports.isEmpty)
              const Text('No reports for this visit.')
            else
              for (var r in reports)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['reportName'] ?? 'Report',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            if ((r['reportDate'] ?? '') != '')
                              Text(r['reportDate'] ?? '',
                                  style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      // reportFile might be a list; show first file as default
                      IconButton(
                        tooltip: 'View',
                        onPressed: () {
                          final rf = (r['reportFile'] ?? []);
                          if (rf is List && rf.isNotEmpty) {
                            previewFn(context, rf[0].toString(),
                                name: r['reportName'] ?? 'Report');
                          } else if (r['reportFile'] is String) {
                            previewFn(context, r['reportFile'].toString(),
                                name: r['reportName'] ?? 'Report');
                          }
                        },
                        icon: const Icon(Icons.visibility, color: mainColor),
                      ),
                      IconButton(
                        tooltip: 'Download',
                        onPressed: () {
                          final rf = (r['reportFile'] ?? []);
                          if (rf is List && rf.isNotEmpty) {
                            downloadFn(rf[0].toString(),
                                name: r['reportName'] ?? 'Report');
                          } else if (r['reportFile'] is String) {
                            downloadFn(r['reportFile'].toString(),
                                name: r['reportName'] ?? 'Report');
                          }
                        },
                        icon: const Icon(Icons.download, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
            const Divider(height: 24),

            // Images
            const Text('📸 Before & After Images',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (images.isEmpty)
              const Text('No images available.')
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final img = images[i];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => previewFn(context, img.toString()),
                          child: Container(
                            width: 120,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                              image: DecorationImage(
                                image: img.toString().startsWith('data:image')
                                    ? MemoryImage(base64Decode(
                                            img.toString().split(',').last))
                                        as ImageProvider
                                    : NetworkImage(img.toString()),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'View',
                                onPressed: () =>
                                    previewFn(context, img.toString()),
                                icon: const Icon(Icons.visibility,
                                    size: 20, color: mainColor),
                              ),
                              IconButton(
                                tooltip: 'Download',
                                onPressed: () =>
                                    downloadFn(img.toString(), name: 'Image'),
                                icon: const Icon(Icons.download,
                                    size: 20, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
