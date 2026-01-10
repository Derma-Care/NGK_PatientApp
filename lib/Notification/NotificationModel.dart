class NotificationModel {
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  // ✅ Convert object → Map
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "body": body,
      "type": type,
      "timestamp": timestamp.toIso8601String(),
      "isRead": isRead,
    };
  }

  // ✅ Convert Map → object
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }
}
