import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import '../../services/wishlist_service.dart';
import '../products/product_details_screen.dart';

// الشاشات المرتبطة بالـ Bottom Bar
import '../home/home_screen.dart';
import '../products/search_screen.dart';
import '../cart/my_cart_screen.dart';
import '../profile/profile_menu_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await WishlistService.getWishlist();

      if (!mounted) return;

      setState(() {
        _wishlistItems = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(dynamic item) async {
    final productId = _readInt(item, 'productId');

    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product id not found'),
        ),
      );
      return;
    }

    try {
      await WishlistService.removeFromWishlist(productId);

      if (!mounted) return;

      setState(() {
        _wishlistItems.removeWhere(
          (element) => _readInt(element, 'productId') == productId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from wishlist'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove: $e'),
        ),
      );
    }
  }

  int? _readInt(dynamic item, String key) {
    if (item is Map && item[key] != null) {
      return int.tryParse(item[key].toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            s.wishlistTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadWishlist,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBody(s),
          ),
        ),

        // ===== Bottom Bar =====
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
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                _BottomItem(
                  icon: Icons.search,
                  label: 'Search',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  },
                ),
                _BottomItem(
                  icon: Icons.favorite,
                  label: 'Wishlist',
                  isActive: true,
                  onTap: () {},
                ),
                _BottomItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  onTap: () {
                    Navigator.pushReplacement(
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
                    Navigator.pushReplacement(
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

  Widget _buildBody(AppStrings s) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Failed to load wishlist',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: _loadWishlist,
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    if (_wishlistItems.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Icon(
            Icons.favorite_border,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 12),
          Center(
            child: Text(
              'Your wishlist is empty',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4.3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _wishlistItems.length,
      itemBuilder: (context, index) {
        final item = _wishlistItems[index];

        return _WishlistCard(
          s: s,
          item: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductDetailsScreen(),
              ),
            );
          },
          onFavoriteToggle: () {
            _removeFromWishlist(item);
          },
        );
      },
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final AppStrings s;
  final dynamic item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _WishlistCard({
    required this.s,
    required this.item,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  String _readString(String key) {
    if (item is Map && item[key] != null) {
      return item[key].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final productName = _readString('productName').isEmpty
        ? s.wishlistProductName
        : _readString('productName');

    final brandName = _readString('brandName').isEmpty
        ? s.wishlistBrand
        : _readString('brandName');

    final categoryName = _readString('categoryName');

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
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
            // الصورة + زر القلب
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: onFavoriteToggle,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                brandName,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                categoryName.isEmpty ? s.wishlistPriceExample : categoryName,
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
}

/// عنصر في الـ Bottom bar
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