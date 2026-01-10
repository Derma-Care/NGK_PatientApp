import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:cutomer_app/NGK/Packges/PackageModel.dart';

class PaymentModal {
  final String clinicId;

  final String serviceId; // procedureId / packageId / cardId
  final String serviceType; // PROCEDURE / PACKAGE / CARD

  final double price;
  final double consultationFee;

  final double gst;
  final double gstAmount;

  final double taxPercentage;
  final double taxAmount;

  final double discountPercentage;
  final double discountAmount;

  final double platformFee;
  final double finalCost;

  final double ngkDiscountPercentage;
  final double ngkDiscountAmount;

  final double totalDiscountAmount;
  final double totalDiscountedAmount;
  final double totalDiscountPercentage;
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
    required this.platformFee,
    required this.finalCost,
    required this.ngkDiscountPercentage,
    required this.ngkDiscountAmount,
    required this.totalDiscountAmount,
    required this.totalDiscountedAmount,
    required this.totalDiscountPercentage,
  });

  // ================= FACTORY HELPERS =================

  /// 🔹 From Procedure
  factory PaymentModal.fromProcedure(ProcedureListModal p) {
    return PaymentModal(
        clinicId: p.clinicId,
        serviceId: p.procedureId,
        serviceType: "PROCEDURE",
        price: p.price,
        consultationFee: p.consultationFee,
        gst: p.gst,
        gstAmount: p.gstAmount,
        taxPercentage: p.taxPercentage,
        taxAmount: p.taxAmount,
        discountPercentage: p.totalDiscountPercentage,
        discountAmount: p.totalDiscountAmount,
        platformFee: 10,
        finalCost: p.finalCost,
        ngkDiscountPercentage: p.ngkDiscountPercentage,
        ngkDiscountAmount: p.ngkDiscountAmount,
        totalDiscountAmount: p.totalDiscountAmount,
        totalDiscountedAmount: p.totalDiscountedAmount,
        totalDiscountPercentage: p.totalDiscountPercentage);
  }

  // /// 🔹 From Package
  factory PaymentModal.fromPackage(PackageModel p) {
    return PaymentModal(
        clinicId: p.clinicId,
        serviceId: p.packageId,
        serviceType: "PACKAGE",
        price: p.price,
        consultationFee: p.consultationFee,
        gst: p.gst,
        gstAmount: p.gstAmount,
        taxPercentage: p.taxPercentage,
        taxAmount: p.taxAmount,
        discountPercentage: p.discountPercentage,
        discountAmount: p.totalDiscountAmount,
        platformFee: 10,
        finalCost: p.finalCost,
        ngkDiscountPercentage: p.ngkDiscountPercentage,
        ngkDiscountAmount: p.ngkDiscountAmount,
        totalDiscountAmount: p.totalDiscountAmount,
        totalDiscountedAmount: p.totalDiscountedAmount,
        totalDiscountPercentage: p.totalDiscountPercentage);
  }

  // ================= JSON SUPPORT =================

  /// 🔹 From API / JSON
  factory PaymentModal.fromJson(Map<String, dynamic> json) {
    return PaymentModal(
      clinicId: json['clinicId'],
      serviceId: json['serviceId'],
      serviceType: json['serviceType'],
      price: (json['price'] as num).toDouble(),
      consultationFee: (json['consultationFee'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
      gstAmount: (json['gstAmount'] as num).toDouble(),
      taxPercentage: (json['taxPercentage'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
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
    };
  }
}
