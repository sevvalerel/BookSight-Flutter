import 'dart:convert';
import 'package:http/http.dart' as http;

String parseApiError(http.Response response) {
  try {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
  } catch (_) {}
  return 'Bir hata oluştu';
}
