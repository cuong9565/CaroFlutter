import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyErrorPageURL extends StatelessWidget {
  const MyErrorPageURL({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          Text(
            'Trang không tồn tại - Vui lòng nhập đúng đường dẫn',
            style: TextStyle(fontSize: 18),
          ),
          ElevatedButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: Text('Quay lại'),
          ),
        ],
      ),
    );
  }
}
