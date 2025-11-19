// patient_report_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/Reports/DoctorBookingsScreen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientReportScreen extends StatefulWidget {
  final String customerId;
  const PatientReportScreen({super.key, required this.customerId});

  @override
  State<PatientReportScreen> createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  bool loading = true;
  Map<String, dynamic>? customerData;
  List<Map<String, dynamic>> doctorList = [];
  List<Map<String, dynamic>> reportsDtoList = [];
  final Map<String, Map<String, String>> patientInfo = {};

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await fetchCustomerData();
    await _fetchPatientNames();
    setState(() => loading = false);
  }

  // Fetch Customer Data
  Future<void> fetchCustomerData() async {
    try {
      final url = Uri.parse("$registerUrl/getReports/${widget.customerId}");
      final resp = await http.get(url);
      print("Raw getReports response: ${resp.body}");

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        dynamic data = decoded["data"];
        if (data is List && data.isNotEmpty) {
          data = data.first;
        }

        if (data is Map && data.isNotEmpty) {
          customerData = Map<String, dynamic>.from(data);

          doctorList = (customerData!["doctorSaveDetailsDTO"] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          reportsDtoList = (customerData!["reportsDtoList"] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          debugPrint(
              "✅ doctorList(${doctorList.length}) and reportsDtoList(${reportsDtoList.length}) loaded.");
        } else {
          debugPrint("⚠️ Invalid data format: $data");
        }
      } else {
        debugPrint("❌ getReports failed with status ${resp.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Error in fetchCustomerData: $e");
    }
  }

  // Fetch Patient Names
  Future<void> _fetchPatientNames() async {
    try {
      final Set<String> patientIds = {};
      final Map<String, String> patientClinic = {};

      for (var d in doctorList) {
        final pid = (d['patientId'] ?? '').toString();
        final cid = (d['clinicId'] ?? d['clinic'] ?? '').toString();
        if (pid.isNotEmpty) {
          patientIds.add(pid);
          if (!patientClinic.containsKey(pid) && cid.isNotEmpty) {
            patientClinic[pid] = cid;
          }
        }
      }

      for (final pid in patientIds) {
        final clinicId = patientClinic[pid] ?? '0001';
        try {
          final url = Uri.parse("${clinicUrl}/bookings/byInput/$pid/$clinicId");
          print("byInput ::: ${url}");
          final r = await http.get(url);
          if (r.statusCode == 200) {
            final decoded = jsonDecode(r.body);
            String name = pid;
            String mobile = '';
            if (decoded is Map &&
                decoded['data'] is List &&
                decoded['data'].isNotEmpty) {
              final first = decoded['data'][0];
              if (first is Map) {
                name = (first['name'] ??
                        first['patientName'] ??
                        first['customerName'] ??
                        pid)
                    .toString();
                mobile = (first['mobileNumber'] ??
                            first['patientMobileNumber'] ??
                            first['mobile'])
                        ?.toString() ??
                    '';
              }
            }
            patientInfo[pid] = {'name': name, 'mobile': mobile};
            debugPrint("Patient $pid -> $name");
          } else {
            patientInfo[pid] = {'name': pid, 'mobile': ''};
          }
        } catch (e) {
          patientInfo[pid] = {'name': pid, 'mobile': ''};
        }
      }
    } catch (e) {
      debugPrint("Error in _fetchPatientNames: $e");
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  // Get Reports by Booking
  List<Map<String, dynamic>> getReportsByBooking(String? bookingId,
      {String? visitMobile}) {
    final List<Map<String, dynamic>> matched = [];
    if (bookingId == null || bookingId.toString().trim().isEmpty)
      return matched;
    final norm = bookingId.toString().trim().toLowerCase();
    for (var group in reportsDtoList) {
      final rl = (group['reportsList'] ?? []) as List;
      for (var r in rl) {
        final rb = (r['bookingId'] ?? '').toString().trim().toLowerCase();
        if (rb == norm) matched.add(Map<String, dynamic>.from(r));
      }
    }
    return matched;
  }

  Future<String> _saveBytesToTemp(List<int> bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  bool _looksLikeBase64Pdf(String s) {
    final trimmed = s.trim();
    return trimmed.startsWith('JVBER') ||
        trimmed.startsWith('data:application/pdf') ||
        trimmed.contains('%PDF');
  }

  bool _isImageEntry(String s) {
    final str = s.trim();
    // base64 image data URI
    if (str.startsWith('data:image')) return true;

    // common image file extensions in URL or path
    final lower = str.toLowerCase();
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp') ||
        lower.contains('/images/') ||
        lower.contains('/image/')) {
      return true;
    }

    // very naive fallback: url with query param like ?format=jpg
    if (lower.contains('format=jpg') || lower.contains('format=png'))
      return true;

    return false;
  }

  Future<void> _previewFile(BuildContext ctx, String entry,
      {String? name}) async {
    try {
      final trimmed = entry.trim();
      // PDF (base64 or PDF url/content)
      if (_looksLikeBase64Pdf(trimmed)) {
        var base = trimmed;
        if (base.startsWith('data:')) {
          final idx = base.indexOf('base64,');
          if (idx >= 0) base = base.substring(idx + 7);
        }
        final bytes = base64Decode(base);
        final path = await _saveBytesToTemp(bytes, (name ?? 'temp') + '.pdf');
        Navigator.push(
            ctx,
            MaterialPageRoute(
                builder: (_) => PdfViewerScreen(localPath: path)));
        return;
      }

      // Image (data URI)
      if (_isImageEntry(trimmed)) {
        if (trimmed.startsWith('data:image')) {
          // base64 data URI
          Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => ImagePreviewScreen(imageUrl: trimmed)));
          return;
        } else if (trimmed.startsWith('http')) {
          // network image URL
          Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => ImagePreviewScreen(imageUrl: trimmed)));
          return;
        } else {
          // maybe a relative path returned by API (e.g. "/uploads/abc.jpg")
          // try converting to absolute using clinicUrl/registerUrl base if needed
          String possibleUrl = trimmed;
          if (!possibleUrl.startsWith('http')) {
            // try prefixing with your clinicUrl or registerUrl if available
            possibleUrl =
                "$clinicUrl${possibleUrl.startsWith('/') ? '' : '/'}$possibleUrl";
          }
          Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => ImagePreviewScreen(imageUrl: possibleUrl)));
          return;
        }
      }

      // HTTP fallback: maybe it's a PDF returned via url
      if (trimmed.startsWith('http')) {
        final r = await http.get(Uri.parse(trimmed));
        if (r.statusCode == 200) {
          // try to detect content type from headers
          final contentType = r.headers['content-type'] ?? '';
          if (contentType.contains('image')) {
            final bytes = r.bodyBytes;
            final base64Str = 'data:$contentType;base64,${base64Encode(bytes)}';
            Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => ImagePreviewScreen(imageUrl: base64Str)));
            return;
          } else {
            // treat as PDF
            final path = await _saveBytesToTemp(
                r.bodyBytes, (name ?? 'remote') + '.pdf');
            Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(localPath: path)));
            return;
          }
        } else {
          throw Exception('Failed to download $trimmed -> ${r.statusCode}');
        }
      }

      debugPrint("Cannot preview: unrecognized format for entry: $entry");
    } catch (e) {
      debugPrint("Error previewing file: $e");
    }
  }

  Future<void> _downloadFile(String entry, {String? name}) async {
    try {
      String path;
      if (_looksLikeBase64Pdf(entry)) {
        var base = entry;
        if (base.startsWith('data:')) {
          final idx = base.indexOf('base64,');
          if (idx >= 0) base = base.substring(idx + 7);
        }
        final bytes = base64Decode(base);
        path = await _saveBytesToTemp(bytes, (name ?? 'download') + '.pdf');
      } else {
        final r = await http.get(Uri.parse(entry));
        if (r.statusCode == 200) {
          path = await _saveBytesToTemp(
              r.bodyBytes, (name ?? 'download') + '.pdf');
        } else {
          throw Exception('Download failed ${r.statusCode}');
        }
      }

      // ✅ Open the file safely
      final result = await OpenFilex.open(path);
      debugPrint('File opened with result: ${result.message}');
    } catch (e) {
      debugPrint("Error downloading file: $e");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitFadingCircle(
                color: mainColor,
                size: 40.0,
              ),
              SizedBox(height: 12),
              Text(
                "Fetching Data...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (doctorList.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No doctor/visit data found')),
      );
    }

    // Group visits by patientId
    final Map<String, List<Map<String, dynamic>>> patientsMap = {};
    for (var v in doctorList) {
      final pid = (v['patientId'] ?? 'Unknown').toString();
      patientsMap.putIfAbsent(pid, () => []);
      patientsMap[pid]!.add(Map<String, dynamic>.from(v));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Reports'),
        backgroundColor: mainColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (var entry in patientsMap.entries)
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
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final patientVisits = entry.value;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorBookingsScreen(
                        patientId: entry.key,
                        patientName:
                            patientInfo[entry.key]?['name'] ?? entry.key,
                        doctorVisits: patientVisits,
                        previewFn: _previewFile,
                        downloadFn: _downloadFile,
                        buildImageListForVisitFn: _buildImageListForVisit,
                        getReportsByBookingFn: getReportsByBooking,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: mainColor.withOpacity(0.15),
                        child: const Icon(Icons.person,
                            color: mainColor, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientInfo[entry.key]?['name'] ?? entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "🆔 ${entry.key}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: mainColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_forward_ios,
                            color: mainColor, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  // ---- VISIT TILE ----

  List<String> _buildImageListForVisit(Map<String, dynamic> visit) {
    final keys = [
      'beforeImages',
      'afterImages',
      'images',
      'photos',
      'imageUrls'
    ];
    final List<String> imgs = [];
    for (var k in keys) {
      final v = visit[k];
      if (v is List) {
        // allow both URL strings and base64 data URIs inside lists
        for (var item in v) {
          if (item is String && item.isNotEmpty) {
            imgs.add(item);
          }
        }
      } else if (v is String && v.isNotEmpty) {
        // if it's a single string (maybe a base64 or url)
        imgs.add(v);
      }
    }
    if (imgs.isEmpty) {
      imgs.add(
          'https://picsum.photos/seed/${visit['bookingId'] ?? 'img1'}/300/200');
    }
    return imgs;
  }
}

// ---------- PDF Viewer ----------
class PdfViewerScreen extends StatelessWidget {
  final String localPath;
  const PdfViewerScreen({super.key, required this.localPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('PDF Preview'), backgroundColor: mainColor),
      body: PDFView(filePath: localPath),
    );
  }
}

// ---------- Image Preview ----------
class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;
  const ImagePreviewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isBase64 = imageUrl.startsWith('data:image');
    ImageProvider provider;
    if (isBase64) {
      try {
        final base64Part = imageUrl.split(',').last;
        provider = MemoryImage(base64Decode(base64Part));
      } catch (e) {
        // fallback to an empty network image so errorBuilder shows instead of crash
        provider = const NetworkImage('https://picsum.photos/200');
      }
    } else {
      provider = NetworkImage(imageUrl);
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text('Image Preview'), backgroundColor: mainColor),
      body: Center(child: PhotoView(imageProvider: provider)),
    );
  }
}
