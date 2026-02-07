import 'package:flutter/material.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';

class NgkTermsConditionsScreen extends StatelessWidget {
  const NgkTermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonHeader(title: "Terms & Conditions"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle("Welcome to NGK"),
            _SectionText(
              "These Terms & Conditions govern your access and use of the NGK "
              "mobile application and services. By registering or using NGK, "
              "you agree to comply with these terms.",
            ),

            _SectionTitle("User Eligibility"),
            _SectionText(
              "You must be at least 18 years old to use the NGK application. "
              "By using this app, you confirm that the information provided "
              "during registration is accurate and complete.",
            ),

            _SectionTitle("Account & Registration"),
            _SectionText(
              "Each user is responsible for maintaining the confidentiality "
              "of their account details. NGK reserves the right to suspend or "
              "terminate accounts that provide false or misleading information.",
            ),

            _SectionTitle("Referral Program"),
            _SectionText(
              "Referral rewards are credited only when the referred user "
              "successfully completes registration as per NGK guidelines. "
              "Any misuse or fraudulent activity may lead to cancellation "
              "of rewards.",
            ),

            _SectionTitle("Reward Coins & Membership"),
            _SectionText(
              "Reward coins earned through referrals or promotions are non-"
              "transferable and cannot be exchanged for cash unless explicitly "
              "mentioned by NGK. Membership benefits are subject to change.",
            ),

            _SectionTitle("Appointments & Services"),
            _SectionText(
              "NGK facilitates appointment booking between customers and "
              "clinics. NGK is not responsible for service quality, delays, "
              "or disputes between customers and clinics.",
            ),

            _SectionTitle("Data Privacy"),
            _SectionText(
              "NGK values your privacy. User data is collected and processed "
              "only to provide services and improve user experience. We do not "
              "share personal data with third parties without consent, except "
              "as required by law.",
            ),

            _SectionTitle("Prohibited Activities"),
            _SectionText(
              "Users must not misuse the application, attempt unauthorized "
              "access, or engage in activities that disrupt NGK services.",
            ),

            _SectionTitle("Changes to Terms"),
            _SectionText(
              "NGK reserves the right to modify these Terms & Conditions at "
              "any time. Continued use of the application constitutes "
              "acceptance of updated terms.",
            ),

            _SectionTitle("Contact Us"),
            _SectionText(
              "For questions or concerns regarding these Terms & Conditions, "
              "please contact NGK customer support through the application.",
            ),

            SizedBox(height: 20),
            Center(
              child: Text(
                "© NGK. All rights reserved.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: mainColor,
        ),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;

  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }
}
