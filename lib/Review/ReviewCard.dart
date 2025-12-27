import 'package:cutomer_app/Review/HospitalRatingModel.dart';
import 'package:flutter/material.dart';

Widget reviewCard(CommentModel review) {
  return Card(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: const Color.fromARGB(255, 63, 63, 63)
            .withOpacity(0.4), // border color
        width: 1.2, // border width
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                review.time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating.round() ? Icons.star : Icons.star_border,
                size: 18,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(review.comment),
        ],
      ),
    ),
  );
}
