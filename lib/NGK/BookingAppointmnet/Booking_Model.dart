class BookingModel {
  final String bookingId;
  final String? customerId;
  final String mobileNumber;
  final String? fullName;
  final String serviceType; // procedure / package
  final String? serviceId;
  final String? serviceName;
  final String? hospitalLogo;
  final String? clinicId;

  final double? consultationFee;
  final double? gstAmount;
  final double? gst;

  final double? taxAmount;
  final double? taxPercentage;

  final String clinicName;
  final String clinicAddress;

  final String appointmentDate;

  final double price;
  final double discount;
  final double discountAmount;
  final double finalAmount;

  final String paymentType;

  final String paymentStatus;
  final double partialAmount;
  final double dueAmount;
  final double partialPaymentPercentage;
  final String? paymentMode;
  

  final String status;
  final bool? isRated;
  final List<ProcedureSittingModel>? procedures; // ✅ nullable
  BookingModel({
    required this.bookingId,
    this.fullName,
    this.customerId,
    this.consultationFee,
    this.gstAmount,
    this.gst,
    this.taxAmount,
    this.taxPercentage,
    required this.mobileNumber,
    required this.serviceType,
    this.serviceName,
    this.serviceId,
    this.clinicId,
    required this.clinicName,
    required this.clinicAddress,
    required this.appointmentDate,
    required this.price,
    required this.discount,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentType,
    required this.status,
    required this.paymentStatus,
    required this.partialAmount,
    required this.dueAmount,
    required this.partialPaymentPercentage,
    this.paymentMode,
    this.isRated,
    this.procedures,
    this.hospitalLogo,
  });

  Map<String, dynamic> toJson() {
    return {
      "bookingId": bookingId,
      "hospitalLogo": hospitalLogo,
      "fullName": fullName,
      "customerId": customerId,
      "mobileNumber": mobileNumber,
      "serviceType": serviceType,
      "serviceId": serviceId,
      "serviceName": serviceName,
      "clinicId": clinicId,
      "clinicName": clinicName,
      "clinicAddress": clinicAddress,
      "appointmentDate": appointmentDate,
      "price": price,
      "discount": discount,
      "discountAmount": discountAmount,
      "finalAmount": finalAmount,
      "paymentMethod": paymentType,
      "status": status,
      "isRated": isRated,
      "consultationFee": consultationFee,
      "gstAmount": gstAmount,
      "gst": gst,
      "taxAmount": taxAmount,
      "taxPercentage": taxPercentage,
      "paymentStatus": paymentStatus,
      "partialAmount": partialAmount,
      "dueAmount": dueAmount,
      "partialPaymentPercentage": partialPaymentPercentage,
      "paymentMode": paymentMode,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'],
      hospitalLogo: json['hospitalLogo'],
      fullName: json['fullName'],
      paymentMode: json['paymentMode'],
      isRated: json['isRated'],
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      customerId: json['customerId'],
      mobileNumber: json['mobileNumber'],
      serviceType: json['serviceType'],
      serviceName: json['serviceName'],
      serviceId: json['serviceId'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      clinicAddress: json['clinicAddress'],
      appointmentDate: json['appointmentDate'],
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),

      paymentStatus: json['paymentStatus'],
      partialAmount: (json['partialAmount'] ?? 0).toDouble(),
      dueAmount: (json['dueAmount'] ?? 0).toDouble(),
      partialPaymentPercentage:
          (json['partialPaymentPercentage'] ?? 0).toDouble(),

      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
      paymentType: json['paymentType'],
      status: json['status'],

      // ✅ THIS IS THE MISSING PART
      procedures: (json['procedures'] as List?)
          ?.map((e) => ProcedureSittingModel.fromJson(e))
          .toList(),
    );
  }
}

class ProcedureSittingModel {
  final String procedureName;
  final int noOfSittings;

  ProcedureSittingModel({
    required this.procedureName,
    required this.noOfSittings,
  });

  factory ProcedureSittingModel.fromJson(Map<String, dynamic> json) {
    return ProcedureSittingModel(
      procedureName: json['procedureName'] ?? '',
      noOfSittings: json['noOfSittings'] ?? 0,
    );
  }
}
