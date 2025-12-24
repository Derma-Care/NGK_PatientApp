class BookingModel {
  final String bookingId;
  final String customerId;
  final String mobileNumber;

  final String bookingType; // procedure / package
  final String? serviceId;
  final String? subServiceId;

  final String title;

  final String clinicId;
  final String clinicName;
  final String clinicAddress;

  final String bookingDate;

  final double price;
  final int discountPercentage;
  final double discountAmount;
  final double finalAmount;

  final String paymentMethod;
  final String status;
  final bool? isRated;
final List<ProcedureSittingModel>? procedures; // ✅ nullable
  BookingModel({
    required this.bookingId,
    required this.customerId,
    required this.mobileNumber,
    required this.bookingType,
    this.serviceId,
    this.subServiceId,
    required this.title,
    required this.clinicId,
    required this.clinicName,
    required this.clinicAddress,
    required this.bookingDate,
    required this.price,
    required this.discountPercentage,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.status,
    this.isRated,
    this.procedures,
  });

  Map<String, dynamic> toJson() {
    return {
      "bookingId": bookingId,
      "customerId": customerId,
      "mobileNumber": mobileNumber,
      "bookingType": bookingType,
      "serviceId": serviceId,
      "subServiceId": subServiceId,
      "title": title,
      "clinicId": clinicId,
      "clinicName": clinicName,
      "clinicAddress": clinicAddress,
      "bookingDate": bookingDate,
      "price": price,
      "discountPercentage": discountPercentage,
      "discountAmount": discountAmount,
      "finalAmount": finalAmount,
      "paymentMethod": paymentMethod,
      "status": status,
      "isRated": isRated
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'],
      isRated: json['isRated'],
      customerId: json['customerId'],
      mobileNumber: json['mobileNumber'],
      bookingType: json['bookingType'],
      serviceId: json['serviceId'],
      subServiceId: json['subServiceId'],
      title: json['title'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      clinicAddress: json['clinicAddress'],
      bookingDate: json['bookingDate'],
      price: (json['price'] ?? 0).toDouble(),
      discountPercentage: json['discountPercentage'],
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
    );
  }
}
class ProcedureSittingModel {
  final String procedureName;
  final int sittings;

  ProcedureSittingModel({
    required this.procedureName,
    required this.sittings,
  });
}
