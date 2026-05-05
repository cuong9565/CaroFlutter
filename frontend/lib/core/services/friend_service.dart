import 'dart:convert';

import 'package:frontend/core/services/service.dart';
import 'package:http/http.dart' as http;

class FriendService {
  // /friends/request-by-uuid
  static Future<dynamic> requestByUuid(
    String requesterId,
    String targetUuid,
  ) async {
    final response = await http.post(
      Service.getUri('/friends/request-by-uuid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requesterId': requesterId,
        'targetUuid': targetUuid,
      }),
    );
    final data = Service.handleResponse(response);
    return data;
  }

  // /friends/list/:userId
  static Future<dynamic> getFriendsList(String userId) async {
    final response = await http.get(
      Service.getUri('/friends/list/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    final data = Service.handleResponse(response);
    return data;
  }

  // /friends/requests/:userId
  static Future<dynamic> getFriendRequests(String userId) async {
    final response = await http.get(
      Service.getUri('/friends/requests/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    final data = Service.handleResponse(response);
    return data;
  }

  // /friends/accept
  static Future<dynamic> acceptRequest(
    String friendRecordId,
    String userId,
  ) async {
    final response = await http.post(
      Service.getUri('/friends/accept'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'friendRecordId': friendRecordId,
        'userId': userId,
      }),
    );
    final data = Service.handleResponse(response);
    return data;
  }

  // /friends/reject
  static Future<dynamic> rejectRequest(
    String friendRecordId,
    String userId,
  ) async {
    final response = await http.post(
      Service.getUri('/friends/reject'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'friendRecordId': friendRecordId,
        'userId': userId,
      }),
    );
    final data = Service.handleResponse(response);
    return data;
  }

  // /friends/remove
  static Future<dynamic> removeFriend(
    String friendRecordId,
    String userId,
  ) async {
    final response = await http.post(
      Service.getUri('/friends/remove'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'friendRecordId': friendRecordId,
        'userId': userId,
      }),
    );
    final data = Service.handleResponse(response);
    return data;
  }
}
