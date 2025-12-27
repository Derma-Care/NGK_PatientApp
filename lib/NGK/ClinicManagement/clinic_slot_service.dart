import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicSlotModel.dart';
import 'package:http/http.dart' as http;
import 'package:cutomer_app/Utils/Constant.dart';

class ClinicSlotService {
  static Future<List<ClinicSlotModel>> getClinicSlots(String clinicId) async {
    final url = Uri.parse(
      "$registerUrl/clinic/slots?clinicId=$clinicId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("Slots esponse ${body}");
      if (body['success'] == true) {
        final List slots = body['data']['slots'];
        return slots.map((e) => ClinicSlotModel.fromJson(e)).toList();
      } else {
        throw Exception(body['message']);
      }
    } else {
      throw Exception("Failed to load clinic slots");
    }
  }
}
