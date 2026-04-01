import 'package:frontend/core/services/service.dart';
import 'package:http/http.dart' as http;

class LoginWithGoogleService {
  static Future<void> createUserGmail(
    String name,
    String email,
    String photoUrl,
  ) async {
    final response = await http.get(
      Service.getUri("/users/get-user-email?username=$name"),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    if (data['id'] == null) {
      await http.post(
        Service.getUri(
          "/gmails/create-gmail?username=$name&gmail=$email&photoUrl=$photoUrl",
        ),
        headers: {"Content-Type": "application/json"},
      );
    }
  }

  static Future<String> getUserId(String username) async {
    final response = await http.get(
      Service.getUri('/users/get-user-email?username=$username'),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    return data['id']['id'];
  }

  static Future<dynamic> getGmail(String id) async {
    final response = await http.get(
      Service.getUri('/gmails/get-gmail?id=$id'),
      headers: {"Content-Type": "application/json"},
    );
    final data = Service.handleResponse(response);
    return data;
  }

  static Future<void> deleteGmail(String id) async {
    await http.delete(
      Service.getUri("/emails/delete-gmail/$id"),
      headers: {"Content-Type": "application/json"},
    );
  }
}
