import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_error.dart';

class UserProfile {
  final int userId;
  final String username;
  final String email;
  final String? createdAt;
  final String? bio;
  final String? avatarUrl;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.createdAt,
    this.bio,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      createdAt: json['createdAt'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
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
    }

    throw Exception(parseApiError(response));
  }

  Future<UserProfile> updateProfile({
    String? username,
    String? bio,
    String? avatarUrl,
    String? currentPassword,
    String? newPassword,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (bio != null) body['bio'] = bio;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    if (currentPassword != null) body['currentPassword'] = currentPassword;
    if (newPassword != null) body['newPassword'] = newPassword;

    final response = await http.put(
      Uri.parse('$_baseUrl/api/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      final profile = UserProfile.fromJson(userJson);

      final newToken = data['token'] as String?;
      if (newToken != null && newToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', newToken);
        await prefs.setString('username', profile.username);
      }

      return profile;
    }

    throw Exception(parseApiError(response));
  }
}
