
import 'api_service.dart';

class WishlistService {
  static Future<List<dynamic>> getWishlist() async {
    final data = await ApiService.get(
      '/wishlist',
      withAuth: true,
    );

    print('WISHLIST RESPONSE: $data');

    if (data is List) {
      return data;
    }

    if (data is Map && data['content'] is List) {
      return data['content'];
    }

    if (data is Map && data['items'] is List) {
      return data['items'];
    }

    if (data is Map && data['data'] is List) {
      return data['data'];
    }

    if (data is Map && data['wishlist'] is List) {
      return data['wishlist'];
    }

    return [];
  }

  static Future<dynamic> addToWishlist(int productId) async {
    try {
      final response = await ApiService.post(
        '/wishlist',
        {
          'productId': productId,
        },
        withAuth: true,
      );

      print('ADD TO WISHLIST RESPONSE: $response');

      return response;
    } catch (e) {
      print('ADD TO WISHLIST ERROR: $e');

      // fallback endpoint
      return await ApiService.post(
        '/wishlist/add',
        {
          'productId': productId,
        },
        withAuth: true,
      );
    }
  }

  static Future<void> removeFromWishlist(int productId) async {
    try {
      await ApiService.delete(
        '/wishlist/$productId',
        withAuth: true,
      );
    } catch (e) {
      print('REMOVE WISHLIST ERROR: $e');

      // fallback endpoint
      await ApiService.delete(
        '/wishlist/remove/$productId',
        withAuth: true,
      );
    }
  }

  static Future<bool> isInWishlist(int productId) async {
    final wishlist = await getWishlist();

    return wishlist.any((item) {
      if (item is! Map) return false;

      final id =
          item['id'] ??
          item['productId'] ??
          item['product']?['id'];

      return id == productId;
    });
  }
}

