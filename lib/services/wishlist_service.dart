import 'api_service.dart';

class WishlistService {
  static Future<List<dynamic>> getWishlist() async {
    final data = await ApiService.get(
      '/wishlist',
      withAuth: true,
    );

    if (data is List) {
      return data;
    }

    return [];
  }

  static Future<dynamic> addToWishlist(int productId) async {
    return ApiService.post(
      '/wishlist',
      {
        'productId': productId,
      },
      withAuth: true,
    );
  }

  static Future<void> removeFromWishlist(int productId) async {
    await ApiService.delete(
      '/wishlist/$productId',
      withAuth: true,
    );
  }
}