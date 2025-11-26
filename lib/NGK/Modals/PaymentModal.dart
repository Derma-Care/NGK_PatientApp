class PaymentModal {
  final double price;
  final int discountPercentage;
  final double? discountAmount;
  final double? gst;
  final double? gstAmount;
  final double? consultationFee;
  final double? taxPercentage;
  final double? taxAmount;
  final double? platformFee;
  final double? discountedCost;
  final double? finalCost;

  PaymentModal({
    required this.price,
    required this.discountPercentage,
    this.discountAmount,
    this.gst,
    this.gstAmount,
    this.consultationFee,
    this.taxPercentage,
    this.taxAmount,
    this.platformFee,
    this.discountedCost,
    this.finalCost,
  });

  factory PaymentModal.fromJson(Map<String, dynamic> json) {
    return PaymentModal(
      price: (json["price"] ?? 0).toDouble(),
      discountPercentage: json["discountPercentage"],
      discountAmount: (json["discountAmount"] ?? 0).toDouble(),
      gst: (json["gst"] ?? 0).toDouble(),
      gstAmount: (json["gstAmount"] ?? 0).toDouble(),
      consultationFee: (json["consultationFee"] ?? 0).toDouble(),
      taxPercentage: (json["taxPercentage"] ?? 0).toDouble(),
      taxAmount: (json["taxAmount"] ?? 0).toDouble(),
      platformFee: (json["platformFee"] ?? 0).toDouble(),
      discountedCost: (json["discountedCost"] ?? 0).toDouble(),
      finalCost: (json["finalCost"] ?? 0).toDouble(),
    );
  }
}
