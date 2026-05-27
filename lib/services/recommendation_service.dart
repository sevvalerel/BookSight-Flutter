import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/api_error.dart';
import 'book_service.dart';

class BookRecommendation {
  final int bookId;
  final String title;
  final String author;
  final String? coverUrl;
  final String? genre;
  final List<String> detectedLabels;
  final double confidenceScore;
  final String reason;

  BookRecommendation({
    required this.bookId,
    required this.title,
    required this.author,
    this.coverUrl,
    this.genre,
    required this.detectedLabels,
    required this.confidenceScore,
    required this.reason,
  });

  factory BookRecommendation.fromJson(Map<String, dynamic> json) {
    return BookRecommendation(
      bookId: json['bookId'] as int,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      coverUrl: json['coverUrl'] as String?,
      genre: json['genre'] as String?,
      detectedLabels: (json['detectedLabels'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String? ?? '',
    );
  }

  Book toBook() {
    return Book(
      bookId: bookId,
      title: title,
      author: author,
      genre: genre,
      coverUrl: coverUrl,
    );
  }
}

class RecommendationService {
  static const String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, int>> reanalyze() async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/recommendations/reanalyze'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        'total': data['total'] as int? ?? 0,
        'processed': data['processed'] as int? ?? 0,
      };
    }

    throw Exception(parseApiError(response));
  }

  Future<Map<String, dynamic>> getRecommendations() async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recommendations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final List recs = data['recommendations'] as List;
      return {
        'recommendations': recs.map((e) => BookRecommendation.fromJson(e)).toList(),
        'analyzedReviews': data['analyzedReviews'] as int? ?? 0,
      };
    }

    throw Exception(parseApiError(response));
  }
}
