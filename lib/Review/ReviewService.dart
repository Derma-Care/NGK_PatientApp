import 'dart:convert';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'package:cutomer_app/Toasters/Toaster.dart';
import 'package:get/get.dart';

Future<void> submitCustomerRating({
  required double doctorRating,
  required double branchRating,
  required String feedback,
  required String branchId,
  required String doctorId,
  required String customerMobileNumber,
  required String appointmentId,
  required String hospitalId,
  required String patientId,
  required String patientName,
}) async {

  final endpoint = "/submitCustomerRating";

  final Map<String, dynamic> payload = {
    "doctorRating": doctorRating,
    "branchRating": branchRating,
    "feedback": feedback,
    "doctorId": doctorId,
    "customerMobileNumber": customerMobileNumber,
    "appointmentId": appointmentId,
    "hospitalId": hospitalId,
    "patientId": patientId,
    "patientName": patientName,
    "branchId": branchId,
  };

  final api = Get.find<ApiProvider>().dio;

  try {
    final response = await api.post(
      endpoint,
      data: payload,
    );

    print('✅ Rating submitted successfully: $payload');

    if (response.statusCode == 200) {
      showSuccessToast(msg: "Rating submitted successfully $doctorId");
      print('✅ Rating submitted successfully: ${response.data}');
      // ✅ Close current screen if needed
    } else {
      print('❌ Failed to submit rating: ${response.statusCode}');
      print('🔍 Response: ${response.data}');
    }
  } catch (e) {
    print('🚨 Error submitting rating: $e');
  }
}
