import 'package:get/get.dart';

class ReferralWalletController extends GetxController {
  /// Rewards list (can later come from API)
  final rewards = <Map<String, dynamic>>[
    {"type": "earned", "amount": 500, "date": "10 July 2025"},
    {"type": "used", "amount": 300, "date": "12 July 2025"},
    {"type": "earned", "amount": 500, "date": "15 July 2025"},
  ].obs;

  /// Wallet balance (auto-calculated)
  int get walletBalance {
    return rewards.fold(0, (total, item) {
      if (item["type"] == "earned") {
        return total + (item["amount"] as int);
      } else {
        return total - (item["amount"] as int);
      }
    });
  }

  /// Add reward
  void addReward(int amount) {
    rewards.add({
      "type": "earned",
      "amount": amount,
      "date": DateTime.now().toString().substring(0, 10),
    });
  }

  /// Use reward
  void useReward(int amount) {
    rewards.add({
      "type": "used",
      "amount": amount,
      "date": DateTime.now().toString().substring(0, 10),
    });
  }
}
