import 'package:cutomer_app/Customers/GetCustomerModel.dart';
import 'package:cutomer_app/Dashboard/GetCustomerData.dart';
import 'package:cutomer_app/NGK/Contoller/customer_controller.dart';
import 'package:cutomer_app/NGK/Contoller/referral_wallet_controller.dart';
import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/NGK/Service/customer_service.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralWalletPage extends StatefulWidget {
  const ReferralWalletPage({super.key});

  @override
  State<ReferralWalletPage> createState() => _ReferralWalletPageState();
}

class _ReferralWalletPageState extends State<ReferralWalletPage> {
  final ReferralWalletController walletController =
      Get.find<ReferralWalletController>();

  final CustomerGetController customerController =
      Get.find<CustomerGetController>();

  // ✅ Rewards list
  final List<Map<String, dynamic>> rewards = [
    {"type": "earned", "amount": 500, "date": "10 July 2025"},
    {"type": "used", "amount": 300, "date": "12 July 2025"},
    {"type": "earned", "amount": 500, "date": "15 July 2025"},
  ];

  // ✅ Auto-calculated wallet balance
  int get walletBalance {
    return rewards.fold(0, (total, item) {
      if (item["type"] == "earned") {
        return total + item["amount"] as int;
      } else if (item["type"] == "used") {
        return total - item["amount"] as int;
      }
      return total;
    });
  }

  late Future<CustomerProfileModel?> _futureUserData;
  String? customerId;
  CustomerProfileModel? userData;
  @override
  void initState() {
    super.initState();
    // _loadCustomerData();
  }

  // Future<void> _loadCustomerData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // final savedName = prefs.getString('customer_full_name');

  //   // customerId = prefs.getString('customerId');
  //   final mobileNumber = await prefs.getString('mobileNumber');
  //   setState(() {
  //     _futureUserData = CustomerService.getCustomer(mobileNumber ?? "");
  //     //  = fetchUserData(customerId ?? "");
  //   });
  // }

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
      body: DefaultTabController(
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
      ),
    );
  }

  // ✅ Rewards List
  Widget _rewardList({required String type}) {
    return Obx(() {
      final rewards = walletController.rewards;

      final filtered = type == "all"
          ? rewards
          : rewards.where((r) => r["type"] == type).toList();

      if (filtered.isEmpty) {
        return const Center(child: Text("No rewards available"));
      }

      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final r = filtered[index];
          final isEarned = r["type"] == "earned";

          return Card(
            child: ListTile(
              leading: Icon(
                isEarned ? Icons.arrow_downward : Icons.arrow_upward,
                color: isEarned ? Colors.green : Colors.red,
              ),
              title: Text(isEarned ? "Reward Earned" : "Reward Used"),
              trailing: Text(
                "${isEarned ? '+' : '-'} ₹${r["amount"]}",
                style: TextStyle(
                  color: isEarned ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _walletCard() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [mainColor, secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Wallet Balance",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                "💰 ${walletController.walletBalance}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _referralCodeCard(BuildContext context) {
    return Obx(() {
      if (customerController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final customer = customerController.customer.value;

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
