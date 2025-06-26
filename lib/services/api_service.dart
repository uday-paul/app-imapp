import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String?> fetchMacAddress() async {
    final response = await http.get(Uri.parse("http://localhost/api/get_mac"));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['mac'];
    }
    return null;
  }
}