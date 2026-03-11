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
      await http.post(
        Service.getUri(
          "/emails/create-email?username=$username&email=$email&hash_password=$hashPassword",
        ),
        headers: {"Content-Type": "application/json"},
      );
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
}
