import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  // POST Method
  static const FlutterSecureStorage storage = FlutterSecureStorage();
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api$endpoint');

    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',},
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      final errorResponse = jsonDecode(response.body);
      return {
        'success': errorResponse['success'],
        'error': errorResponse['error'] ?? 'An unknown error occurred.',
      };
    } catch (e) {
      throw 'Failed to connect to the server: $e';
    }
  }

  // **NEW: GET Method**
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/api$endpoint');
    print(url);
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      final errorResponse = jsonDecode(response.body);
      return {
        'success': errorResponse['success'],
        'error': errorResponse['error'] ?? 'An unknown error occurred.',
      };
    } catch (e) {
      throw 'Failed to connect to the server: $e';
    }
  }

  // DELETE Method
  static Future<Map<String, dynamic>> delete(
      String endpoint, Map<String, dynamic>? data) async {
    final url = Uri.parse('$baseUrl/api$endpoint');

    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',},
        body: data != null ? jsonEncode(data) : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      final errorResponse = jsonDecode(response.body);
      return {
        'success': errorResponse['success'],
        'error': errorResponse['error'] ?? 'An unknown error occurred.',
      };
    } catch (e) {
      throw 'Failed to connect to the server: $e';
    }
  }

  // NEW: File Download Method
static Future<Map<String, dynamic>> downloadFile(String endpoint) async {
  final url = Uri.parse('$baseUrl/api$endpoint');
  print('Downloading file from: $url');

  try {
    final token = await storage.read(key: 'jwt_token');
    // Make the API request
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',},
    );

    if (response.statusCode == 200) {
      // Extract filename from Content-Disposition header
      String? contentDisposition = response.headers['content-disposition'];
      String fileName = 'downloaded_file';
      if (contentDisposition != null && contentDisposition.contains('filename=')) {
        final parts = contentDisposition.split('filename=');
        if (parts.length > 1) {
          fileName = parts[1].replaceAll('"', '').trim();
        }
      }

      // Get the Downloads directory
      final directory = await getExternalStorageDirectory();
      final downloadsPath = '${directory!.parent.parent.parent.parent.path}/Download';
      final filePath = '$downloadsPath/$fileName';

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print('File saved to: $filePath');

      // Return success with file path
      return {
        'success': true,
        'filePath': filePath,
      };
    } else {
      return {
        'success': false,
        'error': 'Failed to download file: ${response.statusCode} ${response.reasonPhrase}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error downloading file: $e',
    };
  }
}


  // PUT Method (Optional for Updates)
  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api$endpoint');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      final errorResponse = jsonDecode(response.body);
      return {
        'success': errorResponse['success'],
        'error': errorResponse['error'] ?? 'An unknown error occurred.',
      };
    } catch (e) {
      throw 'Failed to connect to the server: $e';
    }
  }
}

