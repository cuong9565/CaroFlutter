import 'dart:convert';

import 'package:http/http.dart' as http;

class Service {
  static const apiUrl = String.fromEnvironment('API_URL');
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
