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

  Future<Map<String, dynamic>> me({required String token}) async {
    final res = await http.get(
      _u('/api/v1/auth/me'),
      headers: {'authorization': 'Bearer $token'},
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> updateMe({
    required String token,
    String? phoneNumberE164,
    double? goalFinalGrade,
  }) async {
    final res = await http.patch(
      _u('/api/v1/users/me'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (phoneNumberE164 != null) 'phoneNumberE164': phoneNumberE164,
        if (goalFinalGrade != null) 'goalFinalGrade': goalFinalGrade,
      }),
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

  Future<Map<String, dynamic>> updateGrades({
    required String token,
    required String classId,
    required List<Map<String, dynamic>> grades,
  }) async {
    final res = await http.post(
      _u('/api/v1/grades/update'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({'classId': classId, 'grades': grades}),
    );
    return _decode(res);
  }

  Future<void> deleteClass({required String token, required String classId}) async {
    final res = await http.delete(
      _u('/api/v1/classes/$classId'),
      headers: {'authorization': 'Bearer $token'},
    );
    if (res.statusCode == 204) return;
    _decode(res); // throw if error
  }

  Future<Map<String, dynamic>> patchClass({
    required String token,
    required String classId,
    String? className,
    double? assumedRemainingAverage,
  }) async {
    final res = await http.patch(
      _u('/api/v1/classes/$classId'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (className != null) 'className': className,
        if (assumedRemainingAverage != null) 'assumedRemainingAverage': assumedRemainingAverage,
      }),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> patchClassEvents({
    required String token,
    required String classId,
    required List<Map<String, dynamic>> events,
  }) async {
    final res = await http.patch(
      _u('/api/v1/classes/$classId/events'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({'events': events}),
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
