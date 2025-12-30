import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleCalendar({
  required String title,
  required String description,
  required String location,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  String formatDate(DateTime date) {
    return date
            .toUtc()
            .toIso8601String()
            .split('.')
            .first
            .replaceAll('-', '')
            .replaceAll(':', '') +
        'Z';
  }

  final start = formatDate(startDate);
  final end = formatDate(endDate);

  final url = 'https://www.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent(title)}'
      '&details=${Uri.encodeComponent(description)}'
      '&location=${Uri.encodeComponent(location)}'
      '&dates=$start/$end';

  final uri = Uri.parse(url);

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
