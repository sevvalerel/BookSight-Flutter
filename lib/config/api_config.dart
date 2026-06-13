import 'package:flutter/foundation.dart';

class ApiConfig {
  // Web: localhost, Mobil (emülatör): 10.0.2.2
  static const String baseUrl = kIsWeb 
      ? 'http://localhost:8080'
      : 'http://10.0.2.2:8080';
}