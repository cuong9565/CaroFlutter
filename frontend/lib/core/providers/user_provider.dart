import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/services/user_service.dart';

class UserProvider {
  static final storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> _createGuestAndPersist() async {
    final Map<String, dynamic> data = await UserService.createGuest();
    final user = data['user'];
    final id = (user is Map) ? user['id'] : null;

    final userId = id?.toString();
    if (userId == null || userId.isEmpty) {
      throw Exception('Failed to create guest user');
    }

    await storage.write(key: 'uid', value: userId);
    return {'user': user};
  }

  // Sẽ trả về thông tin User
  static Future<Map<String, dynamic>> loadUser() async {
    String? uid = await storage.read(key: 'uid');
    // Nếu không có user_id
    if (uid == null || uid.isEmpty) {
      return _createGuestAndPersist();
    }
    // Nếu có uid
    else {
      final data = await UserService.loadInfoByUid(uid);
      final user = data['user'];
      if (user == null) {
        // uid cũ không còn tồn tại trong DB (reset DB, xóa user, ...)
        await storage.delete(key: 'uid');
        return _createGuestAndPersist();
      }

      return {'user': user};
    }
  }

  static Future<void> updateUser(
    String uid,
    String username,
    String photoUrl,
  ) async {
    await UserService.updateUser(uid, username, photoUrl);
  }

  static Future<void> deleteUser(String uid) async {
    await UserService.deleteUser(uid);
  }
}
