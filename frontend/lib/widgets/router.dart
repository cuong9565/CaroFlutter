import 'package:flutter/cupertino.dart';
import 'package:frontend/screens/account.dart';
import 'package:frontend/screens/chat.dart';
import 'package:frontend/screens/friends.dart';
import 'package:frontend/screens/history.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/widgets/main_layout.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child){
        return SafeArea(child: Mainlayout(child: child));
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Home(),
        ),
        GoRoute(
          path: '/chat',
          builder: (_, _) => const Chat(),
        ),
        GoRoute(
          path: '/friends',
          builder: (_, _) => const Friends(),
        ),
        GoRoute(
          path: '/history',
          builder: (_, _) => const History(),
        ),
        GoRoute(
          path: '/account',
          builder: (_, _) => const Account(),
        ),
      ]
    ),

  ],
);

int findIndexByPath(BuildContext context){
  final location = GoRouterState.of(context).uri.toString();
  if(location.startsWith('/chat')) return 1;
  if(location.startsWith('/friends')) return 2;
  if(location.startsWith('/history')) return 3;
  if(location.startsWith('/account')) return 4;
  return 0;
}