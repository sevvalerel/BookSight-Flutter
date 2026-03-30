import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _baseUrl = 'http://172.20.28.103:8080';

  Future<List<Book>> getBooks({String? search, String? genre}) async {
    String url = '$_baseUrl/api/books';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (genre != null && genre.isNotEmpty) params.add('genre=$genre');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Book.fromJson(e)).toList();
    } else {
      throw Exception('Kitaplar yüklenemedi.');
    }
  }

  Future<Book> getBookById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/books/$id'));
    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Kitap bulunamadı.');
    }
  }
}