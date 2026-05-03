import 'package:frontend/core/services/service.dart';
import 'package:http/http.dart' as http;

class HistoryService {
  static Future<dynamic> getOverallStats(String userId) async {
    final response = await http.get(
      Service.getUri("/history/stats?userId=$userId"),
      headers: {"Content-Type": "application/json"},
    );
    return Service.handleResponse(response);
  }

  static Future<List<dynamic>> getMatchHistory(String userId) async {
    final response = await http.get(
      Service.getUri("/history/rooms?userId=$userId"),
      headers: {"Content-Type": "application/json"},
    );
    return Service.handleResponse(response) as List<dynamic>;
  }

  static Future<List<dynamic>> getRoomMatches(String roomId, String userId) async {
    final response = await http.get(
      Service.getUri("/history/rooms/$roomId/matches?userId=$userId"),
      headers: {"Content-Type": "application/json"},
    );
    return Service.handleResponse(response) as List<dynamic>;
  }
}
