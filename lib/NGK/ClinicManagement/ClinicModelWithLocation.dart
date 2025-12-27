// import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';

// class ClinicModelWithLocation {
//   final String clinicId;
//   final String name;
//   final String address;
//   final String city;
//   final String state;
//   final double latitude;
//   final double longitude;

//   final String contactNumber;
//   final String whatsappNumber;
//   final String email;
//   final String website;

//   final double hospitalOverallRating;
//   final String openingTime;
//   final String closingTime;
//   final String status;
//   final bool recommended;
//   final String subscription;

//   final String hospitalLogo; // base64
//   final int nabhScore;

//   final List<DoctorModel> doctorsList;
//   final ProcedureListModal? procedureDeatils;

//   // final Permissions permissions;
//   final String distanceInKm;

//   ClinicModelWithLocation({
//     required this.clinicId,
//     required this.name,
//     required this.address,
//     required this.city,
//     required this.state,
//     required this.latitude,
//     required this.longitude,
//     required this.contactNumber,
//     required this.whatsappNumber,
//     required this.email,
//     required this.website,
//     required this.hospitalOverallRating,
//     required this.openingTime,
//     required this.closingTime,
//     required this.status,
//     required this.recommended,
//     required this.subscription,
//     required this.hospitalLogo,
//     required this.nabhScore,
//     required this.doctorsList,
//     // required this.permissions,
//     required this.procedureDeatils,
//     required this.distanceInKm,
//   });

//   factory ClinicModelWithLocation.fromJson(Map<String, dynamic> json) {
//     return ClinicModelWithLocation(
//       clinicId: json['clinicId'],
//       name: json['name'],
//       address: json['address'],
//       city: json['city'],
//       state: json['state'],
//       latitude: (json['latitude'] ?? 0).toDouble(),
//       longitude: (json['longitude'] ?? 0).toDouble(),
//       contactNumber: json['contactNumber'] ?? '',
//       whatsappNumber: json['whatsappNumber'] ?? '',
//       email: json['email'] ?? '',
//       website: json['website'] ?? '',
//       hospitalOverallRating: (json['hospitalOverallRating'] ?? 0).toDouble(),
//       openingTime: json['openingTime'] ?? '',
//       closingTime: json['closingTime'] ?? '',
//       status: json['status'] ?? '',
//       recommended: json['recommended'] ?? false,
//       subscription: json['subscription'] ?? '',
//       hospitalLogo: json['hospitalLogo'] ?? '',
//       nabhScore: json['nabhScore'] ?? 0,
//       procedureDeatils: json['procedureDeatils'] != null
//           ? ProcedureListModal.fromJson(json['procedureDeatils'])
//           : null,

//       distanceInKm: json['distanceInKm'] ?? "0",
//       doctorsList: (json['doctorsList'] as List? ?? [])
//           .map((e) => DoctorModel.fromJson(e))
//           .toList(),
//       // permissions: Permissions.fromJson(json['permissions'] ?? {}),
//     );
//   }
// }

// class Permissions {
//   final List<String> clinic;
//   final List<String> users;

//   Permissions({
//     required this.clinic,
//     required this.users,
//   });

//   factory Permissions.fromJson(Map<String, dynamic> json) {
//     return Permissions(
//       clinic: List<String>.from(json['clinic'] ?? []),
//       users: List<String>.from(json['users'] ?? []),
//     );
//   }
// }
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
  final int nabhScore;

  final List<DoctorModel> doctorsList;
  final ProcedureListModal? procedurePricing; // ✅ nullable
  final String distanceInKm;
  final String? facebookHandle;
  final String? instagramHandle;
  final String? twitterHandle;

  final String? licenseNumber;
  final String? issuingAuthority;
  final String? walkthrough;
  final String? primaryContactPerson;
  final String? designation;

  ClinicModelWithLocation(
      {required this.clinicId,
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
      required this.nabhScore,
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
      this.designation});

  factory ClinicModelWithLocation.fromJson(Map<String, dynamic> json) {
    return ClinicModelWithLocation(
      clinicId: json['clinicId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      contactNumber: json['contactNumber'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      hospitalOverallRating: (json['hospitalOverallRating'] ?? 0).toDouble(),
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      status: json['status'] ?? '',
      recommended: json['recommended'] ?? false,
      subscription: json['subscription'] ?? '',
      facebookHandle: json['facebookHandle'] ?? '',
      instagramHandle: json['instagramHandle'] ?? '',
      twitterHandle: json['twitterHandle'] ?? '',
      hospitalLogo: json['hospitalLogo'] ?? '',

      licenseNumber: json['licenseNumber'] ?? '',
      issuingAuthority: json['issuingAuthority'] ?? '',
      walkthrough: json['walkthrough'] ?? '',
      primaryContactPerson: json['primaryContactPerson'] ?? '',
      designation: json['designation'] ?? '',

      nabhScore: json['nabhScore'] ?? 0,

      // ✅ SAFE parsing
      procedurePricing: json['procedurePricing'] != null
          ? ProcedureListModal.fromJson(json['procedurePricing'])
          : null,

      distanceInKm: json['distanceInKm']?.toString() ?? "0",

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
