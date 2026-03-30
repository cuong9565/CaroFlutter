import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/services/login_with_email_service.dart';

class LoginWithEmailProvider {
  static final storage = FlutterSecureStorage();

  Future<bool> createEmail(
    String username,
    String email,
    String hashPassword,
  ) async {
    return await LoginWithEmailService.createUserEmail(
      username,
      email,
      hashPassword,
    );
  }

  Future<String> getPassword(String username) async {
    return await LoginWithEmailService.getPassword(username);
  }

  static Future<Map<String, dynamic>> loadEmail() async {
    final Map<String, dynamic> data;
    String? uid = await storage.read(key: 'uid');

    if (uid != null) {
      data = await LoginWithEmailService.getEmail(uid);
      return {'email': data['email']};
    } else {
      return {'email': null};
    }
  }

  Future<bool> checkUserEmail(String username) async {
    return await LoginWithEmailService.checkUserEmail(username);
  }

  Future<String> getUserId(String username) async {
    return await LoginWithEmailService.getUserId(username);
  }

  Future<void> deleteEmail(String id) async {
    return await LoginWithEmailService.deleteEmail(id);
  }
}
