import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
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

class CheckinStatus {
  final bool alreadyCheckedIn;
  final int streak;
  final int totalPoints;

  CheckinStatus({
    required this.alreadyCheckedIn,
    required this.streak,
    required this.totalPoints,
  });

  factory CheckinStatus.fromJson(Map<String, dynamic> json) {
    return CheckinStatus(
      alreadyCheckedIn: json['alreadyCheckedIn'] ?? false,
      streak: json['streak'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
    );
  }
}

class LeaderboardEntry {
  final int userId;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int streak;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalPoints,
    required this.streak,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      totalPoints: json['totalPoints'] ?? 0,
      streak: json['streak'] ?? 0,
    );
  }
}

class PublicUserReview {
  final String? bookTitle;
  final String? bookCoverUrl;
  final int? rating;
  final String? reviewText;

  PublicUserReview({this.bookTitle, this.bookCoverUrl, this.rating, this.reviewText});

  factory PublicUserReview.fromJson(Map<String, dynamic> json) {
    return PublicUserReview(
      bookTitle: json['bookTitle'],
      bookCoverUrl: json['bookCoverUrl'],
      rating: json['rating'],
      reviewText: json['reviewText'],
    );
  }
}

class PublicUserProfile {
  final int userId;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int streak;
  final int reviewCount;
  final int readCount;
  final List<String> favoriteGenres;
  final List<PublicUserReview> reviews;

  PublicUserProfile({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalPoints,
    required this.streak,
    required this.reviewCount,
    required this.readCount,
    required this.favoriteGenres,
    required this.reviews,
  });

  factory PublicUserProfile.fromJson(Map<String, dynamic> json) {
    return PublicUserProfile(
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      totalPoints: json['totalPoints'] ?? 0,
      streak: json['streak'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      readCount: json['readCount'] ?? 0,
      favoriteGenres: List<String>.from(json['favoriteGenres'] ?? []),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => PublicUserReview.fromJson(e))
          .toList(),
    );
  }
}

class UserService {
  static const String _baseUrl = ApiConfig.baseUrl;

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

  Future<CheckinStatus> getCheckinStatus() async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/checkin/status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return CheckinStatus.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception(parseApiError(response));
  }

  Future<CheckinStatus> doCheckin() async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/checkin'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return CheckinStatus.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception(parseApiError(response));
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/users/leaderboard'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => LeaderboardEntry.fromJson(e)).toList();
    }
    throw Exception(parseApiError(response));
  }

  Future<PublicUserProfile> getUserPublicProfile(String username) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/$username'),
    );
    if (response.statusCode == 200) {
      return PublicUserProfile.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
