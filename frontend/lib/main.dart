import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/main_layout.dart';
import 'package:frontend/providers/chat_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: 'Caro Online',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SafeArea(child: Mainlayout()),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}