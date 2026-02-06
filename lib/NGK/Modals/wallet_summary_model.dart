class WalletSummary {
  final int totalCredits;
  final int totalDebits;
  final int balance;
  final int coinValue;
  final String membership;
  final double balanceValue;
  final Map<String, int> levels;

  WalletSummary({
    required this.totalCredits,
    required this.totalDebits,
    required this.balance,
    required this.coinValue,
    required this.membership,
    required this.balanceValue,
    required this.levels,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      totalCredits: json['totalCredits'] ?? 0,
      totalDebits: json['totalDebits'] ?? 0,
      balance: json['balance'] ?? 0,
      coinValue: json['coinValue'] ?? 0,
      membership: json['membership']?.toString() ?? '',
      balanceValue: (json['balanceValue'] ?? 0).toDouble(),
      levels: Map<String, int>.from(json['levels'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCredits': totalCredits,
      'totalDebits': totalDebits,
      'balance': balance,
      'coinValue': coinValue,
      'membership': membership,
      'balanceValue': balanceValue,
      'levels': levels,
    };
  }
}
