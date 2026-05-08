import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../app/api_constants.dart';

class ApiService {
  static Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<dynamic> get(
    String endpoint, {
    bool withAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final response = await http.get(
      url,
      headers: await _headers(withAuth: withAuth),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final response = await http.post(
      url,
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final response = await http.put(
      url,
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final response = await http.patch(
      url,
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> delete(
    String endpoint, {
    bool withAuth = false,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final response = await http.delete(
      url,
      headers: await _headers(withAuth: withAuth),
    );

    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }

    throw Exception('Request failed: $statusCode - $body');
  }
}