import 'package:cutomer_app/NGK/Packges/PackageModel.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';

class ClinicModelWithLocation {
  final String clinicId;
  final String name;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;

  final String contactNumber;
  final String whatsappNumber;
  final String email;
  final String website;

  final double hospitalOverallRating;
  final String openingTime;
  final String closingTime;
  final String status;
  final bool recommended;
  final String subscription;

  final String hospitalLogo;
  final int? nabhScore;

  final List<DoctorModel> doctorsList;
  final ProcedureListModal? procedurePricing;

  final String distanceInKm;

  final String? facebookHandle;
  final String? instagramHandle;
  final String? twitterHandle;

  final String? licenseNumber;
  final String? issuingAuthority;
  final String? walkthrough;
  final String? primaryContactPerson;
  final String? designation;
  final double? maxOfferPercentage;

  ClinicModelWithLocation({
    required this.clinicId,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.email,
    required this.website,
    required this.hospitalOverallRating,
    required this.openingTime,
    required this.closingTime,
    required this.status,
    required this.recommended,
    required this.subscription,
    required this.hospitalLogo,
    this.nabhScore,
    required this.doctorsList,
    this.procedurePricing,
    required this.distanceInKm,
    this.facebookHandle,
    this.instagramHandle,
    this.twitterHandle,
    this.licenseNumber,
    this.issuingAuthority,
    this.walkthrough,
    this.primaryContactPerson,
    this.designation,
    this.maxOfferPercentage,
  });

  factory ClinicModelWithLocation.fromJson(Map<String, dynamic> json) {
    return ClinicModelWithLocation(
      clinicId: json['clinicId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      contactNumber: json['contactNumber'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      hospitalOverallRating:
          (json['hospitalOverallRating'] as num?)?.toDouble() ?? 0.0,
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      status: json['status'] ?? '',
      recommended: json['recommended'] == true,
      subscription: json['subscription'] ?? '',
      hospitalLogo: json['hospitalLogo'] ?? '',

      /// ✅ FIXED
      nabhScore: (json['nabhScore'] as num?)?.toInt() ?? 0,

      facebookHandle: json['facebookHandle'],
      instagramHandle: json['instagramHandle'],
      twitterHandle: json['twitterHandle'],
      licenseNumber: json['licenseNumber'],
      issuingAuthority: json['issuingAuthority'],
      walkthrough: json['walkthrough'],
      primaryContactPerson: json['primaryContactPerson'],
      designation: json['designation'],

      /// ✅ FIXED
      maxOfferPercentage: (json['maxOfferPercentage'] as num?)?.toDouble(),

      procedurePricing: json['procedurePricing'] != null
          ? ProcedureListModal.fromJson(json['procedurePricing'])
          : null,

      distanceInKm: json['distanceInKm']?.toString() ?? "0 KM",

      doctorsList: (json['doctorsList'] as List? ?? [])
          .map((e) => DoctorModel.fromJson(e))
          .toList(),
    );
  }
}

class DoctorModel {
  final String doctorName;
  final String registrationNumber;
  final String associationNumber;
  final String associationName;
  final String specialization;

  DoctorModel({
    required this.doctorName,
    required this.registrationNumber,
    required this.associationNumber,
    required this.associationName,
    required this.specialization,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      doctorName: json['doctorName'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      associationNumber: json['associationNumber'] ?? '',
      associationName: json['associationName'] ?? '',
      specialization: json['specialization'] ?? '',
    );
  }
}

class ClinicServicesResponse {
  final List<PackageModel> packages;
  final List<ProcedureListModal> procedures;

  ClinicServicesResponse({
    required this.packages,
    required this.procedures,
  });

  factory ClinicServicesResponse.fromJson(Map<String, dynamic> json) {
    return ClinicServicesResponse(
      packages: (json['packages'] as List? ?? [])
          .map((e) => PackageModel.fromListItem(e))
          .toList(),
      procedures: (json['procedures'] as List? ?? [])
          .map((e) => ProcedureListModal.fromJson(e))
          .toList(),
    );
  }
}
