import 'dart:typed_data';
import 'package:frontend/core/services/service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class B2Service {
  static Future<String?> uploadFile(Uint8List bytes, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Service.getUri("/b2/upload"),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      if (response.statusCode == 201 || response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return json['data']; // Đường dẫn proxy trả về từ backend
      }
    } catch (e) {
      print("Upload error: $e");
    }
    return null;
  }
}
