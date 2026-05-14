import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/app_strings.dart';

const String kBaseUrl = 'https://lokit-production.up.railway.app';

Future<String?> getJwtToken() async {
  // TODO: رجّع التوكن من المكان اللي مخزنه فيه
  // مثال SharedPreferences:
  // final prefs = await SharedPreferences.getInstance();
  // return prefs.getString('jwt_token');
  return null;
}

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<ProductDetailsData> _future;
  int quantity = 1;
  ProductVariantData? selectedVariant;
  bool cartLoading = false;
  bool wishlistLoading = false;

  @override
  void initState() {
    super.initState();
    _future = ProductApi.getProductDetails(widget.productId);
  }

  Future<void> addToCart(ProductDetailsData product) async {
    final token = await getJwtToken();

    if (token == null) {
      showMsg('Please login first');
      return;
    }

    final variant = selectedVariant ??
        (product.variants.isNotEmpty ? product.variants.first : null);

    if (variant == null) {
      showMsg('No product variant available');
      return;
    }

    setState(() => cartLoading = true);

    try {
      await ProductApi.addToCart(
        token: token,
        productVariantId: variant.id,
        quantity: quantity,
      );
      showMsg('Added to cart');
    } catch (e) {
      showMsg(e.toString());
    }

    if (mounted) setState(() => cartLoading = false);
  }

  Future<void> addToWishlist() async {
    final token = await getJwtToken();

    if (token == null) {
      showMsg('Please login first');
      return;
    }

    setState(() => wishlistLoading = true);

    try {
      await ProductApi.addToWishlist(
        token: token,
        productId: widget.productId,
      );
      showMsg('Added to wishlist');
    } catch (e) {
      showMsg(e.toString());
    }

    if (mounted) setState(() => wishlistLoading = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<ProductDetailsData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(snapshot.error.toString()),
                ),
              );
            }

            final product = snapshot.data!;
            selectedVariant ??=
                product.variants.isNotEmpty ? product.variants.first : null;

            final price = selectedVariant?.price ?? product.price;
            final total = price * quantity;

            return SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: Column(
                      children: [
                        _ProductImageHeader(
                          s: s,
                          imageUrl: product.mainImageUrl,
                          onWishlistTap: addToWishlist,
                          wishlistLoading: wishlistLoading,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TitlePriceQty(
                                name: product.name,
                                brand: product.brandName,
                                price: price,
                                quantity: quantity,
                                onMinus: () {
                                  if (quantity > 1) {
                                    setState(() => quantity--);
                                  }
                                },
                                onPlus: () {
                                  setState(() => quantity++);
                                },
                              ),
                              const SizedBox(height: 16),
                              _RatingRow(rating: product.rating),
                              const SizedBox(height: 24),
                              _SizeSection(
                                s: s,
                                variants: product.variants,
                                selected: selectedVariant,
                                onSelected: (v) {
                                  setState(() => selectedVariant = v);
                                },
                              ),
                              const SizedBox(height: 24),
                              _ColorSection(
                                variants: product.variants,
                                selected: selectedVariant,
                                onSelected: (v) {
                                  setState(() => selectedVariant = v);
                                },
                              ),
                              const SizedBox(height: 28),
                              Text(
                                s.productDescriptionTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                product.description.isEmpty
                                    ? s.productDescriptionBody
                                    : product.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${total.toStringAsFixed(2)} EGP',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed:
                                    cartLoading ? null : () => addToCart(product),
                                icon: cartLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.white,
                                      ),
                                label: Text(
                                  s.productAddToCartButton,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff74787D),
                                  disabledBackgroundColor:
                                      const Color(0xff74787D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ================= API ================= */

class ProductApi {
  static Future<ProductDetailsData> getProductDetails(int productId) async {
    final responses = await Future.wait([
      http.get(Uri.parse('$kBaseUrl/product/$productId/details')),
      http.get(Uri.parse('$kBaseUrl/variants/product/$productId')),
      http.get(Uri.parse('$kBaseUrl/product-images/product/$productId')),
    ]);

    for (final res in responses) {
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('API Error ${res.statusCode}: ${res.body}');
      }
    }

    final detailsJson = jsonDecode(responses[0].body);
    final variantsJson = jsonDecode(responses[1].body) as List;
    final imagesJson = jsonDecode(responses[2].body) as List;

    return ProductDetailsData.fromJson(
      detailsJson,
      variantsJson,
      imagesJson,
    );
  }

  static Future<void> addToCart({
    required String token,
    required int productVariantId,
    required int quantity,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/cart/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productVariantId': productVariantId,
        'quantity': quantity,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Cart Error ${res.statusCode}: ${res.body}');
    }
  }

  static Future<void> addToWishlist({
    required String token,
    required int productId,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/wishlist'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Wishlist Error ${res.statusCode}: ${res.body}');
    }
  }
}

/* ================= MODELS ================= */

class ProductDetailsData {
  final int id;
  final String name;
  final String brandName;
  final String description;
  final double price;
  final double rating;
  final String? mainImageUrl;
  final List<ProductVariantData> variants;

  ProductDetailsData({
    required this.id,
    required this.name,
    required this.brandName,
    required this.description,
    required this.price,
    required this.rating,
    required this.mainImageUrl,
    required this.variants,
  });

  factory ProductDetailsData.fromJson(
    dynamic json,
    List variantsJson,
    List imagesJson,
  ) {
    final map = json as Map<String, dynamic>;

    final imageMaps = imagesJson
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    Map<String, dynamic>? mainImage;

    if (imageMaps.isNotEmpty) {
      mainImage = imageMaps.firstWhere(
        (e) =>
            e['main'] == true ||
            e['isMain'] == true ||
            e['mainImage'] == true,
        orElse: () => imageMaps.first,
      );
    }

    final imageUrl = mainImage == null
        ? null
        : _fullImageUrl(
            _str(
              mainImage['imageUrl'] ??
                  mainImage['url'] ??
                  mainImage['imagePath'] ??
                  mainImage['path'],
            ),
          );

    return ProductDetailsData(
      id: _int(map['id'] ?? map['productId']),
      name: _str(map['name'] ?? map['productName'] ?? map['title']),
      brandName: _str(
        map['brandName'] ??
            map['brand']?['name'] ??
            map['brandResponse']?['name'],
      ),
      description: _str(map['description']),
      price: _double(map['price']),
      rating: _double(map['rating'] ?? map['averageRating']),
      mainImageUrl: imageUrl,
      variants: variantsJson
          .map((e) => ProductVariantData.fromJson(e))
          .toList(),
    );
  }
}

class ProductVariantData {
  final int id;
  final String size;
  final String color;
  final double price;
  final int stock;

  ProductVariantData({
    required this.id,
    required this.size,
    required this.color,
    required this.price,
    required this.stock,
  });

  factory ProductVariantData.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;

    return ProductVariantData(
      id: _int(map['id'] ?? map['variantId']),
      size: _str(
        map['size'] ??
            map['sizeName'] ??
            map['sizeResponse']?['name'],
      ),
      color: _str(
        map['color'] ??
            map['colorName'] ??
            map['colorResponse']?['name'],
      ),
      price: _double(map['price']),
      stock: _int(map['stock'] ?? map['quantity']),
    );
  }
}

String _str(dynamic value) => value?.toString() ?? '';

int _int(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String? _fullImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http')) return url;
  if (url.startsWith('/')) return '$kBaseUrl$url';
  return '$kBaseUrl/$url';
}

/* ================= UI ================= */

class _ProductImageHeader extends StatelessWidget {
  final AppStrings s;
  final String? imageUrl;
  final VoidCallback onWishlistTap;
  final bool wishlistLoading;

  const _ProductImageHeader({
    required this.s,
    required this.imageUrl,
    required this.onWishlistTap,
    required this.wishlistLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 430 / 430,
          child: imageUrl == null || imageUrl!.isEmpty
              ? Image.asset(
                  'lib/assets/product_sample.png',
                  fit: BoxFit.cover,
                )
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'lib/assets/product_sample.png',
                    fit: BoxFit.cover,
                  ),
                ),
        ),

        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.15),
          ),
        ),

        Positioned(
          top: 24,
          left: 24,
          child: _CircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
        ),

        Positioned(
          top: 24,
          right: 24,
          child: _CircleButton(
            icon: Icons.accessibility_new,
            onTap: () => showAiPhotoInstructions(context, s),
          ),
        ),

        Positioned(
          right: 24,
          bottom: 24,
          child: _CircleButton(
            icon: wishlistLoading
                ? Icons.hourglass_empty
                : Icons.favorite_border,
            onTap: wishlistLoading ? () {} : onWishlistTap,
          ),
        ),
      ],
    );
  }
}

class _TitlePriceQty extends StatelessWidget {
  final String name;
  final String brand;
  final double price;
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _TitlePriceQty({
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Product Name' : name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                brand.isEmpty ? 'Brand' : brand,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${price.toStringAsFixed(2)} EGP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              _QtyButton(icon: Icons.remove, onTap: onMinus),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _QtyButton(icon: Icons.add, onTap: onPlus),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;

  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final value = rating == 0 ? 4.5 : rating;

    return Row(
      children: [
        Row(
          children: List.generate(
            5,
            (_) => const Icon(
              Icons.star,
              size: 18,
              color: Color(0xffF6B23C),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SizeSection extends StatelessWidget {
  final AppStrings s;
  final List<ProductVariantData> variants;
  final ProductVariantData? selected;
  final ValueChanged<ProductVariantData> onSelected;

  const _SizeSection({
    required this.s,
    required this.variants,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final list = variants.where((e) => e.size.isNotEmpty).toList();

    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.productSizeLabel,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: list.map((variant) {
            final isSelected = selected?.id == variant.id;

            return InkWell(
              onTap: () => onSelected(variant),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xff6B6B6B)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  variant.size,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ColorSection extends StatelessWidget {
  final List<ProductVariantData> variants;
  final ProductVariantData? selected;
  final ValueChanged<ProductVariantData> onSelected;

  const _ColorSection({
    required this.variants,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final list = variants.where((e) => e.color.isNotEmpty).toList();

    if (list.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: list.map((variant) {
        final isSelected = selected?.id == variant.id;

        return InkWell(
          onTap: () => onSelected(variant),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: _colorFromName(variant.color),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _colorFromName(String name) {
    final n = name.toLowerCase();

    if (n.contains('black')) return Colors.black;
    if (n.contains('white')) return Colors.white;
    if (n.contains('red')) return Colors.red;
    if (n.contains('blue')) return Colors.blue;
    if (n.contains('green')) return Colors.green;
    if (n.contains('yellow')) return Colors.amber;
    if (n.contains('pink')) return Colors.pink;
    if (n.contains('grey') || n.contains('gray')) return Colors.grey;
    if (n.contains('brown')) return Colors.brown;
    if (n.contains('orange')) return Colors.orange;

    return const Color(0xffE2B15E);
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.65),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

/* ================= AI POPUP ================= */

void showAiPhotoInstructions(BuildContext context, AppStrings s) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 54),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                children: [
                  const Text(
                    'AI Try - Before - you - Buy ✨',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Select an image source',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: _AiSourceButton(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: افتح الكاميرا هنا
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _AiSourceButton(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: افتح المعرض هنا
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                children: [
                  const Text(
                    'Photo Instructions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'For best results :',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _instruction('1. Stand straight facing the camera.'),
                  _instruction('2. Ensure good lighting'),
                  _instruction('3. Keep arms slightly away from body.'),
                  _instruction('4. Make sure your full upper body is visible'),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _instruction(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: Colors.grey.shade600,
        ),
      ),
    ),
  );
}

class _AiSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AiSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: const Color(0xff1F2A30),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}