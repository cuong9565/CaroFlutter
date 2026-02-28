import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/providers/user_provider.dart';

final userNotifier =
    StateNotifierProvider<UserNotifier, AsyncValue<Map<String, dynamic>?>>(
      (ref) => UserNotifier(),
    );

class UserNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  UserNotifier() : super(const AsyncValue.data(null)) {
    loadUser();
  }

  Future<void> loadUser() async {
    state = const AsyncValue.loading();

    try {
      final data = await UserProvider.loadUser();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
