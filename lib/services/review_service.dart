import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Review {
  final int? reviewId;
  final String? reviewText;
  final int? rating;
  final String? username;

  Review({this.reviewId, this.reviewText, this.rating, this.username});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'],
      reviewText: json['reviewText'],
      rating: json['rating'],
      username: json['username'],
    );
  }
}

class ReviewService {
  static const String _baseUrl = 'http://172.20.28.103:8080';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<List<Review>> getReviews(int bookId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/reviews/book/$bookId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('Yorumlar yüklenemedi.');
    }
  }

  Future<List<Review>> getMyReviews() async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/reviews/my'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('Yorumlar yüklenemedi.');
    }
  }

  Future<void> addReview({
    required int bookId,
    required String reviewText,
    required int rating,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bookId': bookId,
        'reviewText': reviewText,
        'rating': rating,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Yorum eklenemedi: ${response.statusCode}');
    }
  }
  Future<void> deleteReview(int reviewId) async {
  final token = await _getToken();
  if (token == null) throw Exception('Oturum açılmamış.');

  final response = await http.delete(
    Uri.parse('$_baseUrl/api/reviews/$reviewId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Yorum silinemedi: ${response.statusCode}');
  }
}
}