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
      final createResponse = await http.post(
        Service.getUri(
          "/gmails/create-gmail?username=$name&gmail=$email&photoUrl=$photoUrl",
        ),
        headers: {"Content-Type": "application/json"},
      );

      if (createResponse.statusCode < 200 || createResponse.statusCode >= 300) {
        throw Exception(
          'Create gmail user failed: ${createResponse.statusCode}: ${createResponse.body}',
        );
      }
    }
  }

  static Future<String> getUserId(String username) async {
    final response = await http.get(
      Service.getUri('/users/get-user-email?username=$username'),
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
