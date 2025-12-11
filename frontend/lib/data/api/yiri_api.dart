import 'dart:convert';

import 'package:http/http.dart' as http;

class YiriApi {
  final String baseUrl;

  const YiriApi({required this.baseUrl});

  Uri _u(String path) => Uri.parse(baseUrl).resolve(path);

  Future<Map<String, dynamic>> register({required String email, required String password}) async {
    final res = await http.post(
      _u('/api/v1/auth/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await http.post(
      _u('/api/v1/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> listClasses({required String token}) async {
    final res = await http.get(
      _u('/api/v1/classes'),
      headers: {'authorization': 'Bearer $token'},
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> submitSyllabus({
    required String token,
    required String className,
    required String syllabusText,
    String? phoneNumberE164,
    double? assumedRemainingAverage,
  }) async {
    final res = await http.post(
      _u('/api/v1/syllabus/submit'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'className': className,
        'syllabusText': syllabusText,
        if (phoneNumberE164 != null && phoneNumberE164.trim().isNotEmpty) 'phoneNumberE164': phoneNumberE164,
        if (assumedRemainingAverage != null) 'assumedRemainingAverage': assumedRemainingAverage,
      }),
    );
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    final body = res.body.isEmpty ? '{}' : res.body;
    final decoded = jsonDecode(body) as Map<String, dynamic>;

    if (res.statusCode >= 400) {
      final err = decoded['error'];
      final message = err is Map<String, dynamic> ? (err['message']?.toString() ?? 'Request failed') : 'Request failed';
      throw ApiException(message, statusCode: res.statusCode, payload: decoded);
    }

    return decoded;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic> payload;

  ApiException(this.message, {required this.statusCode, required this.payload});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
