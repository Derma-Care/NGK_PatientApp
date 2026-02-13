class ClinicAdModel {
  final String id;
  final String? clinicId;
  final String? clinicName;
  final String type;
  final String url;
  final String title;

  ClinicAdModel({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.type,
    required this.url,
    required this.title,
  });

  factory ClinicAdModel.fromJson(Map<String, dynamic> json) {
    return ClinicAdModel(
      id: json['id'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      type: json['type'],
      url: json['url'],
      title: json['title'] ?? '',
    );
  }
}
