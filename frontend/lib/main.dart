import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:frontend/core/providers/chat_provider.dart';
import 'package:frontend/widgets/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting();
  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<ChatProvider>(
          create: (_) {
            final chatProvider = ChatProvider();
            return chatProvider;
          },
        ),
      ],
      child: ProviderScope(
        child: MaterialApp.router(
          title: 'Caro Online',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          ),
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}

final gAuthToken = FutureProvider<Map<String, dynamic>?>((ref) => null);