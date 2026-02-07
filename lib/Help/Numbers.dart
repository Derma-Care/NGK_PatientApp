import 'package:url_launcher/url_launcher.dart';

String customerNumber = "7842259803";
String customerWhatsupNumber = "7842259803";
String emailID = "ngkderma@gmail.com";

customerCare() async {
  final Uri callNow = Uri.parse("tel:+91${customerNumber}");

  // Check if the URL can be launched
  if (await canLaunchUrl(callNow)) {
    // Launch the WhatsApp URL
    await launchUrl(callNow);
  } else {
    // If the URL cannot be launched, show an error or fallback
    print('Could not launch WhatsApp');
  }
}

whatsUpChat() async {
  final Uri whatsappNumber =
      Uri.parse("https://wa.me/+91${customerWhatsupNumber}");

  // Check if the URL can be launched
  if (await canLaunchUrl(whatsappNumber)) {
    // Launch the WhatsApp URL
    await launchUrl(whatsappNumber);
  } else {
    // If the URL cannot be launched, show an error or fallback
    print('Could not launch WhatsApp');
  }
}

Future<void> emailSupport() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: emailID,
    query: 'subject=Support Needed&body=Hello, I need help',
  );
  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    print('Could not launch Email');
  }
}
