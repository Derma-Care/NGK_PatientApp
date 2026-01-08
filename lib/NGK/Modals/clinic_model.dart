class DoctorModel {
  final String name;
  final String specialization;

  DoctorModel({
    required this.name,
    required this.specialization,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      name: json['doctorName'] ?? "",
      specialization: json['specialization'] ?? "",
    );
  }
}

class ClinicModel {
  final String clinicId;
  final String name;
  final String address;
  final double rating;
  final String hospitalLogo;
  final double distanceInKm;
  final bool online;
  final String openingTime;
  final String closingTime;
  final String branch;
  final int nabhScore;
  final List<DoctorModel> doctors;

  ClinicModel({
    required this.clinicId,
    required this.name,
    required this.address,
    required this.rating,
    required this.hospitalLogo,
    required this.distanceInKm,
    required this.online,
    required this.openingTime,
    required this.closingTime,
    required this.branch,
    required this.nabhScore,
    required this.doctors,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    final rawDistance = json['distanceInKm'] ?? "0";
    final distance = double.tryParse(
          rawDistance.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;

    return ClinicModel(
      clinicId: json['clinicId'],
      name: json['name'],
      address: json['address'],
      rating: (json['hospitalOverallRating'] ?? 0).toDouble(),
      hospitalLogo: json['hospitalLogo'] ?? "",
      distanceInKm: distance,
      online: json['online'] ?? false,
      openingTime: json['openingTime'] ?? "",
      closingTime: json['closingTime'] ?? "",
      branch: json['branch'] ?? "",
      nabhScore: json['nabhScore'] ?? 0,
      doctors: (json['doctorsList'] as List? ?? [])
          .map((e) => DoctorModel.fromJson(e))
          .toList(),
    );
  }
}
