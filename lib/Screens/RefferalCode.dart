import 'package:cutomer_app/NGK/Contoller/customer_controller.dart';
import 'package:cutomer_app/NGK/Contoller/referral_wallet_controller.dart';
import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/NGK/Modals/wallet_summary_model.dart';
import 'package:cutomer_app/NGK/Screens/RewardInfoScreen.dart';
import 'package:cutomer_app/Screens/ReferredMembersScreen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/DateConverter.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';

import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

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
    customerController = Get.put(CustomerGetController());
    customerController.fetchCustomer(widget.mobile);

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
    final String appLink = "http://3.111.202.212:3000/referral-registration";

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
              child: SpinKitThreeBounce(
                color: mainColor,
                size: 40,
              ),
            );
          }

          return DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _walletCard(),
                          const SizedBox(height: 20),
                          _referralCodeCard(context),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const RewardInfoScreen());
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: mainColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: mainColor.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: mainColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.card_giftcard,
                                      color: mainColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Reward Coins & Membership",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Keep referring & earn exciting rewards",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: mainColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              final referredList = customerController
                                      .customer.value?.referredCustomers ??
                                  [];

                              Get.to(() => ReferredMembersScreen(
                                    referredCustomers: referredList,
                                  ));
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.blue.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.group,
                                      color: Colors.blue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Your Referred Members",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "View names & referral IDs",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text("Transaction History",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  /// 🔹 STICKY TAB BAR
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      const TabBar(
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
                  ),
                ];
              },

              /// 🔹 TAB CONTENT (SCROLLS PROPERLY)
              body: TabBarView(
                children: [
                  _rewardList(type: "all"),
                  _rewardList(type: "earned"),
                  _rewardList(type: "used"),
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

  // String getMembership(int totalCoins) {
  //   if (totalCoins >= 7500) return "Platinum";
  //   if (totalCoins >= 5000) return "Gold";
  //   if (totalCoins >= 2500) return "Silver";
  //   return "Basic";
  // }

  // Color getMembershipColor(String level) {
  //   switch (level) {
  //     case "Silver":
  //       return Colors.blueGrey.shade200;
  //     case "Gold":
  //       return Colors.amber;
  //     case "Platinum":
  //       return Colors.deepPurple;
  //     default:
  //       return Colors.white;
  //   }
  // }

  LinearGradient getMembershipGradient(String level) {
    switch (level.toUpperCase()) {
      case "SILVER":
        return const LinearGradient(
          colors: [
            Color(0xFF9CA3AF),
            Color(0xFF6B7280),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case "GOLD":
        return const LinearGradient(
          colors: [
            Color(0xFFFFA000), // rich dark gold
            Color(0xFFFF6F00), // deep amber
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case "PLATINUM":
        return const LinearGradient(
          colors: [
            Color(0xFF6A5ACD),
            Color(0xFF483D8B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      default: // BASIC
        return const LinearGradient(
          colors: [
            mainColor,
            secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
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
            child: Center(
              child: SpinKitThreeBounce(
                color: mainColor,
                size: 40,
              ),
            ));
      }

      final membership = summary.membership; // backend-driven

      final style = getMembershipStyle(membership);
      final cardGradient = getMembershipGradient(membership);
      return Stack(
        children: [
          // 🔹 MAIN CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(20),
              // boxShadow: [
              //   BoxShadow(
              //     color: mainColor.withOpacity(0.35),
              //     blurRadius: 14,
              //     offset: const Offset(0, 8),
              //   ),
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      "My Wallet",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// BALANCE (CENTERED)
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/coin.png",
                            width: 36,
                            height: 36,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${summary.balance}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Available Coins",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// PROGRESS
                _membershipProgress(summary),

                const SizedBox(height: 18),

                /// STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _walletStat(
                      label: "Total Earned Coins",
                      value: "${summary.totalCredits}",
                    ),
                    _walletStat(
                      label: "Used Coins",
                      value: "${summary.totalDebits ?? 0}",
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🔥 MEMBERSHIP BADGE (FLOATING CORNER)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                summary.membership.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: style.text,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _membershipProgress(WalletSummary summary) {
    // 🔥 Remove BASIC since it's default
    final levels = Map<String, int>.from(summary.levels)..remove("BASIC");
    final int coins = summary.totalCredits ?? 0;
    // Sort remaining levels
    final sortedLevels = levels.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Find next level
    MapEntry<String, int>? nextLevel;
    for (final level in sortedLevels) {
      if (coins < level.value) {
        nextLevel = level;
        break;
      }
    }

    // Already at highest level
    if (nextLevel == null) {
      return const Text(
        "🎉 Highest Membership Achieved",
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }

    final progress = coins / nextLevel.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          "$coins / ${nextLevel.value} → ${capitalizeEachWord(nextLevel.key)}",
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
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
        Row(
          children: [
            // Container(
            //   width: 30,
            //   height: 30,
            //   padding: const EdgeInsets.all(6),
            //   // decoration: BoxDecoration(
            //   //   color: Colors.white.withOpacity(0.2),
            //   //   shape: BoxShape.circle,
            //   // ),
            //   child: Image.asset(
            //     "assets/coin.png",
            //     fit: BoxFit.contain,
            //   ),
            // ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _referralCodeCard(BuildContext context) {
    return Obx(() {
      if (customerController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: mainColor),
        );
      }

      final customer = customerController.customer.value;

      if (customer == null) {
        return const Text("Customer data not available");
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mainColor.withOpacity(0.4)),
        ),
        child: Stack(
          children: [
            /// Share Icon (Top Right)
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => _shareOnWhatsApp(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share,
                    size: 18,
                    color: mainColor,
                  ),
                ),
              ),
            ),

            /// Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Your Referral Code",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  capitalizeEachWord(customer.fullName),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.08), // soft background
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        customer.referId ?? "",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          final referralText =
                              "NGK Registration Referral Code: ${customer.referId ?? ""}";

                          Clipboard.setData(
                            ClipboardData(text: referralText),
                          );

                          ScaffoldMessageSnackbar.show(
                            context: context,
                            message: "Referral code copied",
                            type: SnackbarType.success,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.copy,
                            size: 18,
                            color: mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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

class MembershipStyle {
  final Color background;
  final Color text;

  MembershipStyle(this.background, this.text);
}

MembershipStyle getMembershipStyle(String level) {
  switch (level) {
    case "Silver":
      return MembershipStyle(
        const Color(0xFFE5E7EB), // soft silver
        const Color(0xFF374151), // dark text
      );

    case "Gold":
      return MembershipStyle(
        const Color(0xFFFFD54F), // gold
        const Color(0xFF4E342E), // deep brown
      );

    case "Platinum":
      return MembershipStyle(
        const Color(0xFF6A5ACD), // royal purple
        Colors.white,
      );

    default: // Basic
      return MembershipStyle(
        Colors.white.withOpacity(0.25),
        Colors.white,
      );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
