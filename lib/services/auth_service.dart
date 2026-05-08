import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // تسجيل الدخول
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

    final token = data['token'] ?? data['accessToken'] ?? data['jwt'];

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.toString());
    }

    return data;
  }

  // تسجيل مستخدم جديد
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

    final token = data['token'] ?? data['accessToken'] ?? data['jwt'];

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.toString());
    }

    return data;
  }

  // تغيير الباسورد
  static Future<dynamic> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    return ApiService.patch(
      '/account/password',
      {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      },
      withAuth: true,
    );
  }

  // طلب إعادة تعيين الباسورد (Forget Password)
  static Future<dynamic> forgotPassword({required String email}) async {
    return ApiService.post(
      '/auth/forgot-password',
      {'email': email},
    );
  }

  // إعادة تعيين الباسورد بعد OTP (Reset Password)
  static Future<dynamic> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return ApiService.post(
      '/auth/reset-password',
      {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
    );
  }

  // التحقق من تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return token != null && token.isNotEmpty;
  }

  // جلب التوكن
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // تسجيل الخروج
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}