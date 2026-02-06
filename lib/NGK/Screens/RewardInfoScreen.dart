import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

class RewardInfoScreen extends StatelessWidget {
  const RewardInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reward Coins"),
        backgroundColor: mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🎁 Reward Coins & Membership Program",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Earn reward coins and use them to save money on bookings. "
              "Your membership and coin value increase automatically as you earn more coins.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _infoTile(
                "🎉 Registration Bonus", "Get 100 reward coins instantly"),
            _infoTile("🤝 Referral Rewards", "Earn 200 coins per referral"),
            _infoTile("💳 Booking Rewards", "1 coin for every ₹100 spent"),
            _infoTile("💸 Redeem Coins", "Use coins for up to 50% of booking"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _showRewardDetailsModal(context),
                child: const Text("Know More", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle, color: mainColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }

  // 🔥 FULL DETAILS MODAL
  void _showRewardDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween(begin: 0.9, end: 1),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle("🪙 What are Reward Coins?"),
                  _bullet(
                      "Earned through registration, referrals, and bookings"),
                  _bullet("Coins can pay up to 50% of booking amount"),
                  const SizedBox(height: 16),
                  _sectionTitle("🎉 Registration Bonus"),
                  _bullet("Every user gets 100 reward coins on registration"),
                  const SizedBox(height: 16),
                  _sectionTitle("🏷️ Membership Levels & Coin Value"),
                  _membershipRow("Basic", "Up to 2,500 coins", "₹1 / coin"),
                  _membershipRow("Silver", "2,500 – 5,000", "₹2 / coin"),
                  _membershipRow("Gold", "5,000 – 7,500", "₹3 / coin"),
                  _membershipRow("Platinum", "7,500+", "₹4 / coin"),
                  const SizedBox(height: 6),
                  _bullet("Membership upgrades happen automatically"),
                  const SizedBox(height: 16),
                  _sectionTitle("🤝 Referral Rewards"),
                  _bullet("Earn 200 coins after referral’s first booking"),
                  _bullet("No limit on referrals"),
                  const SizedBox(height: 16),
                  _sectionTitle("💳 Booking Rewards"),
                  _bullet("Earn 1 coin for every ₹100 spent"),
                  _example("₹1,000 booking → 10 coins"),
                  const SizedBox(height: 16),
                  _sectionTitle("💸 Redeem Rules"),
                  _bullet("Use coins for up to 50% of booking"),
                  _bullet("Remaining amount paid normally"),
                  _example("₹1,000 booking → max ₹500 via coins"),
                  _example("Gold member → 167 coins = ₹500"),
                  const SizedBox(height: 16),
                  _sectionTitle("🔁 Membership Upgrade Example"),
                  _bullet("2,500 coins → Silver"),
                  _bullet("5,000 coins → Gold"),
                  _bullet("7,500+ coins → Platinum"),
                  const SizedBox(height: 16),
                  _sectionTitle("📌 Important Notes"),
                  _bullet("Coins cannot be converted to cash"),
                  _bullet("Coins usable only for bookings"),
                  _bullet("Membership based on total earned coins"),
                  _bullet("Max 50% discount per booking"),
                  const SizedBox(height: 20),
                  _sectionTitle("✅ Simple Summary"),
                  _bullet("Register → Get 100 coins"),
                  _bullet("Refer → Earn 200 coins"),
                  _bullet("Book → Earn coins"),
                  _bullet("Use coins → Save money"),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Got it 👍"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔹 Helpers
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text("• $text"),
    );
  }

  Widget _example(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(
        "👉 $text",
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
    );
  }

  Widget _membershipRow(String level, String range, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(level, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(range),
          Text(value),
        ],
      ),
    );
  }
}
