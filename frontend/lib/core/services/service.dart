import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Service {
  static final String apiUrl = dotenv.env['API_URL'] ?? '';

  // _handleResponse
  static dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error: ${response.statusCode}: ${response.body}");
    }
  }

  // getUri
  static Uri getUri(String url) {
    return Uri.parse("${Service.apiUrl}$url");
  }
}
