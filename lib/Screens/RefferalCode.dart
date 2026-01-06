import 'package:cutomer_app/NGK/Contoller/customer_controller.dart';
import 'package:cutomer_app/NGK/Contoller/referral_wallet_controller.dart';
import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/DateConverter.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:url_launcher/url_launcher.dart';

class ReferralWalletPage extends StatefulWidget {
  final String mobile;
  const ReferralWalletPage({super.key, required this.mobile});

  @override
  State<ReferralWalletPage> createState() => _ReferralWalletPageState();
}

class _ReferralWalletPageState extends State<ReferralWalletPage> {
  late ReferralWalletController walletController;
  late CustomerGetController customerController;

  late Future<CustomerProfileModel?> _futureUserData;
  String? customerId;
  CustomerProfileModel? userData;
  @override
  @override
  void initState() {
    super.initState();

    walletController = Get.put(ReferralWalletController());
    customerController = Get.find<CustomerGetController>();

    walletController.loadWallet();
  }

  void _shareOnWhatsApp(BuildContext context) async {
    final customer = customerController.customer.value;
    if (customer == null || customer.referId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Referral code not available")),
      );
      return;
    }

    final String referralCode = customer.referId!;
    final String appLink =
        "https://glowkartclinic.ashokfruit.shop/NGK-Registration-Form";

    final String message = '''
✨ Join Neeha’s Glow Kart ✨

Use my referral code *$referralCode* while registering and unlock exciting rewards 🎁

👉 Register here:
$appLink
''';

    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WhatsApp not installed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Referral Wallet'),
          backgroundColor: mainColor,
        ),
        body: Obx(() {
          if (walletController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: mainColor),
            );
          }

          return DefaultTabController(
            length: 3,
            initialIndex: 0, // 🔥 All is default
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _walletCard(),
                  const SizedBox(height: 20),
                  _referralCodeCard(context),
                  const SizedBox(height: 20),

                  // 🔹 TABS
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TabBar(
                      indicatorColor: mainColor,
                      labelColor: mainColor,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: "All"),
                        Tab(text: "Earned"),
                        Tab(text: "Used"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 TAB CONTENT
                  Expanded(
                    child: TabBarView(
                      children: [
                        _rewardList(type: "all"),
                        _rewardList(type: "earned"),
                        _rewardList(type: "used"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  // ✅ Rewards List
  Widget _rewardList({required String type}) {
    return Obx(() {
      final all = walletController.transactions;

      final filtered = type == "all"
          ? all
          : all
              .where((t) =>
                  type == "earned" ? t.type == "CREDIT" : t.type == "DEBIT")
              .toList();

      if (filtered.isEmpty) {
        return const Center(child: Text("No transactions"));
      }

      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (_, index) {
          final t = filtered[index];
          final isCredit = t.type == "CREDIT";

          return Card(
            color: Colors.white,
            child: ListTile(
              leading: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green : Colors.red,
              ),
              title: Text(
                isCredit ? "Reward Earned" : "Reward Used",
              ),
              subtitle: Text(t.reason.replaceAll("_", " ")),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isCredit ? '+' : '-'} ₹${t.points}",
                    style: TextStyle(
                      color: isCredit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatCreateDate(t.createdAt.toLocal()),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _walletCard() {
    return Obx(() {
      final summary = walletController.walletSummary.value;

      if (summary == null) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, secondaryColor],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Wallet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 Wallet Balance (Primary)
            Text(
              "₹${summary.balance}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Available Balance",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 Divider
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white.withOpacity(0.25),
            ),

            const SizedBox(height: 14),

            /// 🔹 Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _walletStat(
                  label: "Total Earned",
                  value: "₹${summary.totalCredits}",
                ),
                _walletStat(
                  label: "Used",
                  value: "₹${summary.balance ?? 0}",
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _walletStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _referralCodeCard(BuildContext context) {
    return Obx(() {
      final customer = customerController.customer.value;
      if (customer == null) {
        return const Text("Customer data not available");
      }

      if (customer == null) {
        return const Text("No customer data");
      }

      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: mainColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                "Your Referral Code",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                capitalizeEachWord(customer.fullName),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              Text(customer.referId ?? ""),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _shareOnWhatsApp(context),
                icon: const Icon(Icons.share),
                label: const Text("Share Code"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _historyTile({
    required String title,
    required String subtitle,
    required int amount,
    required String date,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.card_giftcard, color: mainColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "+ 💰$amount",
              style: const TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(date, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
