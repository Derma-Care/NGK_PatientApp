class ReferredCustomerModel {
  final String customerId;
  final String fullName;

  ReferredCustomerModel({
    required this.customerId,
    required this.fullName,
  });

  factory ReferredCustomerModel.fromJson(Map<String, dynamic> json) {
    return ReferredCustomerModel(
      customerId: json['customerId'],
      fullName: json['fullName'],
    );
  }
}
