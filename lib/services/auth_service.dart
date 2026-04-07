import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://172.20.28.103:8080';

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );



      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        final username = data['username'] as String? ?? '';
        await prefs.setString('username', username);
        return token;
      } else if (response.statusCode == 401) {
        throw Exception('E-posta veya şifre hatalı.');
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {

      rethrow;
    }
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
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
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

    if (response.statusCode == 400) {
      throw Exception('Kayıt bilgileri geçersiz.');
    } else if (response.statusCode == 409) {
      throw Exception('Bu e-posta veya kullanıcı adı zaten kayıtlı.');
    } else {
      throw Exception('Kayıt başarısız: ${response.statusCode}');
    }
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
}
