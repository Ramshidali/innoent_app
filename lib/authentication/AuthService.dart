import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://64.227.144.183:81/api/v1';
  static final storage = FlutterSecureStorage();

  static Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('data')) {
        final access = data['data']['access'];
        // Store the token locally
        await storage.write(key: 'token', value: access);
        return access; // Return the token
      } else {
        throw Exception('Access token not found in response');
      }
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      if (errorData.containsKey('message')) {
        final String errorMessage = errorData['message'];
        throw Exception(errorMessage);
      } else {
        throw Exception('Error message not found in response body');
      }
    }
  }

  static Future<String?> getToken() async {
    // Retrieve the token from local storage
    return await storage.read(key: 'token');
  }
}
