import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:cutomer_app/NGK/Packges/PackageModel.dart';

class PaymentModal {
  final String clinicId;

  final String serviceId;
  final String serviceType;

  final double price;
  final double consultationFee;

  final double gst;
  final double gstAmount;

  final double taxPercentage;
  final double taxAmount;

  final double discountPercentage;
  final double discountAmount;

  final double finalCost;

  final double ngkDiscountPercentage;
  final double ngkDiscountAmount;

  final double totalDiscountAmount;
  final double totalDiscountedAmount;
  final double totalDiscountPercentage;
  final String? paymentType;
  final double? partialPaymentPercentage;
  final double? platformFeePercentage;
  final double? platformFee;
  final bool? offerActive;
  PaymentModal({
    required this.clinicId,
    required this.serviceId,
    required this.serviceType,
    required this.price,
    required this.consultationFee,
    required this.gst,
    required this.gstAmount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.discountPercentage,
    required this.discountAmount,
    this.platformFee,
    required this.finalCost,
    required this.ngkDiscountPercentage,
    required this.ngkDiscountAmount,
    required this.totalDiscountAmount,
    required this.totalDiscountedAmount,
    required this.totalDiscountPercentage,
    this.paymentType,
    this.offerActive,
    this.partialPaymentPercentage,
    this.platformFeePercentage,
  });

  // ================= FACTORY HELPERS =================

  /// 🔹 From Procedure
  factory PaymentModal.fromProcedure(ProcedureListModal p) {
    return PaymentModal(
      clinicId: p.clinicId ,
      serviceId: p.procedureId,
      serviceType: "PROCEDURE",

      price: p.price,
      consultationFee: p.consultationFee ,

      gst: p.gst ,
      gstAmount: p.gstAmount ,

      taxPercentage: p.taxPercentage ,
      taxAmount: p.taxAmount ,

      discountPercentage: p.totalDiscountPercentage ,
      discountAmount: p.totalDiscountAmount ,

      finalCost: p.finalCost ,

      ngkDiscountPercentage: p.ngkDiscountPercentage ,
      ngkDiscountAmount: p.ngkDiscountAmount ,

      totalDiscountAmount: p.totalDiscountAmount,
      totalDiscountedAmount: p.totalDiscountedAmount ,
      totalDiscountPercentage: p.totalDiscountPercentage ,

      // 🔥 FORCE SAFE DEFAULTS FOR PROCEDURE
      paymentType: "FULL_PAYMENT",
      partialPaymentPercentage: 0,

      platformFee: p.platformFee ?? 0,
      platformFeePercentage: p.platformFeePercentage ?? 0,
      offerActive:p.offerActive ,
    );
  }

  // /// 🔹 From Package
  factory PaymentModal.fromPackage(PackageModel p) {
    return PaymentModal(
      clinicId: p.clinicId ,
      serviceId: p.packageId ,
      serviceType: "PACKAGE",
      price: p.price ,
      consultationFee: p.consultationFee ,
      gst: p.gst ,
      gstAmount: p.gstAmount ,
      taxPercentage: p.taxPercentage ,
      taxAmount: p.taxAmount ,
      discountPercentage: p.discountPercentage ,
      discountAmount: p.totalDiscountAmount,
      finalCost: p.finalCost ,
      ngkDiscountPercentage: p.ngkDiscountPercentage ,
      ngkDiscountAmount: p.ngkDiscountAmount ,
      totalDiscountAmount: p.totalDiscountAmount ,
      totalDiscountedAmount: p.totalDiscountedAmount ,
      totalDiscountPercentage: p.totalDiscountPercentage ,
      paymentType: p.paymentType ?? "FULL_PAYMENT",
      partialPaymentPercentage: p.partialPaymentPercentage ?? 0,
      platformFee: p.platformFee ?? 0,
      platformFeePercentage: p.platformFeePercentage ?? 0,
      offerActive:p.offerActive ,
    );
  }

  // ================= JSON SUPPORT =================

  /// 🔹 From API / JSON
  factory PaymentModal.fromJson(Map<String, dynamic> json) {
    return PaymentModal(
      clinicId: json['clinicId'],
      offerActive: json['offerActive'],
      serviceId: json['serviceId'],
      paymentType: json['paymentType'],
      partialPaymentPercentage:
          (json['partialPaymentPercentage'] as num?)?.toDouble() ?? 0,
      serviceType: json['serviceType'],
      price: (json['price'] as num).toDouble(),
      consultationFee: (json['consultationFee'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
      gstAmount: (json['gstAmount'] as num).toDouble(),
      taxPercentage: (json['taxPercentage'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      platformFeePercentage: (json['platformFeePercentage'] ?? 0).toDouble(),
      finalCost: (json['finalCost'] as num).toDouble(),
      ngkDiscountPercentage: (json['ngkDiscountPercentage'] as num).toDouble(),
      ngkDiscountAmount: (json['ngkDiscountAmount'] as num).toDouble(),
      totalDiscountAmount: (json['totalDiscountAmount'] as num).toDouble(),
      totalDiscountedAmount: (json['totalDiscountedAmount'] as num).toDouble(),
      totalDiscountPercentage:
          (json['totalDiscountPercentage'] as num).toDouble(),
    );
  }

  /// 🔹 Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      "clinicId": clinicId,
      "offerActive": offerActive,
      "serviceId": serviceId,
      "serviceType": serviceType,
      "price": price,
      "consultationFee": consultationFee,
      "gst": gst,
      "gstAmount": gstAmount,
      "taxPercentage": taxPercentage,
      "taxAmount": taxAmount,
      "discountPercentage": discountPercentage,
      "discountAmount": discountAmount,
      "platformFee": platformFee,
      "finalCost": finalCost,
      "ngkDiscountPercentage": ngkDiscountPercentage,
      "ngkDiscountAmount": ngkDiscountAmount,
      "totalDiscountAmount": totalDiscountAmount,
      "totalDiscountedAmount": totalDiscountedAmount,
      "totalDiscountPercentage": totalDiscountPercentage,
      "paymentType": paymentType,
      "partialPaymentPercentage": partialPaymentPercentage,
      "platformFeePercentage": platformFeePercentage,
    };
  }
}
