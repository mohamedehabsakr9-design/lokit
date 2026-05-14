import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import '../../services/shipping_service.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  List<AddressItem> addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final s = AppStrings.of(context);
    try {
      final data = await ShippingService.getAddresses();
      setState(() {
        addresses = data.map((e) => AddressItem(
          id: e['id'].toString(),
          title: e['title'],
          details: e['details'],
          isDefault: e['isDefault'] ?? false,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${s.failedToLoadProfile}: $e")),
      );
    }
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            s.shippingTitle, // صححت هنا
            style: const TextStyle(color: Colors.black),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = addresses[index];
                  return _AddressCard(
                    item: item,
                    isArabic: isArabic,
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
      ),
    );
  }
}

class AddressItem {
  final String id;
  final String title;
  final String details;
  final bool isDefault;

  AddressItem({
    required this.id,
    required this.title,
    required this.details,
    required this.isDefault,
  });
}

class _AddressCard extends StatelessWidget {
  final AddressItem item;
  final VoidCallback onTap;
  final bool isArabic;

  const _AddressCard({
    required this.item,
    required this.onTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = item.isDefault ? Colors.black : Colors.grey[300]!;
    final Color badgeColor = item.isDefault ? Colors.green : Colors.grey[400]!;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined, color: badgeColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      if (item.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isArabic ? "افتراضي" : "Default",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}