import 'package:cutomer_app/Review/HospitalRatingModel.dart';
import 'package:cutomer_app/Review/ReviewCard.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';

class AllReviewsScreen extends StatelessWidget {
  final HospitalRatingModel hospitalRating;

  const AllReviewsScreen({super.key, required this.hospitalRating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "All Reviews",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: hospitalRating.comments.length,
          itemBuilder: (_, i) => reviewCard(hospitalRating.comments[i]),
        ),
      ),
    );
  }
}
