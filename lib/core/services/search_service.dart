import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/product_search_model.dart';

class SearchService {
  final Dio _dio = ApiClient().dio;

  Future<List<ProductSearchModel>> searchProducts({
    String? keyword,
    int? brandId,
    int? categoryId,
    int? colorId,
    int? sizeId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final Map<String, dynamic> params = {};

    if (keyword    != null && keyword.isNotEmpty) params['keyword']    = keyword;
    if (brandId    != null) params['brandId']    = brandId;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (colorId    != null) params['colorId']    = colorId;
    if (sizeId     != null) params['sizeId']     = sizeId;
    if (minPrice   != null) params['minPrice']   = minPrice;
    if (maxPrice   != null) params['maxPrice']   = maxPrice;

    final response = await _dio.get(
      ApiEndpoints.search,
      queryParameters: params,
    );

    return (response.data as List<dynamic>)
        .map((e) => ProductSearchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}