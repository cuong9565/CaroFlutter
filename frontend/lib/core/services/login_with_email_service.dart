import 'package:frontend/core/services/service.dart';
import 'package:http/http.dart' as http;

class LoginWithEmailService {
  // /emails/create-email
  static Future<bool> createUserEmail(
    String username,
    String email,
    String hashPassword,
  ) async {
    final response = await http.get(
      Service.getUri("/users/get-user-email?username=$username"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    if (data['id'] == null) {
      final createResponse = await http.post(
        Service.getUri(
          "/emails/create-email?username=$username&email=$email&hash_password=$hashPassword",
        ),
        headers: {"Content-Type": "application/json"},
      );

      if (createResponse.statusCode < 200 || createResponse.statusCode >= 300) {
        throw Exception(
          'Create email user failed: ${createResponse.statusCode}: ${createResponse.body}',
        );
      }
      // Future.delayed(Duration(seconds: 2));
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  static Future<String> getPassword(String username) async {
    final response = await http.get(
      Service.getUri("/emails/get-password?username=$username"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    return data['password'];
  }

  static Future<dynamic> getEmail(String uid) async {
    final response = await http.get(
      Service.getUri("/emails/get-email?id=$uid"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    return data;
  }

  static Future<bool> checkUserEmail(String username) async {
    final response = await http.get(
      Service.getUri("/users/get-user-email?username=$username"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    if (data['id'] == null) {
      return false;
    } else {
      return true;
    }
  }

  static Future<String> getUserId(String username) async {
    final response = await http.get(
      Service.getUri("/users/get-user-email?username=$username"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    final user = data['id'];

    if (user is Map) {
      final id = user['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }

    throw Exception('User not found');
  }

  static Future<void> deleteEmail(String id) async {
    await http.delete(
      Service.getUri("/emails/delete-email/$id"),
      headers: {"Content-Type": "application/json"},
    );
  }
}
