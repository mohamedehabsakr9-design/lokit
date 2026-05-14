class ProductSearchModel {
  final int id;
  final String name;
  final String? description;
  final String brandName;
  final String categoryName;
  final String? imageUrl;
  final double minPrice;

  ProductSearchModel({
    required this.id,
    required this.name,
    this.description,
    required this.brandName,
    required this.categoryName,
    this.imageUrl,
    required this.minPrice,
  });

  factory ProductSearchModel.fromJson(Map<String, dynamic> json) {
    return ProductSearchModel(
      id:           json['id'] as int,
      name:         json['name'] as String? ?? '',
      description:  json['description'] as String?,
      brandName:    json['brandName'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      imageUrl:     json['imageUrl'] as String?,
      minPrice:     double.tryParse(json['minPrice'].toString()) ?? 0.0,
    );
  }
}