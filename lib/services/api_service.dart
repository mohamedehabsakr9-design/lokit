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

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token') ??
        prefs.getString('jwt') ??
        prefs.getString('accessToken');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setString('jwt', token);
    await prefs.setString('accessToken', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('jwt');
    await prefs.remove('accessToken');
  }

  static Future<Map<String, String>> _authHeader() async {
    final token = await getToken();

    debugPrint('Has Token: ${token != null && token.isNotEmpty}');

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
    try {
      final headers = withAuth ? await _authHeader() : <String, String>{};

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic>? body, {
    bool withAuth = false,
  }) async {
    try {
      final headers = withAuth ? await _authHeader() : <String, String>{};

      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic>? body, {
    bool withAuth = false,
  }) async {
    try {
      final headers = withAuth ? await _authHeader() : <String, String>{};

      final response = await _dio.put(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }

  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic>? body, {
    bool withAuth = false,
  }) async {
    try {
      final headers = withAuth ? await _authHeader() : <String, String>{};

      final response = await _dio.patch(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }

  static Future<dynamic> delete(
    String endpoint, {
    bool withAuth = false,
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = withAuth ? await _authHeader() : <String, String>{};

      final response = await _dio.delete(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }

  static dynamic _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    final body = response.data;

    debugPrint('STATUS: $statusCode');
    debugPrint('URL: ${response.realUri}');
    debugPrint('BODY: $body');

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    String errorMessage = 'Request failed: $statusCode';

    if (statusCode == 401) {
      errorMessage = 'Unauthorized. Please login again.';
    } else if (statusCode == 403) {
      errorMessage = 'Forbidden. You do not have permission.';
    } else if (statusCode == 404) {
      errorMessage = 'Not found.';
    }

    if (body is Map) {
      final msg = body['message'] ??
          body['error'] ??
          body['msg'] ??
          body['detail'] ??
          body['errors'];

      if (msg != null) {
        errorMessage = msg.toString();
      }
    } else if (body != null) {
      errorMessage = body.toString();
    }

    throw Exception(errorMessage);
  }

  static String _dioErrorMessage(DioException e) {
    final response = e.response;

    if (response != null) {
      try {
        _handleResponse(response);
      } catch (err) {
        return err.toString().replaceFirst('Exception: ', '');
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Try again.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Try again.';
      case DioExceptionType.connectionError:
        return 'Connection error. Check your internet.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return e.message ?? 'Network error.';
    }
  }
}