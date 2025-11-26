class CustomerProfileModel {
  final String customerId;
  final String fullName;
  final String mobile;
  final String? email;
  final String? city;
  final String? dob;
  final String? clinicName;
  final String? clinicCityArea;
  final String? dateOfLastVisit;
  final List<String>? serviceType;
  final String? blood;
  final String? registrationCode;
  final String? referBy;
  final String? aadharNumber;
  final String? prescription;
  final String? spinRewardId;
  final String? spinRewardValue;
  final String? spinRewardImage;
  final String? prizePostScreenshot;
  final String? followScreenshot;
  final String? address;
  final bool registrationCodeVerified;
  final bool registrationCompleted;
  final bool spinWheelCompleted;
  final bool userProfileCompleted;

  CustomerProfileModel({
    required this.customerId,
    required this.fullName,
    required this.mobile,
    this.email,
    this.city,
    this.dob,
    this.clinicName,
    this.clinicCityArea,
    this.dateOfLastVisit,
    this.serviceType,
    this.blood,
    this.registrationCode,
    this.referBy,
    this.aadharNumber,
    this.prescription,
    this.spinRewardId,
    this.spinRewardValue,
    this.spinRewardImage,
    this.prizePostScreenshot,
    this.followScreenshot,
    this.address,
    required this.registrationCodeVerified,
    required this.registrationCompleted,
    required this.spinWheelCompleted,
    required this.userProfileCompleted,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      customerId: json["customerId"],
      fullName: json["fullName"],
      mobile: json["mobile"],
      email: json["email"],
      city: json["city"],
      dob: json["dob"],
      clinicName: json["clinicName"],
      clinicCityArea: json["clinicCityArea"],
      dateOfLastVisit: json["dateOfLastVisit"],
      serviceType: json["serviceType"] != null
          ? List<String>.from(json["serviceType"])
          : null,
      blood: json["blood"],
      registrationCode: json["registrationCode"],
      referBy: json["referBy"],
      aadharNumber: json["aadharNumber"],
      prescription: json["prescription"],
      spinRewardId: json["spinRewardId"],
      spinRewardValue: json["spinRewardValue"],
      spinRewardImage: json["spinRewardImage"],
      prizePostScreenshot: json["prizePostScreenshot"],
      followScreenshot: json["followScreenshot"],
      address: json["address"],
      registrationCodeVerified: json["registrationCodeVerified"] ?? false,
      registrationCompleted: json["registrationCompleted"] ?? false,
      spinWheelCompleted: json["spinWheelCompleted"] ?? false,
      userProfileCompleted: json["userProfileCompleted"] ?? false,
    );
  }
}
