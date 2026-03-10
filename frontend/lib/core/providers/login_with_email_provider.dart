import 'package:frontend/core/services/login_with_email_service.dart';

class LoginWithEmailProvider {
  void createEmail(String username, String email, String hashPassword) async {
    await LoginWithEmailService.createUserEmail(username, email, hashPassword);
  }
}
