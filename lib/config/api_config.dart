import 'package:flutter/foundation.dart';

class ApiConfig {
  // flutter run (debug) -> lokal backend
  // flutter build web / Render deploy (release) -> canlı backend
  static const String baseUrl = kReleaseMode
      ? 'https://booksight.onrender.com'
      : (kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080');
}