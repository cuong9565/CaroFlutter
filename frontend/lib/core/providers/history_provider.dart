import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/user_provider.dart';
import 'package:frontend/core/services/service.dart';
import 'package:http/http.dart' as http;

final historyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = await UserProvider.storage.read(key: 'uid');
  final String _apiUrl = Service.apiUrl;
  if (userId == null) return {};

  final response = await http.get(
    Uri.parse('${_apiUrl}/history/stats?userId=$userId'),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load history stats');
});

final historyRoomsProvider = FutureProvider<List<dynamic>>((ref) async {
  final userId = await UserProvider.storage.read(key: 'uid');
  if (userId == null) return [];

  final response = await http.get(
    Uri.parse('${_apiUrl}/history/rooms?userId=$userId'),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load history rooms');
});

final roomMatchesProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  roomId,
) async {
  final userId = await UserProvider.storage.read(key: 'uid');
  if (userId == null) return [];

  final response = await http.get(
    Uri.parse('${_apiUrl}/history/rooms/$roomId/matches?userId=$userId'),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load room matches');
});
