import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQR extends StatelessWidget {
  final String url;
  const MyQR({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrImageView(
        data: url,
        version: QrVersions.auto,
        size: 200.0,
      ),
    );
  }
}
