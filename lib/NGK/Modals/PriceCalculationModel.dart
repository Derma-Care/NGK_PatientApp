class PriceCalculationModel {
  final double originalFinalAmount;
  final double finalAmount;
  final int appliedPoints;
  final int maxRedeemablePoints;
  final int availablePoints;

  PriceCalculationModel({
    required this.originalFinalAmount,
    required this.finalAmount,
    required this.appliedPoints,
    required this.maxRedeemablePoints,
    required this.availablePoints,
  });

  factory PriceCalculationModel.fromJson(Map<String, dynamic> json) {
    return PriceCalculationModel(
      originalFinalAmount: json['originalFinalAmount'].toDouble(),
      finalAmount: json['finalAmount'].toDouble(),
      appliedPoints: json['appliedPoints'],
      maxRedeemablePoints: json['maxRedeemablePoints'],
      availablePoints: json['availablePoints'],
    );
  }
}
