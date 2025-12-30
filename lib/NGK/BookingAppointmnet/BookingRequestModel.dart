class BookingRequestModel {
  final String clinicId;
  final String customerId;

  final String serviceId; // procedureId or packageId
  final String serviceType; // PROCEDURE / PACKAGE

  final String paymentType; // ONLINE / CASH
  final double coinsUsed;
  final String appointmentDate; // yyyy-MM-dd

  BookingRequestModel({
    required this.clinicId,
    required this.customerId,
    required this.serviceId,
    required this.serviceType,
    required this.paymentType,
    required this.coinsUsed,
    required this.appointmentDate,
  });

  

  Map<String, dynamic> toJson() {
    return {
      "clinicId": clinicId,
      "customerId": customerId,
      "serviceId": serviceId,
      "serviceType": serviceType,
      "paymentType": paymentType,
      "coinsUsed": coinsUsed,
      "appointmentDate": appointmentDate,
    };
  }
}
