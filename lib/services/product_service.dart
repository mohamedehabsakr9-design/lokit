import 'api_service.dart';

class ProductService {
  static Future<List<dynamic>> getProducts() async {
    final data = await ApiService.get('/product');

    print('PRODUCTS RESPONSE: $data');

    if (data is List) return data;
    if (data is Map && data['content'] is List) return data['content'];
    if (data is Map && data['products'] is List) return data['products'];
    if (data is Map && data['data'] is List) return data['data'];

    return [];
  }

  static Future<Map<String, dynamic>> getProductById(int productId) async {
    final data = await ApiService.get('/product/$productId');

    print('PRODUCT BY ID RESPONSE: $data');

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    return {};
  }

  static Future<Map<String, dynamic>> getProductDetails(int productId) async {
    final details = await ApiService.get('/product/$productId/details');

    print('PRODUCT DETAILS RESPONSE: $details');

    if (details is Map<String, dynamic>) return details;
    if (details is Map) return Map<String, dynamic>.from(details);

    return {};
  }

  static Future<List<dynamic>> getProductVariants(int productId) async {
    final data = await ApiService.get('/variants/product/$productId');

    print('PRODUCT VARIANTS RESPONSE: $data');

    if (data is List) return data;
    if (data is Map && data['content'] is List) return data['content'];
    if (data is Map && data['data'] is List) return data['data'];

    return [];
  }

  static Future<List<dynamic>> getProductImages(int productId) async {
    final data = await ApiService.get('/product-images/product/$productId');

    print('PRODUCT IMAGES RESPONSE: $data');

    if (data is List) return data;
    if (data is Map && data['content'] is List) return data['content'];
    if (data is Map && data['data'] is List) return data['data'];
    if (data is Map && data['images'] is List) return data['images'];

    return [];
  }

  static Future<Map<String, dynamic>> getFullProductDetails(
    int productId,
  ) async {
    final results = await Future.wait([
      getProductDetails(productId),
      getProductVariants(productId),
      getProductImages(productId),
    ]);

    final details = Map<String, dynamic>.from(results[0] as Map);
    final variants = results[1] as List<dynamic>;
    final images = results[2] as List<dynamic>;

    details['variants'] = variants;
    details['images'] = images;

    if ((details['imageUrl'] == null || details['imageUrl'].toString().isEmpty) &&
        images.isNotEmpty) {
      final firstImage = images.first;

      if (firstImage is String) {
        details['imageUrl'] = firstImage;
      }

      if (firstImage is Map) {
        details['imageUrl'] = firstImage['imageUrl'] ??
            firstImage['url'] ??
            firstImage['imagePath'] ??
            firstImage['path'];
      }
    }

    return details;
  }
}