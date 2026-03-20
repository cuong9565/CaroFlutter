import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/core/providers/chat_provider.dart';
import 'package:frontend/widgets/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  SocketService.init();
  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
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
