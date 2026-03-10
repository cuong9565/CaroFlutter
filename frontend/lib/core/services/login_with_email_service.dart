import 'package:frontend/core/services/service.dart';
import 'package:http/http.dart' as http;

class LoginWithEmailService {
  // /emails/create-email
  static Future<dynamic> createUserEmail(
    String username,
    String email,
    String hashPassword,
  ) async {
    await http.post(
      Service.getUri(
        "/emails/create-email?username=$username&email=$email&hash_password=$hashPassword",
      ),
      headers: {"Content-Type": "application/json"},
    );
  }

  static Future<dynamic> getPassword(String username) async {
    final response = await http.get(
      Service.getUri("/emails/get-password?username=$username"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    return data;
  }
}
