import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'GetAppointmentModel.dart';

class AppointmentService {

  /// Fetch all bookings for a mobile number
  Future<List<Getappointmentmodel>> fetchAppointments(String customerId) async {
    final endpoint = '$registerUrl/bookings/customerId/$customerId';
    final api = Get.find<ApiProvider>().dio;

    debugPrint("🔍 URL: ${api.options.baseUrl}$endpoint");

    try {
      final response = await api.get(endpoint);

      debugPrint("🔍 Status code: ${response.statusCode}");
      debugPrint("🔍 Body: ${response.data}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final List<dynamic> data = jsonData['data'] ?? [];

        debugPrint("📥 Data array length: ${data.length}");

        return data
            .map((item) {
              try {
                return Getappointmentmodel.fromJson(item);
              } catch (e) {
                debugPrint("❌ Error parsing appointment: $e\nData: $item");
                return null;
              }
            })
            .whereType<Getappointmentmodel>()
            .toList();
      } else {
        debugPrint("⚠️ HTTP error: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Exception in fetchAppointments: $e");
      return [];
    }
  }

  /// Fetch in-progress appointments
  Future<List<Getappointmentmodel>> fetchInprogressAppointments(
      String customerId) async {

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('customerId') ?? "";

    final endpoint =
        '$registerUrl/bookings/Inprogress/customerId/$customerId';
    final api = Get.find<ApiProvider>().dio;

    debugPrint("🔍 InprogressURL: ${api.options.baseUrl}$endpoint");

    try {
      final response = await api.get(endpoint);

      debugPrint("🔍 Status code: ${response.statusCode}");
      debugPrint("🔍 Body!!!!!: ${response.data}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final List<dynamic> data = jsonData['data'] ?? [];

        debugPrint("📥 Data array length: ${data.length}");

        return data
            .map((item) {
              try {
                return Getappointmentmodel.fromJson(item);
              } catch (e) {
                debugPrint(
                    "❌ Error parsing in-progress appointment: $e\nData: $item");
                return null;
              }
            })
            .whereType<Getappointmentmodel>()
            .toList();
      } else {
        debugPrint("⚠️ HTTP error: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Exception in fetchInprogressAppointments: $e");
      return [];
    }
  }

  /// Fetch a single appointment by ID
  Future<Getappointmentmodel?> fetchAppointmentById(String appID) async {
    final endpoint = '$registerUrl/getBookedService/$appID';
    final api = Get.find<ApiProvider>().dio;

    debugPrint("🔍 URL: ${api.options.baseUrl}$endpoint");

    try {
      final response = await api.get(endpoint);

      debugPrint("🔍 Status code: ${response.statusCode}");
      debugPrint("🔍 Body: ${response.data}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final dynamic data = jsonData['data'];

        if (data != null) {
          return Getappointmentmodel.fromJson(data);
        } else {
          debugPrint("⚠️ No appointment data found");
          return null;
        }
      } else {
        debugPrint("⚠️ HTTP error: ${response.statusMessage}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception in fetchAppointmentById: $e");
      return null;
    }
  }
}
