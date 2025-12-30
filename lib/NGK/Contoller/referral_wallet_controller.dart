import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/Modals/wallet_summary_model.dart';
import 'package:cutomer_app/NGK/Modals/wallet_transaction_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReferralWalletController extends GetxController {
  final isLoading = false.obs;

  final transactions = <WalletTransaction>[].obs;
  final walletSummary = Rxn<WalletSummary>();

  // Future<String?> getMobileNumber() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('mobileNumber');
  // }

  /// 🔹 Fetch Wallet Summary
  Future<void> fetchWalletSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobileNumber');
    final response =
        await http.get(Uri.parse("$booking_Url/wallet/$mobile/summary"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      walletSummary.value = WalletSummary.fromJson(jsonData['data']);
    }
  }

  Future<void> fetchTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobileNumber');
    final response =
        await http.get(Uri.parse("$booking_Url/wallet/$mobile/transactions"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      transactions.value = (jsonData['data'] as List)
          .map((e) => WalletTransaction.fromJson(e))
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
