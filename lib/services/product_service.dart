import 'api_service.dart';

class ProductService {
  static Future<List<dynamic>> getProducts() async {
    final data = await ApiService.get('/product');

    print('PRODUCTS RESPONSE: $data');

    if (data is List) {
      print('PRODUCTS COUNT: ${data.length}');
      return data;
    }

    if (data is Map && data['content'] is List) {
      return data['content'];
    }

    if (data is Map && data['products'] is List) {
      return data['products'];
    }

    if (data is Map && data['data'] is List) {
      return data['data'];
    }

    print('PRODUCTS DATA IS NOT LIST');
    return [];
  }

  static Future<Map<String, dynamic>> getProductById(int productId) async {
    final data = await ApiService.get('/product/$productId');

    print('PRODUCT BY ID RESPONSE: $data');

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }

  static Future<Map<String, dynamic>> getProductDetails(int productId) async {
    final data = await ApiService.get('/product/$productId/details');

    print('PRODUCT DETAILS RESPONSE: $data');

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }
}