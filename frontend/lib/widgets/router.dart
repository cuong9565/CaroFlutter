import 'package:flutter/material.dart';
import 'package:frontend/screens/account.dart';
import 'package:frontend/screens/chat.dart';
import 'package:frontend/screens/friends.dart';
import 'package:frontend/screens/game_online.dart';
import 'package:frontend/screens/game.dart';
import 'package:frontend/screens/game_machine.dart';
import 'package:frontend/screens/history.dart';
import 'package:frontend/screens/history_detail.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/signin.dart';
import 'package:frontend/screens/play_with_friend.dart';
import 'package:frontend/widgets/layout/my_error.dart';
import 'package:frontend/widgets/main_layout.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) =>
      SafeArea(child: Scaffold(body: MyErrorPageURL())),
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return SafeArea(
          child: Scaffold(body: Mainlayout(child: child)),
        );
      },
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Home()),
        GoRoute(path: '/chat', builder: (_, _) => const Chat()),
        GoRoute(path: '/friends', builder: (_, _) => const Friends()),
        GoRoute(path: '/history', builder: (_, _) => const History()),
        GoRoute(path: '/account', builder: (_, _) => const Account()),
      ],
    ),
    GoRoute(
      path: '/game',
      builder: (_, _) => const SafeArea(child: Scaffold(body: Game())),
    ),
    GoRoute(
      path: '/game-online',
      builder: (_, _) => const SafeArea(child: Scaffold(body: GameOnline())),
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const SafeArea(child: Scaffold(body: Login())),
    ),
    GoRoute(
      path: '/signin',
      builder: (_, _) => const SafeArea(child: Scaffold(body: Signin())),
    ),
    GoRoute(
      path: '/history/:roomId',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return SafeArea(child: HistoryDetail(roomId: roomId));
      },
    ),
    GoRoute(
      path: '/play/:idRoom',
      builder: (context, state) {
        final idRoom = state.pathParameters['idRoom']!;
        return SafeArea(
          child: Scaffold(body: PlayWithFriend(idRoom: idRoom)),
        );
      },
    ),
    GoRoute(
      path: '/play-ai/:idRoom',
      builder: (context, state) {
        final idRoom = state.pathParameters['idRoom']!;
        return SafeArea(
          child: Scaffold(body: GameMachine(idRoom: idRoom)),
        );
      },
    ),
  ],
);

int findIndexByPath(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.startsWith('/chat')) return 1;
  if (location.startsWith('/friends')) return 2;
  if (location.startsWith('/history')) return 3;
  if (location.startsWith('/account')) return 4;
  return 0;
}
