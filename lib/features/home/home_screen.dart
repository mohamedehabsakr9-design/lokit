import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import '../../services/product_service.dart';
import '../cart/my_cart_screen.dart';
import '../products/product_details_screen.dart';
import '../products/search_screen.dart';
import '../profile/profile_menu_screen.dart';
import '../wishlist/wishlist_screen.dart';

const String kBaseUrl = 'https://lokit-production.up.railway.app';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  bool loading = true;
  bool showSuccessOverlay = false;
  String searchQuery = '';
  String? departmentFilter;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final result = await ProductService.getProducts();

      if (!mounted) return;

      setState(() {
        products = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  void hideSuccessOverlay() {
    setState(() {
      showSuccessOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: loadProducts,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            onSearchChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                          const SizedBox(height: 18),

                          const _TopBanner(),
                          const SizedBox(height: 18),

                          const _BrandRow(),
                          const SizedBox(height: 24),

                          _ProductSection(
                            title: s.homeNewArrivals,
                            products: products,
                            searchQuery: searchQuery,
                            departmentFilter: departmentFilter,
                          ),

                          const SizedBox(height: 24),

                          _ProductSection(
                            title: s.homeRecommended,
                            products: products,
                            searchQuery: searchQuery,
                            departmentFilter: departmentFilter,
                          ),
                        ],
                      ),
                    ),
            ),

            if (showSuccessOverlay)
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
                        onPressed: hideSuccessOverlay,
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
    );
  }
}

class _Header extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const _Header({
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'lib/assets/logo.png',
              height: 42,
              errorBuilder: (_, __, ___) {
                return const Text(
                  'LOKIT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                );
              },
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: s.homeSearchHint,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
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
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
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

  static String _readString(dynamic product, String key) {
    if (product is Map && product[key] != null) {
      return product[key].toString();
    }
    return '';
  }

  static int _extractProductId(dynamic product) {
    if (product is! Map) return 0;

    final id = product['id'] ??
        product['productId'] ??
        product['productID'] ??
        product['product_id'];

    if (id == null) return 0;
    if (id is int) return id;

    return int.tryParse(id.toString()) ?? 0;
  }

  static String _extractPrice(dynamic product) {
    if (product is! Map) return '0 EGP';

    final directPrice = product['price'];
    if (directPrice != null) return '$directPrice EGP';

    final variants = product['variants'];
    if (variants is List && variants.isNotEmpty) {
      final firstVariant = variants.first;
      if (firstVariant is Map && firstVariant['price'] != null) {
        return '${firstVariant['price']} EGP';
      }
    }

    return '0 EGP';
  }

  static String? _extractImageUrl(dynamic product) {
    if (product is! Map) return null;

    final imageUrl = product['imageUrl'] ??
        product['mainImageUrl'] ??
        product['mainImage'] ??
        product['thumbnail'] ??
        product['photo'];

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return _fullImageUrl(imageUrl.toString());
    }

    final images = product['images'] ?? product['productImages'];

    if (images is List && images.isNotEmpty) {
      final firstImage = images.first;

      if (firstImage is String) {
        return _fullImageUrl(firstImage);
      }

      if (firstImage is Map) {
        final url = firstImage['url'] ??
            firstImage['imageUrl'] ??
            firstImage['imagePath'] ??
            firstImage['path'];

        if (url != null && url.toString().isNotEmpty) {
          return _fullImageUrl(url.toString());
        }
      }
    }

    return null;
  }

  static String _fullImageUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('http')) {
      return url;
    }

    if (url.startsWith('/')) {
      return '$kBaseUrl$url';
    }

    return '$kBaseUrl/$url';
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
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 166,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: imageUrl == null || imageUrl!.isEmpty
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
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