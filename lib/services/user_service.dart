import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final int userId;
  final String username;
  final String email;
  final String? createdAt;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      createdAt: json['createdAt'],
    );
  }
}

class UserService {
  static const String _baseUrl = 'http://172.20.28.103:8080';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<UserProfile> getMyProfile() async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception('Profil bilgisi alınamadı.');
    }
  }
}