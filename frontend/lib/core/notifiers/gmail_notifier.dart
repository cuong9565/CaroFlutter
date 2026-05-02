import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/core/providers/login_with_google_provider.dart';

final gmailNotifier =
    StateNotifierProvider<GmailNotifier, AsyncValue<Map<String, dynamic>?>>(
      (ref) => GmailNotifier(),
    );

class GmailNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  GmailNotifier() : super(const AsyncValue.data(null)) {
    loadGmail();
  }

  Future<void> loadGmail() async {
    state = const AsyncValue.loading();

    try {
      final data = await LoginWithGoogleProvider.loadGmail();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
