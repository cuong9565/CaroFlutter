import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/widgets/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  SocketService.init();
  runApp(
    ProviderScope(
      child: MaterialApp.router(
        title: 'Caro Online',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

final gAuthToken = FutureProvider<Map<String, dynamic>?>((ref) => null);
