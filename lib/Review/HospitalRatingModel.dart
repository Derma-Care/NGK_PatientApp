class HospitalRatingModel {
  final String hospitalOverallRating;
  final String clinicName;
  final List<CommentModel> comments;

  HospitalRatingModel({
    required this.hospitalOverallRating,
    required this.clinicName,
    required this.comments,
  });

  factory HospitalRatingModel.fromJson(Map<String, dynamic> json) {
    return HospitalRatingModel(
      hospitalOverallRating: json['hospitalOverallRating'],
      clinicName: json['clinicName'],
      comments: (json['comments'] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList(),
    );
  }
}

class CommentModel {
  final String userName;
  final String comment;
  final double rating;
  final String time;

  CommentModel({
    required this.userName,
    required this.comment,
    required this.rating,
    required this.time,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userName: json['userName'],
      comment: json['comment'],
      rating: (json['rating'] as num).toDouble(),
      time: json['time'],
    );
  }
}
