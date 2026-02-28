import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/services/user_service.dart';

class UserProvider {
  static final storage = FlutterSecureStorage();

  // Sẽ trả về thông tin User
  static Future<Map<String, dynamic>> loadUser() async {
    String? uid = await storage.read(key: 'uid');
    // Nếu không có user_id
    if (uid == null) {
      final Map<String, dynamic> data = await UserService.createGuest();
      uid = data['user']['id'];
      await storage.write(key: 'uid', value: data['user']['id']);
      return {'user': data['user']};
    }
    // Nếu có uid
    else {
      final data = await UserService.loadInfoByUid(uid);
      return {'user': data['user']};
    }
  }
}
