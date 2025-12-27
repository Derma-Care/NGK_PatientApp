import 'package:cutomer_app/Review/AllReviewsScreen.dart';
import 'package:cutomer_app/Review/HospitalRatingModel.dart';
import 'package:cutomer_app/Review/ReviewCard.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';

class HospitalRatingScreen extends StatelessWidget {
  HospitalRatingScreen({super.key});

  final Map<String, dynamic> dummyPayload = {
    "hospitalOverallRating": "5.0",
    "clinicName": "Souji Clinic",
    "comments": [
      {
        "userName": "Anusha R",
        "comment": "Very good doctor and friendly staff.",
        "rating": 4.5,
        "time": "2 days ago"
      },
      {
        "userName": "Rahul K",
        "comment": "Clean clinic and professional service.",
        "rating": 4.0,
        "time": "5 days ago"
      },
      {
        "userName": "Rahul K",
        "comment": "Clean clinic and professional service.",
        "rating": 4.0,
        "time": "5 days ago"
      },
      {
        "userName": "Rahul K",
        "comment": "Clean clinic and professional service.",
        "rating": 4.0,
        "time": "5 days ago"
      },
      {
        "userName": "Rahul K",
        "comment": "Clean clinic and professional service.",
        "rating": 4.0,
        "time": "5 days ago"
      },
      {
        "userName": "Rahul K",
        "comment": "Clean clinic and professional service.",
        "rating": 4.0,
        "time": "5 days ago"
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    final hospitalRating = HospitalRatingModel.fromJson(dummyPayload);

    return Scaffold(
      appBar: CommonHeader(
        title: "${hospitalRating.clinicName} Reviews",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _overallRatingCard(hospitalRating),
            const SizedBox(height: 16),
            const Text(
              "Patient Reviews",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: hospitalRating.comments.length > 5
                    ? 5
                    : hospitalRating.comments.length,
                itemBuilder: (_, i) => reviewCard(hospitalRating.comments[i]),
              ),
            ),
            if (hospitalRating.comments.length > 5)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AllReviewsScreen(hospitalRating: hospitalRating),
                      ),
                    );
                  },
                  child: const Text("View All"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _overallRatingCard(HospitalRatingModel model) {
    final double rating = double.tryParse(model.hospitalOverallRating) ?? 0.0;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.pinkAccent.withOpacity(0.4), // border color
          width: 1.2, // border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Text("Out of 5"),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${model.comments.length} Ratings",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
