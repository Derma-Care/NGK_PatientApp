class PackageModel {
  final String packageId;
  final String packageName;
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String clinicRating;
  final String distance;

  final double price;
  final double discountPercentage;
  final double finalCost;

  final double taxPercentage;
  final double taxAmount;
  final double gst;
  final double gstAmount;
  final double consultationFee;
  final double discountedCost;
  final double clinicPay;
  final int sittings;
  final double ngkDiscountPercentage;
  final double ngkDiscountAmount;
  final double totalDiscountPercentage;
  final double totalDiscountAmount;
  final double totalDiscountedAmount;

  final String? offerStart;
  final String? offerValidDate;
  final bool offerActive;

  final List<ProcedureModel> procedures;

  PackageModel({
    required this.packageId,
    required this.packageName,
    required this.clinicId,
    required this.clinicName,
    required this.clinicAddress,
    required this.clinicRating,
    required this.distance,
    required this.price,
    required this.discountPercentage,
    required this.finalCost,
    required this.taxPercentage,
    required this.taxAmount,
    required this.gst,
    required this.gstAmount,
    required this.consultationFee,
    required this.discountedCost,
    required this.clinicPay,
    required this.ngkDiscountPercentage,
    required this.ngkDiscountAmount,
    required this.totalDiscountPercentage,
    required this.totalDiscountAmount,
    required this.totalDiscountedAmount,
    required this.offerStart,
    required this.offerValidDate,
    required this.offerActive,
    required this.procedures,
    required this.sittings,
  });

  factory PackageModel.fromApi(Map<String, dynamic> json) {
    final pkg = json['packageInfo'] ?? {};
    final clinicList = json['clinics'] as List? ?? [];
    final clinic = clinicList.isNotEmpty ? clinicList[0] : {};

    return PackageModel(
      packageId: pkg['packageId'] ?? '',
      packageName: pkg['packageName'] ?? '',
      clinicId: pkg['clinicId'] ?? '',
      clinicName: clinic['name'] ?? '',
      clinicAddress: clinic['address'] ?? '',
      clinicRating: (clinic['hospitalOverallRating'] ?? 0).toString(),
      distance: clinic['distanceInKm'] ?? '',
      price: (pkg['price'] ?? 0).toDouble(),
      discountPercentage: (pkg['discountPercentage'] ?? 0).toDouble(),
      finalCost: (pkg['finalCost'] ?? 0).toDouble(),
      taxPercentage: (pkg['taxPercentage'] ?? 0).toDouble(),
      taxAmount: (pkg['taxAmount'] ?? 0).toDouble(),
      gst: (pkg['gst'] ?? 0).toDouble(),
      gstAmount: (pkg['gstAmount'] ?? 0).toDouble(),
      consultationFee: (pkg['consultationFee'] ?? 0).toDouble(),
      discountedCost: (pkg['discountedCost'] ?? 0).toDouble(),
      clinicPay: (pkg['clinicPay'] ?? 0).toDouble(),
      ngkDiscountPercentage: (pkg['ngkDiscountPercentage'] ?? 0).toDouble(),
      ngkDiscountAmount: (pkg['ngkDiscountAmount'] ?? 0).toDouble(),
      totalDiscountPercentage: (pkg['totalDiscountPercentage'] ?? 0).toDouble(),
      totalDiscountAmount: (pkg['totalDiscountAmount'] ?? 0).toDouble(),
      totalDiscountedAmount: (pkg['totalDiscountedAmount'] ?? 0).toDouble(),
      offerStart: pkg['offerStart'],
      sittings: pkg['sittings'],
      offerValidDate: pkg['offerValidDate'],
      offerActive: pkg['offerActive'] ?? false,
      procedures: (pkg['procedures'] as List? ?? [])
          .map((e) => ProcedureModel.fromJson(e))
          .toList(),
    );
  }
  factory PackageModel.fromListItem(Map<String, dynamic> json) {
    return PackageModel(
      packageId: json['packageId'] ?? '',
      packageName: json['packageName'] ?? '',
      clinicId: json['clinicId'] ?? '',
      clinicName: json['clinicName'] ?? '',
      clinicAddress: json['clinicAddress'] ?? '',
      clinicRating: (json['clinicRating'] ?? '').toString(),
      distance: (json['distance'] ?? '').toString(),
      price: (json['price'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      finalCost: (json['finalCost'] ?? 0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      discountedCost: (json['discountedCost'] ?? 0).toDouble(),
      clinicPay: (json['clinicPay'] ?? 0).toDouble(),
      ngkDiscountPercentage: (json['ngkDiscountPercentage'] ?? 0).toDouble(),
      ngkDiscountAmount: (json['ngkDiscountAmount'] ?? 0).toDouble(),
      totalDiscountPercentage:
          (json['totalDiscountPercentage'] ?? 0).toDouble(),
      totalDiscountAmount: (json['totalDiscountAmount'] ?? 0).toDouble(),
      totalDiscountedAmount: (json['totalDiscountedAmount'] ?? 0).toDouble(),
      offerStart: json['offerStart'],
      offerValidDate: json['offerValidDate'],
      sittings: json['sittings'],
      offerActive: json['offerActive'] ?? false,
      procedures: (json['procedures'] as List? ?? [])
          .map((e) => ProcedureModel.fromJson(e))
          .toList(),
    );
  }
}

class ProcedureModel {
  final String procedureName;
  final int noOfSittings;

  ProcedureModel({
    required this.procedureName,
    required this.noOfSittings,
  });

  factory ProcedureModel.fromJson(Map<String, dynamic> json) {
    return ProcedureModel(
      procedureName: json['procedureName'],
      noOfSittings: (json['noOfSittings'] as num?)?.toInt() ?? 0,
    );
  }
}
