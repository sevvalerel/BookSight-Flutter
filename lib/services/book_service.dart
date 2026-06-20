import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/api_error.dart';

class Book {
  final int bookId;
  final String title;
  final String author;
  final String? genre;
  final int? publicationYear;
  final double? avgRating;
  final int? reviewCount;
  final String? description;
  final String? coverUrl;

  Book({
    required this.bookId,
    required this.title,
    required this.author,
    this.genre,
    this.publicationYear,
    this.avgRating,
    this.reviewCount,
    this.description,
    this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['bookId'],
      title: json['title'],
      author: json['author'],
      genre: json['genre'],
      publicationYear: json['publicationYear'],
      avgRating: json['avgRating']?.toDouble(),
      reviewCount: json['reviewCount'],
      description: json['description'],
      coverUrl: json['coverUrl'],
    );
  }
}

class BookService {
  static const String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, dynamic>> getBooks({
    String? search,
    String? genre,
    List<String>? genres,
    double? minRating,
    int page = 0,
    int size = 20,
  }) async {
    final token = await _getToken();
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (genres != null && genres.isNotEmpty) {
      queryParams['genres'] = genres;
    } else if (genre != null && genre.isNotEmpty) {
      queryParams['genre'] = genre;
    }
    if (minRating != null) queryParams['minRating'] = minRating.toString();

    final uri = Uri.parse('$_baseUrl/api/books')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final books = (data['content'] as List)
          .map((e) => Book.fromJson(e))
          .toList();
      return {
        'books': books,
        'hasNext': data['hasNext'] ?? false,
        'totalElements': data['totalElements'] ?? 0,
      };
    }
    throw Exception(parseApiError(response));
  }

  Future<Book> getBookById(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/books/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception(parseApiError(response));
  }
}