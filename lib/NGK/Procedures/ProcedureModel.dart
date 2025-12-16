class ProcedureListmodel {
  final String hospitalId;
  final String subServiceId;
  final String subServiceName;
  final String serviceId;
  final String serviceName;
  final String categoryName;
  final String categoryId;
  final String viewDescription;
  final String subServiceImage;
  final String minTime;

  final List<Map<String, dynamic>> preProcedureQA;
  final List<Map<String, dynamic>> procedureQA;
  final List<Map<String, dynamic>> postProcedureQA;

  final double price;
  final int discountPercentage;
  final double discountAmount;
  final double gst;
  final double gstAmount;
  final double consultationFee;
  final double taxPercentage;
  final double taxAmount;
  final double platformFee;
  final double discountedCost;
  final double finalCost;

  final String? consentFormType;

  ProcedureListmodel({
    required this.hospitalId,
    required this.subServiceId,
    required this.subServiceName,
    required this.serviceId,
    required this.serviceName,
    required this.categoryName,
    required this.categoryId,
    required this.viewDescription,
    required this.subServiceImage,
    required this.minTime,
    required this.preProcedureQA,
    required this.procedureQA,
    required this.postProcedureQA,
    required this.price,
    required this.discountPercentage,
    required this.discountAmount,
    required this.gst,
    required this.gstAmount,
    required this.consultationFee,
    required this.taxPercentage,
    required this.taxAmount,
    required this.platformFee,
    required this.discountedCost,
    required this.finalCost,
      this.consentFormType,
  });

  factory ProcedureListmodel.fromJson(Map<String, dynamic> json) {
    return ProcedureListmodel(
      hospitalId: json["hospitalId"],
      subServiceId: json["subServiceId"],
      subServiceName: json["subServiceName"],
      serviceId: json["serviceId"],
      serviceName: json["serviceName"],
      categoryName: json["categoryName"],
      categoryId: json["categoryId"],
      viewDescription: json["viewDescription"],
      subServiceImage: json["subServiceImage"],
      minTime: json["minTime"],
      preProcedureQA: List<Map<String, dynamic>>.from(json["preProcedureQA"]),
      procedureQA: List<Map<String, dynamic>>.from(json["procedureQA"]),
      postProcedureQA: List<Map<String, dynamic>>.from(json["postProcedureQA"]),
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
      consentFormType: json["consentFormType"],
    );
  }
}
