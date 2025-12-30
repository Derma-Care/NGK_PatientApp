class WalletTransaction {
  final String id;
  final int points;
  final String type; // CREDIT / DEBIT
  final String reason;
  final int balanceAfter;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.points,
    required this.type,
    required this.reason,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      points: json['points'],
      type: json['type'],
      reason: json['reason'],
      balanceAfter: json['balanceAfter'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
