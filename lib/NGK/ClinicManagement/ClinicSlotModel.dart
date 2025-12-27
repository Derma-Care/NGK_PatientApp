class ClinicSlotModel {
  final String date; // yyyy-MM-dd
  final String dayOfWeek;
  final bool workingHours;
  final String? reason;

  ClinicSlotModel({
    required this.date,
    required this.dayOfWeek,
    required this.workingHours,
    this.reason,
  });

  factory ClinicSlotModel.fromJson(Map<String, dynamic> json) {
    return ClinicSlotModel(
      date: json['date'],
      dayOfWeek: json['dayOfWeek'],
      workingHours: json['workingHours'],
      reason: json['reason'],
    );
  }
}
