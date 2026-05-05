import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';
import 'package:frontend/core/providers/login_with_google_provider.dart';

class SignInTest extends StatefulWidget {
  const SignInTest({super.key});

  @override
  State<SignInTest> createState() => _SignInTestState();
}

class _SignInTestState extends State<SignInTest> {
  static GoogleSignInAccount? _user;

  final scopes = <String>["https://www.googleapis.com/auth/contacts.readonly"];

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      GoogleSignIn.instance.initialize(
        clientId:
            '425132500364-2vqgb28pma9cf90k7d826jehr8qbs26d.apps.googleusercontent.com',
      );
      GoogleSignIn.instance.authenticationEvents.listen(
        _handleAuthenticationEvent,
      );
    }
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    // #docregion CheckAuthorization
    final GoogleSignInAccount? user = // ...
        // #enddocregion CheckAuthorization
        switch (event) {
          GoogleSignInAuthenticationEventSignIn() => event.user,
          GoogleSignInAuthenticationEventSignOut() => null,
        };

    // Check for existing authorization.
    // #docregion CheckAuthorization
    await user?.authorizationClient.authorizationForScopes(scopes);

    debugPrint(user.toString());
    setState(() {
      _user = user;
    });
    String name = _user?.displayName ?? '';
    String email = _user?.email ?? '';
    String photoUrl = _user?.photoUrl ?? '';
    debugPrint(name);
    debugPrint(email);
    debugPrint(photoUrl);
    try {
      await LoginWithGoogleProvider().createUserGmail(name, email, photoUrl);
      final String id = await LoginWithGoogleProvider().getUserId(name);
      await FlutterSecureStorage().write(key: 'uid', value: id);
      if (!mounted) return;
      context.go("/");
    } catch (e, st) {
      debugPrint('Google sign-in flow failed: $e');
      debugPrint('$st');
    }
  }

  Future<void> _signIn() async {
    try {
      // Check if platform supports authenticate
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        final GoogleSignInAccount user = await GoogleSignIn.instance
            .authenticate();
        await user.authorizationClient.authorizeScopes(scopes);
        debugPrint('Name: ${user.displayName}');
        // debugPrint(userAuth.accessToken);
        // debugPrint(user.toString());
        setState(() {
          _user = user;
        });
      } else {
        // Handle web platform differently
        print('This platform requires platform-specific sign-in UI');
      }
    } catch (e) {
      print('Sign-in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return (!kIsWeb)
        ? ElevatedButton(onPressed: _signIn, child: Text('Đăng nhập bằng Google'))
        : renderButton(
            configuration: GSIButtonConfiguration(
              type: GSIButtonType.standard,
              text: GSIButtonText.signinWith,
              size: GSIButtonSize.medium,
            ),
          );
  }
}
