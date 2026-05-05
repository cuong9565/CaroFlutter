import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/providers/login_with_email_provider.dart';

final emailNotifier =
    StateNotifierProvider<EmailNotifier, AsyncValue<Map<String, dynamic>?>>(
      (ref) => EmailNotifier(),
    );

class EmailNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  EmailNotifier() : super(const AsyncValue.data(null)) {
    loadEmail();
  }

  Future<void> loadEmail() async {
    state = const AsyncValue.loading();

    try {
      final data = await LoginWithEmailProvider.loadEmail();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
