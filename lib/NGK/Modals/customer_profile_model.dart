import 'package:cutomer_app/NGK/Contoller/referred_customer_model.dart';

class CustomerProfileModel {
  final String customerId;
  final String fullName;
  final String mobile;
  final String gender;
  final String city;
  final String dob;
  final String? clinicName;
  final String? clinicCityArea;
  final String? dateOfLastVisit;
  final List<String>? serviceType;

  final String? category;
  final List<String>? concern;
  final String? skinTone;
  final String? photo;

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
  final String? referId;
  final int? rewardPoints;
  final List<ReferredCustomerModel>? referredCustomers;

  CustomerProfileModel({
    required this.customerId,
    required this.fullName,
    required this.mobile,
    required this.gender,
    required this.city,
    required this.dob,
    this.clinicName,
    this.clinicCityArea,
    this.dateOfLastVisit,
    this.serviceType,
    this.category,
    this.concern,
    this.skinTone,
    this.photo,
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
    this.referId,
    this.rewardPoints,
    required this.registrationCodeVerified,
    required this.registrationCompleted,
    required this.spinWheelCompleted,
    required this.userProfileCompleted,
    this.referredCustomers,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      customerId: json["customerId"],
      fullName: json["fullName"],
      mobile: json["mobile"],
      gender: json["gender"],
      city: json["city"],
      dob: json["dob"],
      clinicName: json["clinicName"],
      clinicCityArea: json["clinicCityArea"],
      dateOfLastVisit: json["dateOfLastVisit"],
      serviceType: json["serviceType"] != null
          ? List<String>.from(json["serviceType"])
          : null,
      category: json["category"],
      skinTone: json["skinTone"],
      photo: json["photo"],
      concern:
          json["concern"] != null ? List<String>.from(json["concern"]) : null,
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
      referId: json["referId"],
      rewardPoints: json["rewardPoints"],
      referredCustomers: json['referredCustomers'] != null
          ? (json['referredCustomers'] as List)
              .map((e) => ReferredCustomerModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

 