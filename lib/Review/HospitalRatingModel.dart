class HospitalRatingModel {
  final String clinicName;
  final String hospitalOverallRating;
  final int totalRatings;
  final List<CommentModel> comments;

  HospitalRatingModel({
    required this.clinicName,
    required this.hospitalOverallRating,
    required this.totalRatings,
    required this.comments,
  });

  factory HospitalRatingModel.fromApi(Map<String, dynamic> json) {
    final ratings = json['ratings'] as List? ?? [];

    return HospitalRatingModel(
      clinicName:
          ratings.isNotEmpty ? ratings[0]['clinicName'] ?? 'Clinic' : 'Clinic',
      hospitalOverallRating: (json['averageRating'] ?? 0).toString(),
      totalRatings: json['totalRatings'] ?? 0,
      comments: ratings.map((e) => CommentModel.fromJson(e)).toList(),
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
      userName: json['fullName'] ?? 'Anonymous',
      comment: json['review'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      time: json['createdAt'] ?? '',
    );
  }
}
