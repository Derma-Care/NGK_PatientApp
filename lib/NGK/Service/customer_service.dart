import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:http/http.dart' as http;

class CustomerService {
  static Future<CustomerProfileModel?> getCustomer(String mobile) async {
    print("calling getCustomer ${mobile}");
    final url =
        Uri.parse("https://glowkartapi.ashokfruit.shop/api/customer/$mobile");

    final response = await http.get(url);
    print("calling response ${response.body}");
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body["success"] == true && body["data"] != null) {
        return CustomerProfileModel.fromJson(body["data"]);
      }
    }

    return null;
  }
}
