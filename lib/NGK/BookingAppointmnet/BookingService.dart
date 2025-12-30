import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:http/http.dart' as http;
import 'BookingRequestModel.dart';

import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/BookingAppointmnet/Booking_Model.dart';
import 'package:http/http.dart' as http;
import 'BookingRequestModel.dart';

class BookingService {
  static Future<BookingModel> createBooking(BookingRequestModel request) async {
    final url = Uri.parse("$wifiUrl/booking/create");

    // 🔹 REQUEST LOGS
    print("📤 [BOOKING API] URL: $url");
    print("📤 [BOOKING API] Headers: Content-Type: application/json");
    print("📤 [BOOKING API] Request Body:");
    print(const JsonEncoder.withIndent('  ').convert(request.toJson()));

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );

      // 🔹 RESPONSE LOGS
      print("📥 [BOOKING API] Status Code: ${response.statusCode}");
      print("📥 [BOOKING API] Raw Response:");
      print(response.body);

      final body = jsonDecode(response.body);

      // 🔹 PARSED RESPONSE LOG
      print("📥 [BOOKING API] Parsed Response:");
      print(const JsonEncoder.withIndent('  ').convert(body));

      if (response.statusCode == 200 && body['success'] == true) {
        print("✅ [BOOKING API] Booking created successfully");
        return BookingModel.fromJson(body['data']);
      } else {
        print("❌ [BOOKING API] Booking failed: ${body['message']}");
        throw Exception(body['message'] ?? "Booking failed");
      }
    } catch (e, stack) {
      // 🔹 ERROR LOGS
      print("🔥 [BOOKING API] Exception occurred");
      print("🔥 Error: $e");
      print("🔥 StackTrace:");
      print(stack);

      rethrow;
    }
  }

  static Future<List<BookingModel>> getBookingsByCustomer(
      String customerId) async {
    final url = Uri.parse("$wifiUrl/booking/customer/$customerId");

    print("📤 [GET BOOKINGS] URL: $url");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    print("📥 [GET BOOKINGS] Status: ${response.statusCode}");
    print("📥 [GET BOOKINGS] Body: ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final List data = body['data'] ?? [];

      return data.map<BookingModel>((e) => BookingModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? "Failed to load bookings");
    }
  }


}
