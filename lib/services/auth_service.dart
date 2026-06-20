import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/api_error.dart';

class AuthService {
  static const String _baseUrl = ApiConfig.baseUrl;

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final token = data['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      final username = data['username'] as String? ?? '';
      await prefs.setString('username', username);
      return token;
    }

    throw Exception(parseApiError(response));
  }

  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Kayıt başarılı fakat token alınamadı.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      final savedUsername = data['username'] as String? ?? username;
      await prefs.setString('username', savedUsername);
      return token;
    }

    throw Exception(parseApiError(response));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('username');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse('$_baseUrl/api/auth/forgot-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['message'] as String;
    }
    throw Exception(parseApiError(response));
  }

  Future<String> resetPassword(String code, String newPassword) async {
    final url = Uri.parse('$_baseUrl/api/auth/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code, 'newPassword': newPassword}),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['message'] as String;
    }
    throw Exception(parseApiError(response));
  }
}
