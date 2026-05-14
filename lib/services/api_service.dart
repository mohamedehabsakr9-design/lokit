import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/api_constants.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  static Future<Map<String, String>> _authHeader() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token') ??
        prefs.getString('jwt') ??
        prefs.getString('accessToken');

    debugPrint('╔════════ AUTH HEADER ════════╗');
    debugPrint('Has Token: ${token != null && token.isNotEmpty}');
    debugPrint('╚═════════════════════════════╝');

    if (token != null && token.isNotEmpty) {
      return {
        'Authorization': 'Bearer $token',
      };
    }

    return {};
  }

  static Future<dynamic> get(
    String endpoint, {
    bool withAuth = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    final headers = withAuth ? await _authHeader() : <String, String>{};

    final response = await _dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final headers = withAuth ? await _authHeader() : <String, String>{};

    debugPrint('╔════════ API REQUEST ════════╗');
    debugPrint('URL  : ${ApiConstants.baseUrl}$endpoint');
    debugPrint('BODY : $body');
    debugPrint('╚═════════════════════════════╝');

    final response = await _dio.post(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final headers = withAuth ? await _authHeader() : <String, String>{};

    final response = await _dio.put(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final headers = withAuth ? await _authHeader() : <String, String>{};

    final response = await _dio.patch(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> delete(
    String endpoint, {
    bool withAuth = false,
  }) async {
    final headers = withAuth ? await _authHeader() : <String, String>{};

    final response = await _dio.delete(
      endpoint,
      options: Options(headers: headers),
    );

    return _handleResponse(response);
  }

  static dynamic _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    final body = response.data;

    debugPrint('╔════════ API RESPONSE ════════╗');
    debugPrint('STATUS : $statusCode');
    debugPrint('URL    : ${response.realUri}');
    debugPrint('BODY   : $body');
    debugPrint('╚═════════════════════════════╝');

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    String errorMessage = 'Request failed: $statusCode';

    if (body is Map) {
      final msg = body['message'] ??
          body['error'] ??
          body['msg'] ??
          body['detail'];

      if (msg != null) {
        errorMessage = msg.toString();
      }
    } else if (body != null) {
      errorMessage = body.toString();
    }

    throw Exception(errorMessage);
  }
}