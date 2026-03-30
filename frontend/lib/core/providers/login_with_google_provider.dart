import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/services/login_with_google_service.dart';

class LoginWithGoogleProvider {
  static final storage = FlutterSecureStorage();

  Future<void> createUserGmail(
    String name,
    String email,
    String photoUrl,
  ) async {
    await LoginWithGoogleService.createUserGmail(name, email, photoUrl);
  }

  Future<String> getUserId(String username) async {
    return await LoginWithGoogleService.getUserId(username);
  }

  static Future<Map<String, dynamic>> loadGmail() async {
    final Map<String, dynamic> data;
    String? uid = await storage.read(key: 'uid');

    if (uid != null) {
      data = await LoginWithGoogleService.getGmail(uid);
      return {'gmail': data['gmail']};
    } else {
      return {'gmail': null};
    }
  }

  Future<void> deleteEmail(String id) async {
    return await LoginWithGoogleService.deleteGmail(id);
  }
}
