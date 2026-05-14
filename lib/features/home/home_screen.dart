import 'package:flutter/material.dart';
import '../notifications/notification_screen.dart';
import '../profile/profile_menu_screen.dart';
import '../products/product_details_screen.dart';
import '../../app/app_strings.dart';
import '../../services/product_service.dart';

import '../products/search_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../cart/my_cart_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showSuccess;

  const HomeScreen({
    super.key,
    this.showSuccess = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _showSuccessOverlay;

  String _searchQuery = '';
  bool _isLoadingProducts = true;
  String? _productsError;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _showSuccessOverlay = widget.showSuccess;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      final products = await ProductService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _productsError = e.toString();
        _isLoadingProducts = false;
      });
    }
  }

  void _hideSuccessOverlay() {
    setState(() {
      _showSuccessOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: s.homeSearchHint,
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_none),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _TopBanner(),
                            const SizedBox(height: 20),

                            Text(
                              s.homeShopByBrand,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 8),
                            const _BrandRow(),
                            const SizedBox(height: 20),

                            if (_isLoadingProducts)
                              const SizedBox(
                                height: 260,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_productsError != null)
                              SizedBox(
                                height: 260,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 36,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Failed to load products',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _loadProducts,
                                        child: const Text('Try again'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              _ProductSection(
                                title: s.homeTopRated,
                                products: _products,
                                searchQuery: _searchQuery,
                              ),
                              const SizedBox(height: 16),
                              _ProductSection(
                                title: s.homeMen,
                                products: _products,
                                searchQuery: _searchQuery,
                                departmentFilter: 'men',
                              ),
                              const SizedBox(height: 16),
                              _ProductSection(
                                title: s.homeWomen,
                                products: _products,
                                searchQuery: _searchQuery,
                                departmentFilter: 'women',
                              ),
                              const SizedBox(height: 16),
                              _ProductSection(
                                title: s.homeKids,
                                products: _products,
                                searchQuery: _searchQuery,
                                departmentFilter: 'kids',
                              ),
                              const SizedBox(height: 16),
                              _ProductSection(
                                title: s.homeUnisex,
                                products: _products,
                                searchQuery: _searchQuery,
                                departmentFilter: 'unisex',
                              ),
                              const SizedBox(height: 16),
                              _ProductSection(
                                title: s.homeSportsWear,
                                products: _products,
                                searchQuery: _searchQuery,
                                departmentFilter: 'sports',
                              ),
                            ],

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_showSuccessOverlay)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF1BC47D),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.homeSuccessTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.homeSuccessBody,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _hideSuccessOverlay,
                        child: Text(
                          s.homeSuccessOk,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BottomItem(
                  icon: Icons.home_filled,
                  label: 'Home',
                  isActive: true,
                  onTap: () {},
                ),
                _BottomItem(
                  icon: Icons.search,
                  label: 'Search',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  },
                ),
                _BottomItem(
                  icon: Icons.favorite_border,
                  label: 'Wishlist',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WishlistScreen(),
                      ),
                    );
                  },
                ),
                _BottomItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyCartScreen(),
                      ),
                    );
                  },
                ),
                _BottomItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileMenuScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  const _TopBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 380 / 108,
        child: Image.asset(
          'lib/assets/Group 3.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _BrandChip(label: 'Zara'),
          _BrandChip(label: 'Nike'),
          _BrandChip(label: 'Adidas'),
          _BrandChip(label: 'Gucci'),
        ],
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  final String label;

  const _BrandChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  final String title;
  final List<dynamic> products;
  final String searchQuery;
  final String? departmentFilter;

  const _ProductSection({
    required this.title,
    required this.products,
    required this.searchQuery,
    this.departmentFilter,
  });

  String _readString(dynamic product, String key) {
    if (product is Map && product[key] != null) {
      return product[key].toString();
    }
    return '';
  }

  int _extractProductId(dynamic product) {
    if (product is! Map) return 0;

    final id = product['id'] ??
        product['productId'] ??
        product['productID'] ??
        product['product_id'];

    if (id == null) return 0;
    if (id is int) return id;

    return int.tryParse(id.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    final filtered = products.where((product) {
      final name = _readString(product, 'name').toLowerCase();
      final brand = _readString(product, 'brandName').toLowerCase();
      final department = _readString(product, 'departmentName').toLowerCase();
      final category = _readString(product, 'categoryName').toLowerCase();

      if (departmentFilter != null && departmentFilter!.isNotEmpty) {
        final f = departmentFilter!.toLowerCase();

        final matchedDepartment =
            department.contains(f) || category.contains(f);

        if (!matchedDepartment) return false;
      }

      if (searchQuery.trim().isEmpty) return true;

      final q = searchQuery.toLowerCase();

      return name.contains(q) ||
          brand.contains(q) ||
          department.contains(q) ||
          category.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    s.homeNoResults,
                    style: const TextStyle(fontSize: 13),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = filtered[index];

                    final name = _readString(product, 'name').isEmpty
                        ? s.homeProductName
                        : _readString(product, 'name');

                    final brand = _readString(product, 'brandName').isEmpty
                        ? s.homeBrand
                        : _readString(product, 'brandName');

                    return _ProductCard(
                      name: name,
                      brand: brand,
                      price: _extractPrice(product),
                      imageUrl: _extractImageUrl(product),
                      onTap: () {
                        final productId = _extractProductId(product);

                        if (productId == 0) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(
                              productId: productId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _extractPrice(dynamic product) {
    if (product is! Map) return '\$000';

    final directPrice = product['price'];
    if (directPrice != null) return '\$$directPrice';

    final variants = product['variants'];
    if (variants is List && variants.isNotEmpty) {
      final firstVariant = variants.first;
      if (firstVariant is Map && firstVariant['price'] != null) {
        return '\$${firstVariant['price']}';
      }
    }

    return '\$000';
  }

  String? _extractImageUrl(dynamic product) {
    if (product is! Map) return null;

    final imageUrl = product['imageUrl'] ??
        product['mainImage'] ??
        product['thumbnail'] ??
        product['photo'];

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return imageUrl.toString();
    }

    final images = product['images'];
    if (images is List && images.isNotEmpty) {
      final firstImage = images.first;

      if (firstImage is String) {
        return firstImage;
      }

      if (firstImage is Map) {
        final url = firstImage['url'] ??
            firstImage['imageUrl'] ??
            firstImage['imagePath'];

        if (url != null && url.toString().isNotEmpty) {
          return url.toString();
        }
      }
    }

    return null;
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String brand;
  final String price;
  final String? imageUrl;
  final VoidCallback onTap;

  const _ProductCard({
    required this.name,
    required this.brand,
    required this.price,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Container(
                height: 140,
                width: double.infinity,
                color: Colors.grey[300],
                child: imageUrl == null
                    ? const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                        ),
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                brand,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.black : Colors.grey;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}