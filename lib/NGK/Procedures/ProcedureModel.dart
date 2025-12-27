// class ProcedureListmodel {
//   final String hospitalId;
//   final String subServiceId;
//   final String subServiceName;
//   // final String serviceId;
//   // final String serviceName;
//   // final String categoryName;
//   // final String categoryId;
//   final String viewDescription;
//   final String subServiceImage;
//   final String minTime;

//   final List<Map<String, dynamic>> preProcedureQA;
//   final List<Map<String, dynamic>> procedureQA;
//   final List<Map<String, dynamic>> postProcedureQA;

//   final double price;
//   final int discountPercentage;
//   final double discountAmount;
//   final double gst;
//   final double gstAmount;
//   final double consultationFee;
//   final double taxPercentage;
//   final double taxAmount;
//   final double platformFee;
//   final double discountedCost;
//   final double finalCost;

//   ProcedureListmodel({
//     required this.hospitalId,
//     required this.subServiceId,
//     required this.subServiceName,
//     // required this.serviceId,
//     // required this.serviceName,
//     // required this.categoryName,
//     // required this.categoryId,
//     required this.viewDescription,
//     required this.subServiceImage,
//     required this.minTime,
//     required this.preProcedureQA,
//     required this.procedureQA,
//     required this.postProcedureQA,
//     required this.price,
//     required this.discountPercentage,
//     required this.discountAmount,
//     required this.gst,
//     required this.gstAmount,
//     required this.consultationFee,
//     required this.taxPercentage,
//     required this.taxAmount,
//     required this.platformFee,
//     required this.discountedCost,
//     required this.finalCost,

//   });

//   factory ProcedureListmodel.fromJson(Map<String, dynamic> json) {
//     return ProcedureListmodel(
//       hospitalId: json["hospitalId"],
//       subServiceId: json["subServiceId"],
//       subServiceName: json["subServiceName"],
//       // serviceId: json["serviceId"],
//       // serviceName: json["serviceName"],
//       // categoryName: json["categoryName"],
//       // categoryId: json["categoryId"],
//       viewDescription: json["viewDescription"],
//       subServiceImage: json["subServiceImage"],
//       minTime: json["minTime"],
//       preProcedureQA: List<Map<String, dynamic>>.from(json["preProcedureQA"]),
//       procedureQA: List<Map<String, dynamic>>.from(json["procedureQA"]),
//       postProcedureQA: List<Map<String, dynamic>>.from(json["postProcedureQA"]),
//       price: (json["price"] ?? 0).toDouble(),
//       discountPercentage: json["discountPercentage"],
//       discountAmount: (json["discountAmount"] ?? 0).toDouble(),
//       gst: (json["gst"] ?? 0).toDouble(),
//       gstAmount: (json["gstAmount"] ?? 0).toDouble(),
//       consultationFee: (json["consultationFee"] ?? 0).toDouble(),
//       taxPercentage: (json["taxPercentage"] ?? 0).toDouble(),
//       taxAmount: (json["taxAmount"] ?? 0).toDouble(),
//       platformFee: (json["platformFee"] ?? 0).toDouble(),
//       discountedCost: (json["discountedCost"] ?? 0).toDouble(),
//       finalCost: (json["finalCost"] ?? 0).toDouble(),

//     );
//   }
// }
class ProcedureListModal {
  final String procedureId;
  final String procedureName;
  final String clinicId;
  final String description;
  final String procedureImage;
  final String? procedureLink;

  final List<Map<String, List<String>>> preProcedureQA;
  final List<Map<String, List<String>>> procedureQA;
  final List<Map<String, List<String>>> postProcedureQA;

  final int sittings;
  final String minTime;

  final double price;
  final double discountPercentage;
  final double discountAmount;

  final double taxPercentage;
  final double taxAmount;

  final double gst;
  final double gstAmount;

  final double consultationFee;
  final double discountedCost;
  final double clinicPay;
  final double finalCost;

  final String? offerStart;
  final String? offerValidDate;
  final bool offerActive;

  final double ngkDiscountPercentage;
  final double ngkDiscountAmount;
  final double totalDiscountPercentage;
  final double totalDiscountAmount;

  ProcedureListModal({
    required this.procedureId,
    required this.procedureName,
    required this.clinicId,
    required this.description,
    required this.procedureImage,
    this.procedureLink,
    required this.preProcedureQA,
    required this.procedureQA,
    required this.postProcedureQA,
    required this.sittings,
    required this.minTime,
    required this.price,
    required this.discountPercentage,
    required this.discountAmount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.gst,
    required this.gstAmount,
    required this.consultationFee,
    required this.discountedCost,
    required this.clinicPay,
    required this.finalCost,
    this.offerStart,
    this.offerValidDate,
    required this.offerActive,
    required this.ngkDiscountPercentage,
    required this.ngkDiscountAmount,
    required this.totalDiscountPercentage,
    required this.totalDiscountAmount,
  });

  factory ProcedureListModal.fromJson(Map<String, dynamic> json) {
    return ProcedureListModal(
      procedureId: json['procedureId'] ?? '',
      procedureName: json['procedureName'] ?? '',
      clinicId: json['clinicId'] ?? '',
      description: json['description'] ?? '',
      procedureImage: json['procedureImage'] ?? '',
      procedureLink: json['procedureLink'],
      preProcedureQA: _parseQA(json['preProcedureQA']),
      procedureQA: _parseQA(json['procedureQA']),
      postProcedureQA: _parseQA(json['postProcedureQA']),
      sittings: json['sittings'] ?? 0,
      minTime: json['minTime'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      discountedCost: (json['discountedCost'] ?? 0).toDouble(),
      clinicPay: (json['clinicPay'] ?? 0).toDouble(),
      finalCost: (json['finalCost'] ?? 0).toDouble(),
      offerStart: json['offerStart']  ??"",
      offerValidDate: json['offerValidDate']  ?? "",
      offerActive: json['offerActive'] ?? false,
      ngkDiscountPercentage: (json['ngkDiscountPercentage'] ?? 0).toDouble(),
      ngkDiscountAmount: (json['ngkDiscountAmount'] ?? 0).toDouble(),
      totalDiscountPercentage:
          (json['totalDiscountPercentage'] ?? 0).toDouble(),
      totalDiscountAmount: (json['totalDiscountAmount'] ?? 0).toDouble(),
    );
  }

  /// Helper to parse QA arrays
  static List<Map<String, List<String>>> _parseQA(dynamic data) {
    if (data == null) return [];
    return List<Map<String, List<String>>>.from(
      data.map(
        (e) => Map<String, List<String>>.from(
          e.map(
            (key, value) => MapEntry(key.toString(), List<String>.from(value)),
          ),
        ),
      ),
    );
  }
}
