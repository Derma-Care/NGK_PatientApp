class PatientData {
  final String name;
  final String relation;
  final String patientMobileNumber;
  final String patientId;
  final String patientAddress;
  final String age;
  final String gender;
  final String customerId;
  final String clinicId;

  PatientData({
    required this.name,
    required this.relation,
    required this.patientMobileNumber,
    required this.patientId,
    required this.patientAddress,
    required this.age,
    required this.gender,
    required this.customerId,
    required this.clinicId,
  });

  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      patientMobileNumber: json['patientMobileNumber'] ?? '',
      patientId: json['patientId'] ?? '',
      patientAddress: json['patientAddress'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      customerId: json['customerId'] ?? '',
      clinicId: json['clinicId'] ?? '',
    );
  }
}
