 
class TreatmentData {
  final String? reason;
  final String? frequency;
  final int? sittings;
  final String? startDate;
  final int? totalSittings;
  final int? takenSittings;
  final int? pendingSittings;
  final int? currentSitting;
  final List<TreatmentDate>? dates;

  TreatmentData({
    this.reason,
    this.frequency,
    this.sittings,
    this.startDate,
    this.totalSittings,
    this.takenSittings,
    this.pendingSittings,
    this.currentSitting,
    this.dates,
  });

  factory TreatmentData.fromJson(Map<String, dynamic> json) {
    return TreatmentData(
      reason: json['reason']?.toString(),
      frequency: json['frequency']?.toString(),
      sittings: json['sittings'] is int
          ? json['sittings']
          : int.tryParse(json['sittings']?.toString() ?? '0'),
      startDate: json['startDate']?.toString(),
      totalSittings: json['totalSittings'],
      takenSittings: json['takenSittings'],
      pendingSittings: json['pendingSittings'],
      currentSitting: json['currentSitting'],
      dates: (json['dates'] as List?)
          ?.map((e) => TreatmentDate.fromJson(e))
          .toList(),
    );
  }
}

class TreatmentDate {
  final String? date;
  final int? sitting;
  final String? status;

  TreatmentDate({this.date, this.sitting, this.status});

  factory TreatmentDate.fromJson(Map<String, dynamic> json) {
    return TreatmentDate(
      date: json['date']?.toString(),
      sitting: json['sitting'] is int
          ? json['sitting']
          : int.tryParse(json['sitting']?.toString() ?? '0'),
      status: json['status']?.toString(),
    );
  }
}

