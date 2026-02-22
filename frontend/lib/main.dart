import 'package:flutter/material.dart';
import 'package:frontend/widgets/router.dart';

void main() {
  runApp(MaterialApp.router(
      title: 'Caro Online',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
  ));
}