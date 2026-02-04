import 'dart:convert';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../BottomNavigation/BottomNavigation.dart';
import '../Utils/ScaffoldMessageSnacber.dart';

class customerRatingService {

  // ---------------- SEND CUSTOMER RATING ----------------
  Future<Map<String, dynamic>> sendCustomerRating(
    BuildContext context,
    String appointmentId,
    String serviceId,
    int selectedRating,
    String feedback,
    String mobileNumber,
    String userName,
  ) async {

    print("Rating appointmentId: $appointmentId");
    print("Rating serviceId: $serviceId");
    print("Rating selectedRating: $selectedRating");
    print("Rating feedback: $feedback");
    print("Rating mobileNumber: $mobileNumber");

    final Map<String, dynamic> requestBody = {
      "appointmentId": appointmentId,
      "serviceId": serviceId,
      "rating": selectedRating,
      "feedback": feedback,
      "customerMobileNumber": mobileNumber,
    };

    final api = Get.find<ApiProvider>().dio;

    final response = await api.post(
      '/provider-ratings/$appointmentId/$serviceId',
      data: requestBody,
    );

    print("Rating Response code: ${response.statusCode}");
    print("Rating Response body: ${response.data}");

    final Map<String, dynamic> responseData = response.data;

    if (response.statusCode == 200 || response.statusCode == 201) {

      ScaffoldMessageSnackbar.show(
        context: context,
        message: responseData['message'],
        type: SnackbarType.error,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (ctx) => BottomNavController(
            mobileNumber: mobileNumber,
            index: 0,
          ),
        ),
        (route) => false,
      );

      return responseData;
    } else {
      print("Failed to submit rating. Status code: ${response.statusCode}");
      throw Exception(
        responseData['error'] ?? 'Failed to submit rating',
      );
    }
  }

  // ---------------- FETCH RATING ----------------
  Future<Map<String, dynamic>?> fetchRating(
    String serviceId,
    String appointmentId,
  ) async {

    final api = Get.find<ApiProvider>().dio;

    try {
      final response = await api.get(
        '/provider-ratings/$appointmentId/$serviceId/rating-info',
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;

        print('Rating Data: $data');

        if (data['success'] == true) {
          final Map<String, dynamic>? formData = data['formData'];

          final double? rating =
              formData != null ? formData['rating']?.toDouble() : null;

          final bool customerRatingCompleted =
              data['customerRatingCompleted'] ?? false;

          print('Rating: $rating');
          print('Customer Rating Completed: $customerRatingCompleted');

          return {
            'rating': rating,
            'customerRatingCompleted': customerRatingCompleted,
          };
        } else {
          print('No rating found for the specified appointment and service.');
          return {
            'rating': null,
            'customerRatingCompleted':
                data['customerRatingCompleted'] ?? false,
          };
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred while fetching the rating: $e');
      return null;
    }
  }
}
