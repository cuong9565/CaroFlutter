import 'package:frontend/core/services/service.dart';
import 'package:http/http.dart' as http;

class UserService {
  // /user/create-guest
  static Future<dynamic> createGuest() async {
    final response = await http.post(
      Service.getUri("/users/create-guest"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    return data;
  }

  // /user/get/:id
  static Future<dynamic> loadInfoByUid(String uid) async {
    final response = await http.get(
      Service.getUri("/users/get/$uid"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    return data;
  }
}
