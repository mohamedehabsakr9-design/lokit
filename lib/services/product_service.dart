import 'api_service.dart';

class ProductService {
  static Future<List<dynamic>> getProducts() async {
    final data = await ApiService.get('/product');

    print('PRODUCTS RESPONSE: $data');

    if (data is List) {
      print('PRODUCTS COUNT: ${data.length}');
      return data;
    }

    print('PRODUCTS DATA IS NOT LIST');
    return [];
  }
}