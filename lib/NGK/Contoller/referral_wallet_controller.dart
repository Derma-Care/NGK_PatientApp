import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/Modals/wallet_summary_model.dart';
import 'package:cutomer_app/NGK/Modals/wallet_transaction_model.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';

class ReferralWalletController extends GetxController {
  final isLoading = false.obs;

  final transactions = <WalletTransaction>[].obs;
  final walletSummary = Rxn<WalletSummary>();

  /// 🔹 Fetch Wallet Summary
  Future<void> fetchWalletSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobileNumber');

    final api = Get.find<ApiProvider>().dio;
    final endpoint = "$booking_Url/wallet/$mobile/summary";

    debugPrint("📤 [WALLET SUMMARY] URL: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    debugPrint("📥 [WALLET SUMMARY] STATUS: ${response.statusCode}");
    debugPrint("📥 [WALLET SUMMARY] BODY: ${response.data}");

    if (response.statusCode == 200) {
      final jsonData = response.data;
      walletSummary.value =
          WalletSummary.fromJson(jsonData['data']);
    }
  }

  /// 🔹 Fetch Wallet Transactions
  Future<void> fetchTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobileNumber');

    final api = Get.find<ApiProvider>().dio;
    final endpoint = "$booking_Url/wallet/$mobile/transactions";

    debugPrint(
        "📤 [WALLET TRANSACTIONS] URL: ${api.options.baseUrl}$endpoint");

    final response = await api.get(endpoint);

    debugPrint(
        "📥 [WALLET TRANSACTIONS] STATUS: ${response.statusCode}");
    debugPrint(
        "📥 [WALLET TRANSACTIONS] BODY: ${response.data}");

    if (response.statusCode == 200) {
      final jsonData = response.data;
      transactions.value = (jsonData['data'] as List)
          .map<WalletTransaction>(
              (e) => WalletTransaction.fromJson(e))
          .toList();
    }
  }

  /// 🔹 Combined Call
  Future<void> loadWallet() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchWalletSummary(),
        fetchTransactions(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }
}
