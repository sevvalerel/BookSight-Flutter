import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_error.dart';

class LibraryEntry {
  final int bookId;
  final String title;
  final String author;
  final String? coverUrl;
  final String status;
  final String? updatedAt;

  LibraryEntry({
    required this.bookId,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.status,
    this.updatedAt,
  });

  factory LibraryEntry.fromJson(Map<String, dynamic> json) {
    return LibraryEntry(
      bookId: json['bookId'],
      title: json['title'],
      author: json['author'],
      coverUrl: json['coverUrl'],
      status: json['status'],
      updatedAt: json['updatedAt'],
    );
  }
}

class ReadingStatusService {
  static const String _baseUrl = 'http://172.20.28.103:8080';

  static const String statusReading = 'READING';
  static const String statusWillRead = 'WILL_READ';
  static const String statusRead = 'READ';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> addOrUpdate(int bookId, String status) async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/reading-status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bookId': bookId,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(parseApiError(response));
    }
  }

  Future<List<LibraryEntry>> getMyLibrary() async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/reading-status/my'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => LibraryEntry.fromJson(e)).toList();
    }

    throw Exception(parseApiError(response));
  }

  Future<void> remove(int bookId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Oturum açılmamış.');

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/reading-status/$bookId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(parseApiError(response));
    }
  }
}
