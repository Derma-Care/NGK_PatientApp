import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'BookingRequestModel.dart';

class BookingService {

  static Future<BookingModel> createBooking(
      BookingRequestModel request) async {

    final endpoint = "/booking/create";

    // 🔹 REQUEST LOGS
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📤 [BOOKING API] REQUEST");
    debugPrint("➡️ ENDPOINT : $endpoint");
    debugPrint("➡️ HEADERS  : Content-Type: application/json");
    debugPrint("➡️ BODY ↓↓↓");
    debugPrint(
      const JsonEncoder.withIndent('  ').convert(request.toJson()),
    );
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final api = Get.find<ApiProvider>().dio;

    try {
      final response = await api.post(
        endpoint,
        data: request.toJson(),
      );

      final resData = response.data;

      // 🔹 RESPONSE LOGS
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📥 [BOOKING API] RESPONSE");
      debugPrint("✅ STATUS CODE : ${response.statusCode}");
      debugPrint("📦 RESPONSE BODY ↓↓↓");
      debugPrint(
        const JsonEncoder.withIndent('  ').convert(resData),
      );
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      if (resData['success'] == true) {
        debugPrint("✅ [BOOKING API] Booking created successfully");
        return BookingModel.fromJson(resData['data']);
      } else {
        debugPrint(
            "❌ [BOOKING API] Booking failed: ${resData['message']}");
        throw Exception(resData['message'] ?? "Booking failed");
      }
    } catch (e, stack) {
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("🔥 [BOOKING API] EXCEPTION");
      debugPrint("🔥 ERROR : $e");
      debugPrint("🔥 STACKTRACE ↓↓↓");
      debugPrint(stack.toString());
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      rethrow;
    }
  }

  static Future<List<BookingModel>> getBookingsByCustomer(
      String customerId) async {

    final endpoint = "/booking/customer/$customerId";
    final api = Get.find<ApiProvider>().dio;

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📤 [GET BOOKINGS] REQUEST");
    debugPrint("➡️ ENDPOINT : $endpoint");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final response = await api.get(endpoint);
      final resData = response.data;

      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📥 [GET BOOKINGS] RESPONSE");
      debugPrint("✅ STATUS CODE : ${response.statusCode}");
      debugPrint("📦 RESPONSE BODY ↓↓↓");
      debugPrint(
        const JsonEncoder.withIndent('  ').convert(resData),
      );
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      if (resData['success'] == true) {
        final List list = resData['data'] ?? [];
        return list
            .map<BookingModel>((e) => BookingModel.fromJson(e))
            .toList();
      } else {
        throw Exception(
            resData['message'] ?? "Failed to load bookings");
      }
    } catch (e, stack) {
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("🔥 [GET BOOKINGS] EXCEPTION");
      debugPrint("🔥 ERROR : $e");
      debugPrint("🔥 STACKTRACE ↓↓↓");
      debugPrint(stack.toString());
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      rethrow;
    }
  }
}
