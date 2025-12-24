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

  final String hospitalLogo; // base64
  final int nabhScore;

  final List<DoctorModel> doctorsList;
  final Permissions permissions;

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
    required this.nabhScore,
    required this.doctorsList,
    required this.permissions,
  });

  factory ClinicModelWithLocation.fromJson(Map<String, dynamic> json) {
    return ClinicModelWithLocation(
      clinicId: json['clinicId'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
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
      hospitalLogo: json['hospitalLogo'] ?? '',
      nabhScore: json['nabhScore'] ?? 0,
      doctorsList: (json['doctorsList'] as List? ?? [])
          .map((e) => DoctorModel.fromJson(e))
          .toList(),
      permissions: Permissions.fromJson(json['permissions'] ?? {}),
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

class Permissions {
  final List<String> clinic;
  final List<String> users;

  Permissions({
    required this.clinic,
    required this.users,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      clinic: List<String>.from(json['clinic'] ?? []),
      users: List<String>.from(json['users'] ?? []),
    );
  }
}
