import 'package:flutter/material.dart';
import '../../app/app_strings.dart';

class ShippingAddressScreen extends StatelessWidget {
  const ShippingAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final addresses = <AddressItem>[
      AddressItem(
        title: 'Home',
        details: 'Cairo - Almaadi - Street 9 - Building 10',
        isDefault: true,
      ),
      AddressItem(
        title: 'Office',
        details: 'Giza - Dokki - Street 15 - Building 3',
        isDefault: false,
      ),
    ];

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
            s.shippingTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddShippingAddressScreen(),
              ),
            );
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = addresses[index];
            return _AddressCard(
              item: item,
              onTap: () {
                // TODO: اختيار العنوان والرجوع
                Navigator.pop(context, item);
              },
              onEditTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddShippingAddressScreen(initial: item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AddressItem {
  final String title;
  final String details;
  final bool isDefault;

  AddressItem({
    required this.title,
    required this.details,
    required this.isDefault,
  });
}

class _AddressCard extends StatelessWidget {
  final AddressItem item;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const _AddressCard({
    required this.item,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        item.isDefault ? Colors.black : (Colors.grey[300] ?? Colors.grey);
    final Color badgeColor =
        item.isDefault ? Colors.green : (Colors.grey[400] ?? Colors.grey);

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
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
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
              child: Icon(
                Icons.location_on_outlined,
                color: badgeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (item.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEditTap,
            ),
          ],
        ),
      ),
    );
  }
}

class AddShippingAddressScreen extends StatelessWidget {
  final AddressItem? initial;

  const AddShippingAddressScreen({super.key, this.initial});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final nameController = TextEditingController(text: initial?.title ?? '');
    final cityController = TextEditingController();
    final streetController = TextEditingController();
    final buildingController = TextEditingController();
    final postalController = TextEditingController();

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
            s.shippingNewAddress,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _AddressTextField(
                controller: nameController,
                hint: s.homeProductName,
                icon: Icons.label_outline,
              ),
              const SizedBox(height: 12),
              _AddressTextField(
                controller: cityController,
                hint: s.shippingCity,
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 12),
              _AddressTextField(
                controller: streetController,
                hint: s.shippingStreet,
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 12),
              _AddressTextField(
                controller: buildingController,
                hint: s.shippingBuilding,
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 12),
              _AddressTextField(
                controller: postalController,
                hint: s.shippingPostalCode,
                icon: Icons.local_post_office_outlined,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: حفظ العنوان في السيرفر
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    s.shippingSave,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _AddressTextField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
