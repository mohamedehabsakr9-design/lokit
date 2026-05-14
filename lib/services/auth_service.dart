import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String baseUrl = "https://lokit-production.up.railway.app";

  // ===================== تسجيل الدخول =====================
  static Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    debugPrint('=== LOGIN RESPONSE ===');
    debugPrint(data.toString());
    debugPrint('======================');

    final token = data['token'] ??
        data['accessToken'] ??
        data['access_token'] ??
        data['jwt'] ??
        data['Authorization'];

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.toString());
      debugPrint('✅ Token saved!');
    } else {
      debugPrint('❌ No token found in response!');
    }

    return data;
  }

  // ===================== تسجيل مستخدم جديد =====================
  static Future<dynamic> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    final data = await ApiService.post(
      '/auth/register',
      {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );

    debugPrint('=== REGISTER RESPONSE ===');
    debugPrint(data.toString());

    final token = data['token'] ??
        data['accessToken'] ??
        data['access_token'] ??
        data['jwt'];

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.toString());
    }

    return data;
  }

  // ===================== تغيير الباسورد =====================
  static Future<dynamic> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception(
        "User not logged in / الرجاء تسجيل الدخول أولاً",
      );
    }

    try {
      final response = await ApiService.patch(
        '/account/password',
        {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        withAuth: true,
      );

      return response;
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception(
          "Forbidden: Old password might be wrong or user not authorized",
        );
      }

      rethrow;
    }
  }

  // ===================== طلب إعادة تعيين الباسورد =====================
  static Future<bool> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/forgot-password',
        {
          'email': email,
        },
      );

      if (response == null) return false;

      if (response['success'] != null) {
        return response['success'] == true;
      }

      if (response['message'] != null ||
          response['token'] != null) {
        return true;
      }

      return true;
    } catch (e) {
      debugPrint('❌ forgotPassword error: $e');
      return false;
    }
  }

  // ===================== التحقق من كود OTP =====================
  static Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/verify-reset-code',
        {
          'email': email,
          'code': code,
        },
      );

      if (response == null) return false;

      if (response['success'] != null) {
        return response['success'] == true;
      }

      if (response['message'] != null) {
        return true;
      }

      return true;
    } catch (e) {
      debugPrint('❌ verifyResetCode error: $e');
      return false;
    }
  }

  // ===================== إعادة تعيين الباسورد =====================
  static Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/reset-password',
        {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      if (response == null) return false;

      if (response['success'] != null) {
        return response['success'] == true;
      }

      if (response['message'] != null ||
          response['token'] != null) {
        return true;
      }

      return true;
    } catch (e) {
      debugPrint('❌ resetPassword error: $e');
      return false;
    }
  }

  // ===================== التحقق من تسجيل الدخول =====================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return token != null && token.isNotEmpty;
  }

  // ===================== جلب التوكن =====================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ===================== تسجيل الخروج =====================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    debugPrint('✅ Token cleared — user logged out');
  }
}