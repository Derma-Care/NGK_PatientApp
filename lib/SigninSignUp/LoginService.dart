import 'dart:convert';
import 'package:cutomer_app/NGK/service/api_provider.dart';
import 'package:get/get.dart';
import '../Utils/ShowSnackBar.dart';

class LoginApiService {
  final String endpoint = "/api/auth/send-otp";

  Future<Map<String, dynamic>> sendUserDataWithFCMToken(
      String fullname, String mobileNumber, String token) async {

    print("response for fullname $fullname");
    print("response for mobileNumber $mobileNumber");
    print("response for token $token");

    try {
      if (token == null) {
        print("FCM Token is null. Cannot send data.");
        return {'error': 'FCM Token is null. Cannot send data.'};
      }

      final body = {
        'userName': fullname,
        'mobileNumber': mobileNumber,
        'deviceId': token,
      };

      print("body.toString() : $body");
      print("loginUrl : $endpoint");

      final api = Get.find<ApiProvider>().dio;

      // 🔹 SEND OTP
      final response = await api.post(
        endpoint,
        data: {
          'mobile': mobileNumber,
          // 'deviceToken': token,
        },
      );

      print("response for statusCode ${response.statusCode}");
      print("response for data ${response.data}");
      print("response for body $body");

      if (response.data != null) {
        return Map<String, dynamic>.from(response.data);
      } else {
        return {
          'statusCode': response.statusCode,
          'message': 'Empty response from server'
        };
      }
    } catch (e) {
      showSnackbar("Error", "server not respond", "error");
      return {'error': 'An error occurred: $e'};
    }
  }
}
