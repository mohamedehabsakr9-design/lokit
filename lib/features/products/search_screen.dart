import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import '../../core/models/product_search_model.dart';
import '../../core/services/search_service.dart';
import '../home/home_screen.dart';
import '../profile/profile_menu_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();

  // Search
  String _query = '';
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  List<ProductSearchModel> _results = [];
  DateTime? _lastTyped;

  // Filters
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
        return;
      }
    });

    if (_query.trim().length < 2) return;

    final typed = DateTime.now();
    _lastTyped = typed;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_lastTyped == typed && mounted) _performSearch();
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
        keyword:    _query.trim(),
        brandId:    _selectedBrandId,
        categoryId: _selectedCategoryId,
        colorId:    _selectedColorId,
        sizeId:     _selectedSizeId,
        minPrice:   _minPrice,
        maxPrice:   _maxPrice,
      );

      if (!mounted) return;
      setState(() {
        _results     = results;
        _hasSearched = true;
        _isLoading   = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading    = false;
        _hasSearched  = true;
        _errorMessage = e.response?.data?['message'] as String?
            ?? 'Connection error. Please try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading    = false;
        _hasSearched  = true;
        _errorMessage = 'Something went wrong.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s       = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.3,
          centerTitle: true,
          title: Text(
            s.searchTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            _SearchBarWidget(onQueryChanged: _onQueryChanged),
            const SizedBox(height: 16),
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: _results.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4.6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) =>
                  _ProductCard(product: _results[index]),
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
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (r) => false,
              ),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              ),
            ),
            _NavItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Cart',
              onTap: () {},
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileMenuScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;
  const _SearchBarWidget({required this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: onQueryChanged,
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

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductSearchModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(productId: product.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── صورة ──────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
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
                          )
                        : _placeholder(),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 18),
                  ),
                ),
              ],
            ),
            // ── اسم ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // ── براند · كاتيجوري ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                '${product.brandName} · ${product.categoryName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
            // ── سعر ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                'From \$${product.minPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String title;
  final bool isError;
  const _EmptyState({required this.title, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

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