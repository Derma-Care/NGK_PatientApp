class WalletSummary {
  final int totalCredits;
  final int totalDebits;
  final int balance;

  WalletSummary({
    required this.totalCredits,
    required this.totalDebits,
    required this.balance,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      totalCredits: json['totalCredits'],
      totalDebits: json['totalDebits'],
      balance: json['balance'],
    );
  }
}
