import 'dart:convert';
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

  static Future<void> updateUser(
    String uid,
    String username,
    String photoUrl,
  ) async {
    await http.put(
      Service.getUri("/users/update-user/$uid"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "photoUrl": photoUrl,
      }),
    );
  }

  static Future<void> deleteUser(String uid) async {
    await http.delete(
      Service.getUri("/users/delete-user/$uid"),
      headers: {"Content-Type": "application/json"},
    );
  }
}
