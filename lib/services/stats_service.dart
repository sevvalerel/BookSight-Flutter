import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../utils/api_error.dart';

class GenreCount {
  final String genre;
  final int count;

  GenreCount({required this.genre, required this.count});

  factory GenreCount.fromJson(Map<String, dynamic> json) {
    return GenreCount(
      genre: json['genre'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class MonthlyCount {
  final String month;
  final int count;

  MonthlyCount({required this.month, required this.count});

  factory MonthlyCount.fromJson(Map<String, dynamic> json) {
    return MonthlyCount(
      month: json['month'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class ReadingStats {
  final int totalReviews;
  final int reviewsThisMonth;
  final int reviewsThisYear;
  final double averageRating;
  final List<GenreCount> genreDistribution;
  final List<MonthlyCount> monthlyTrend;

  ReadingStats({
    required this.totalReviews,
    required this.reviewsThisMonth,
    required this.reviewsThisYear,
    required this.averageRating,
    required this.genreDistribution,
    required this.monthlyTrend,
  });

  factory ReadingStats.fromJson(Map<String, dynamic> json) {
    return ReadingStats(
      totalReviews: json['totalReviews'] as int? ?? 0,
      reviewsThisMonth: json['reviewsThisMonth'] as int? ?? 0,
      reviewsThisYear: json['reviewsThisYear'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      genreDistribution: (json['genreDistribution'] as List<dynamic>? ?? [])
          .map((e) => GenreCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyTrend: (json['monthlyTrend'] as List<dynamic>? ?? [])
          .map((e) => MonthlyCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StatsService {
  static const String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<ReadingStats> getMyStats() async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/stats/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return ReadingStats.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    }

    throw Exception(parseApiError(response));
  }
}
