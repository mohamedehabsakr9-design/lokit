import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import '../home/home_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../profile/profile_menu_screen.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  String _selectedDept = '';
  bool _showResults = false;
  bool _hasResults = true;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final products = List.generate(4, (index) {
      return {
        'name': '${s.productNameExample} $index',
        'brand': 'Zara',
        'price': '\$100',
      };
    });

    final filteredProducts = _showResults && _hasResults ? products : <Map>[];

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
            _SearchBarAndFilters(
              query: _query,
              onQueryChanged: (value) {
                setState(() {
                  _query = value;
                  if (_query.trim().isEmpty) {
                    _showResults = false;
                    _hasResults = true;
                  } else {
                    _showResults = true;
                    _hasResults = true;
                  }
                });
              },
              selectedDept: _selectedDept,
              onDeptChanged: (value) {
                setState(() {
                  _selectedDept = value;
                  _showResults = true;
                  _hasResults = true;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildBodyState(context, s, filteredProducts),
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
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                _BottomItem(
                  icon: Icons.search,
                  label: 'Search',
                  isActive: true,
                  onTap: () {},
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
                  onTap: () { /* اربطه لاحقاً بشاشة الكارت */ },
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

  Widget _buildBodyState(BuildContext context, AppStrings s, List<Map> products) {
    if (!_showResults) {
      return _EmptySearchState(
        title: s.searchExploreNow,
        isError: false,
      );
    }

    if (_showResults && products.isEmpty) {
      return _EmptySearchState(
        title: s.searchNoResults,
        isError: true,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.searchResultsTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4.6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = products[index];
                return _SearchResultCard(
                  name: item['name'] as String,
                  brand: item['brand'] as String,
                  price: item['price'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarAndFilters extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final String selectedDept;
  final ValueChanged<String> onDeptChanged;

  const _SearchBarAndFilters({
    required this.query,
    required this.onQueryChanged,
    required this.selectedDept,
    required this.onDeptChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: onQueryChanged,
                  decoration: InputDecoration(
                    hintText: s.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChipButton(
                          label: s.searchFilterDepartment,
                          isSelected: selectedDept.isNotEmpty,
                          onTap: () async {
                            final result = await _showDepartmentSheet(context);
                            if (result != null) {
                              onDeptChanged(result);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChipButton(
                          label: s.searchFilterCategory,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _FilterChipButton(
                          label: s.searchFilterBrand,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _FilterChipButton(
                          label: s.searchFilterColor,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _FilterChipButton(
                          label: s.searchFilterSize,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showDepartmentSheet(BuildContext context) async {
    final s = AppStrings.of(context);
    String temp = selectedDept.isEmpty ? s.searchMen : selectedDept;

    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final options = [
              s.searchMen,
              s.searchWomen,
              s.searchUnisex,
              s.searchKids,
              s.searchSportswear,
            ];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.searchSortBy,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...options.map((o) {
                    return RadioListTile<String>(
                      value: o,
                      groupValue: temp,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        setState(() => temp = val!);
                      },
                      title: Text(
                        o,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, temp);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(s.searchApply),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context, '');
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(s.searchClear),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? Colors.black : const Color(0xFFF2F2F2);
    final fg = isSelected ? Colors.white : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: fg,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: fg,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final String title;
  final bool isError;

  const _EmptySearchState({
    required this.title,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isError ? Colors.redAccent : Colors.black54;

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
              color: iconColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String name;
  final String brand;
  final String price;

  const _SearchResultCard({
    required this.name,
    required this.brand,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductDetailsScreen(),
          ),
        );
      },
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
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                brand,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                price,
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
