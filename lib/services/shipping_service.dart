import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShippingService {
  static const String _baseUrl = 'https://lokit-production.up.railway.app';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<Options> _authOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return Options(
      headers: {
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );
  }

  // جلب العناوين
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    final response = await _dio.get(
      '/shipping/addresses',
      options: await _authOptions(),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // إضافة عنوان جديد
  static Future<bool> addAddress(Map<String, dynamic> address) async {
    final response = await _dio.post(
      '/shipping/addresses',
      data: address,
      options: await _authOptions(),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // تعديل عنوان موجود
  static Future<bool> updateAddress(
      String id, Map<String, dynamic> address) async {
    final response = await _dio.put(
      '/shipping/addresses/$id',
      data: address,
      options: await _authOptions(),
    );
    return response.statusCode == 200;
  }
}