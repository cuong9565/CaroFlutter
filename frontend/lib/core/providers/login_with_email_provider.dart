import 'package:frontend/core/services/login_with_email_service.dart';

class LoginWithEmailProvider {
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

  Future<bool> checkUserEmail(String username) async {
    return await LoginWithEmailService.checkUserEmail(username);
  }
}
