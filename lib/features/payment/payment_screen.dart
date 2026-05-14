import 'package:flutter/material.dart';

import '../../app/app_strings.dart';
import '../../services/api_service.dart';
import '../orders/my_orders_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = true;
  bool _isConfirming = false;

  List<dynamic> cartItems = [];
  String paymentMethod = 'CASH_ON_DELIVERY';

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final postalController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expController = TextEditingController();
  final cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    postalController.dispose();
    cardNumberController.dispose();
    expController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  Future<void> _loadCheckoutData() async {
    try {
      final cartData = await ApiService.get('/cart', withAuth: true);

      if (!mounted) return;

      setState(() {
        cartItems = _extractCartItems(cartData);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  List<dynamic> _extractCartItems(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'];
    if (data is Map && data['cartItems'] is List) return data['cartItems'];
    if (data is Map && data['content'] is List) return data['content'];
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  double get subTotal {
    double total = 0;

    for (final item in cartItems) {
      final price = _toDouble(
        _read(item, 'price') ??
            _read(item, 'unitPrice') ??
            _read(item, 'productPrice') ??
            _readProduct(item, 'price'),
      );

      final quantity = _toInt(
        _read(item, 'quantity') ?? _read(item, 'qty') ?? 1,
      );

      total += price * quantity;
    }

    return total;
  }

  double get shipmentTotal => 0;
  double get total => subTotal + shipmentTotal;

  Future<void> _confirmOrder(AppStrings s) async {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();
    final postal = postalController.text.trim();

    if (cartItems.isEmpty) {
      _showMessage('Cart is empty', isError: true);
      return;
    }

    if (fullName.isEmpty || phone.isEmpty || address.isEmpty || city.isEmpty) {
      _showMessage('Please fill delivery information', isError: true);
      return;
    }

    if (paymentMethod == 'CARD') {
      if (cardNumberController.text.trim().isEmpty ||
          expController.text.trim().isEmpty ||
          cvvController.text.trim().isEmpty) {
        _showMessage('Please fill card details', isError: true);
        return;
      }
    }

    setState(() => _isConfirming = true);

    final body = {
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'postalCode': postal,
      'paymentMethod': paymentMethod,
      'items': cartItems.map((item) {
        return {
          'productVariantId': _extractVariantId(item),
          'quantity': _toInt(_read(item, 'quantity') ?? _read(item, 'qty') ?? 1),
        };
      }).toList(),
    };

    try {
      dynamic response;

      try {
        response = await ApiService.post(
          '/checkout',
          body: body,
          withAuth: true,
        );
      } catch (_) {
        response = await ApiService.post(
          '/orders',
          body: body,
          withAuth: true,
        );
      }

      if (!mounted) return;

      final orderId = _extractOrderId(response);

      final confirmed = await showOrderConfirmedDialog(
        context,
        s,
        orderId: orderId,
      );

      if (!mounted) return;

      if (confirmed == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  String _extractOrderId(dynamic response) {
    if (response is Map) {
      final data = response['data'];

      final id = response['id'] ??
          response['orderId'] ??
          response['orderNumber'] ??
          (data is Map ? data['id'] : null) ??
          (data is Map ? data['orderId'] : null) ??
          (data is Map ? data['orderNumber'] : null);

      if (id != null) {
        final value = id.toString();
        return value.startsWith('#') ? value : '#$value';
      }
    }

    return '#ORDER';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _isConfirming ? null : () => Navigator.pop(context),
          ),
          title: Text(
            s.paymentTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadCheckoutData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _StepCircle(isActive: true),
                          Expanded(
                            child: Container(height: 2, color: Colors.grey[300]),
                          ),
                          const _StepCircle(isActive: true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.paymentOrderSummary,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (cartItems.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Text('Cart is empty')),
                        )
                      else
                        ...cartItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SummaryItemCard(item: item),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _TotalRow(
                              label: 'Sub total (${cartItems.length})',
                              value: '${subTotal.toStringAsFixed(2)} EGP',
                            ),
                            const SizedBox(height: 4),
                            _TotalRow(
                              label: 'Shipment total',
                              value: '${shipmentTotal.toStringAsFixed(2)} EGP',
                            ),
                            const Divider(height: 20),
                            _TotalRow(
                              label: 'Total',
                              value: '${total.toStringAsFixed(2)} EGP',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        s.paymentDeliveryInfoTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TextField(
                        hint: s.paymentFullNameHint,
                        controller: fullNameController,
                        enabled: !_isConfirming,
                      ),
                      const SizedBox(height: 10),
                      _TextField(
                        hint: s.paymentPhoneHint,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_isConfirming,
                      ),
                      const SizedBox(height: 10),
                      _TextField(
                        hint: s.paymentAddressHint,
                        controller: addressController,
                        enabled: !_isConfirming,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _TextField(
                              hint: s.paymentCityHint,
                              controller: cityController,
                              enabled: !_isConfirming,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TextField(
                              hint: s.paymentPostalHint,
                              controller: postalController,
                              keyboardType: TextInputType.number,
                              enabled: !_isConfirming,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        s.paymentMethodTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PaymentOption(
                        title: s.paymentCashOnDelivery,
                        value: 'CASH_ON_DELIVERY',
                        groupValue: paymentMethod,
                        onChanged: _isConfirming
                            ? null
                            : (value) {
                                setState(() => paymentMethod = value);
                              },
                      ),
                      _PaymentOption(
                        title: s.paymentCreditCard,
                        value: 'CARD',
                        groupValue: paymentMethod,
                        onChanged: _isConfirming
                            ? null
                            : (value) {
                                setState(() => paymentMethod = value);
                              },
                      ),
                      if (paymentMethod == 'CARD') ...[
                        const SizedBox(height: 12),
                        Text(
                          s.paymentCardDetailsTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          hint: s.paymentCardNumberHint,
                          controller: cardNumberController,
                          keyboardType: TextInputType.number,
                          enabled: !_isConfirming,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _TextField(
                                hint: s.paymentExpHint,
                                controller: expController,
                                enabled: !_isConfirming,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TextField(
                                hint: s.paymentCvvHint,
                                controller: cvvController,
                                keyboardType: TextInputType.number,
                                enabled: !_isConfirming,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              _isConfirming ? null : () => _confirmOrder(s),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            disabledBackgroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: _isConfirming
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  s.paymentConfirmButton,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String>? onChanged;

  const _PaymentOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged == null ? null : (v) => onChanged!(v!),
      title: Text(title),
      activeColor: Colors.black,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool isActive;

  const _StepCircle({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: isActive ? Colors.black : Colors.white,
      child: Icon(
        isActive ? Icons.check : Icons.circle_outlined,
        color: isActive ? Colors.white : Colors.black54,
        size: 16,
      ),
    );
  }
}

class _SummaryItemCard extends StatelessWidget {
  final dynamic item;

  const _SummaryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = _text(
      _read(item, 'productName') ?? _readProduct(item, 'name'),
      fallback: 'Product',
    );

    final brand = _text(
      _read(item, 'brandName') ?? _readProduct(item, 'brandName'),
    );

    final price = _toDouble(
      _read(item, 'price') ??
          _read(item, 'unitPrice') ??
          _read(item, 'productPrice') ??
          _readProduct(item, 'price'),
    );

    final quantity = _toInt(_read(item, 'quantity') ?? _read(item, 'qty') ?? 1);
    final imageUrl = _imageUrl(item);

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(18),
            ),
            child: SizedBox(
              width: 90,
              height: 90,
              child: imageUrl.isEmpty
                  ? _imagePlaceholder()
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Qty: $quantity',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '${(price * quantity).toStringAsFixed(2)} EGP',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;

  const _TotalRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isTotal = label == 'Total';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;

  const _TextField({
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? const Color(0xFFF5F5F5) : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

Future<bool?> showOrderConfirmedDialog(
  BuildContext context,
  AppStrings s, {
  required String orderId,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFF1BC47D),
                child: Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                s.orderConfirmTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${s.orderConfirmBody}\n$orderId',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    s.orderConfirmTrackButton,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    s.orderConfirmContinueButton,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

dynamic _read(dynamic item, String key) {
  if (item is Map) return item[key];
  return null;
}

dynamic _readProduct(dynamic item, String key) {
  if (item is Map && item['product'] is Map) {
    return item['product'][key];
  }
  return null;
}

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString() ?? '';
  return text.trim().isEmpty ? fallback : text;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 1;
}

int _extractVariantId(dynamic item) {
  final id = _read(item, 'productVariantId') ??
      _read(item, 'variantId') ??
      _read(item, 'variant_id') ??
      _readProduct(item, 'variantId') ??
      _readProduct(item, 'productVariantId') ??
      _read(item, 'id');

  if (id is int) return id;
  return int.tryParse(id?.toString() ?? '') ?? 0;
}

String _imageUrl(dynamic item) {
  final raw = _read(item, 'imageUrl') ??
      _read(item, 'productImage') ??
      _read(item, 'image') ??
      _readProduct(item, 'imageUrl') ??
      _readProduct(item, 'mainImageUrl') ??
      _readProduct(item, 'productImage') ??
      _readProduct(item, 'image') ??
      '';

  final url = raw.toString();

  if (url.isEmpty) return '';
  if (url.startsWith('http')) return url;
  if (url.startsWith('/')) {
    return 'https://lokit-production.up.railway.app$url';
  }
  return 'https://lokit-production.up.railway.app/$url';
}