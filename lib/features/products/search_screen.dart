import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import '../../core/models/product_search_model.dart';
import '../../core/services/search_service.dart';
import '../cart/my_cart_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_menu_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'product_details_screen.dart';

const String kBaseUrl = 'https://lokit-production.up.railway.app';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();

  String _query = '';
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  List<ProductSearchModel> _results = [];
  DateTime? _lastTyped;

  int? _selectedBrandId;
  int? _selectedCategoryId;
  int? _selectedColorId;
  int? _selectedSizeId;
  double? _minPrice;
  double? _maxPrice;

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;

      if (_query.trim().isEmpty) {
        _hasSearched = false;
        _results = [];
        _errorMessage = null;
        _isLoading = false;
      }
    });

    if (_query.trim().length < 2) return;

    final typed = DateTime.now();
    _lastTyped = typed;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (_lastTyped == typed && mounted) {
        _performSearch();
      }
    });
  }

  Future<void> _performSearch() async {
    if (_query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _searchService.searchProducts(
        keyword: _query.trim(),
        brandId: _selectedBrandId,
        categoryId: _selectedCategoryId,
        colorId: _selectedColorId,
        sizeId: _selectedSizeId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );

      if (!mounted) return;

      setState(() {
        _results = results;
        _hasSearched = true;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasSearched = true;
        _errorMessage = e.response?.data is Map
            ? e.response?.data['message']?.toString()
            : 'Connection error. Please try again.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasSearched = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          centerTitle: true,
          title: Text(
            s.searchTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            _SearchBarWidget(
              onQueryChanged: _onQueryChanged,
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(s)),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBody(AppStrings s) {
    if (!_hasSearched && !_isLoading) {
      return _EmptyState(title: s.searchExploreNow, isError: false);
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (_errorMessage != null) {
      return _EmptyState(title: _errorMessage!, isError: true);
    }

    if (_results.isEmpty) {
      return _EmptyState(title: s.searchNoResults, isError: true);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${s.searchResultsTitle} (${_results.length})',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: _results.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                return _ProductCard(product: _results[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return SafeArea(
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
            _NavItem(
              icon: Icons.home_filled,
              label: 'Home',
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
            _NavItem(
              icon: Icons.search,
              label: 'Search',
              isActive: true,
              onTap: () {},
            ),
            _NavItem(
              icon: Icons.favorite_border,
              label: 'Wishlist',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              },
            ),
            _NavItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Cart',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyCartScreen()),
                );
              },
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileMenuScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSubmitted;

  const _SearchBarWidget({
    required this.onQueryChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: onQueryChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: s.searchHint,
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductSearchModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = _fullImageUrl(product.imageUrl);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: product.id),
          ),
        );
      },
      child: Container(
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: SizedBox(
                    height: 175,
                    width: double.infinity,
                    child: imageUrl == null
                        ? _placeholder()
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;

                              return Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black45,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _placeholder(),
                          ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 19),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brandName,
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
                        product.name,
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
                      '${product.minPrice.toStringAsFixed(2)} EGP',
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

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey),
      ),
    );
  }

  String? _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return '$kBaseUrl$url';
    return '$kBaseUrl/$url';
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final bool isError;

  const _EmptyState({
    required this.title,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 130),
        Center(
          child: Container(
            width: 130,
            height: 130,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 50,
              color: isError ? Colors.redAccent : Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
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
          Icon(icon, color: color, size: 22),
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