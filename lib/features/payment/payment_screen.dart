import 'package:flutter/material.dart';
import '../../app/app_strings.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

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
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            s.paymentTitle, // "Payment"
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // مؤشر الخطوتين 1 / 2
              Row(
                children: [
                  _StepCircle(isActive: true),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                  _StepCircle(isActive: true),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                s.paymentOrderSummary, // "Order Summary"
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              // عناصر الطلب
              _SummaryItemCard(),
              const SizedBox(height: 10),
              _SummaryItemCard(),
              const SizedBox(height: 12),
              // إجماليات
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    _TotalRow(label: 'Sub total (2)', value: '3000 EGP'),
                    SizedBox(height: 4),
                    _TotalRow(label: 'Shipment total', value: '0.00 EGP'),
                    Divider(height: 20),
                    _TotalRow(label: 'Total', value: '3000 EGP'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Delivery Information
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.paymentDeliveryInfoTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit_outlined, size: 18),
                ],
              ),
              const SizedBox(height: 10),
              _TextField(hint: s.paymentFullNameHint),
              const SizedBox(height: 8),
              _TextField(hint: s.paymentPhoneHint),
              const SizedBox(height: 8),
              _TextField(hint: s.paymentAddressHint),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _TextField(hint: s.paymentCityHint)),
                  const SizedBox(width: 8),
                  Expanded(child: _TextField(hint: s.paymentPostalHint)),
                ],
              ),
              const SizedBox(height: 20),
              // Payment Method
              Text(
                s.paymentMethodTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'cod',
                      groupValue: 'cod',
                      onChanged: (_) {},
                      title: Text(s.paymentCashOnDelivery),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'card',
                      groupValue: 'cod',
                      onChanged: (_) {},
                      title: Text(s.paymentCreditCard),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                s.paymentCardDetailsTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _TextField(hint: s.paymentCardNumberHint),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _TextField(hint: s.paymentExpHint)),
                  const SizedBox(width: 8),
                  Expanded(child: _TextField(hint: s.paymentCvvHint)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final confirmed = await showOrderConfirmedDialog(context, s);
                    if (confirmed == true) {
                      // Track Order
                      Navigator.pushNamed(context, '/orders');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    s.paymentConfirmButton, // "Confirm Order"
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
  @override
  Widget build(BuildContext context) {
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
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Roller Rabbit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Nike',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'White / White',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Text(
              '1000 EGP',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;

  const _TotalRow({required this.label, required this.value});

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

  const _TextField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
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

/// Dialog "Order Confirmed!"
Future<bool?> showOrderConfirmedDialog(
    BuildContext context, AppStrings s) {
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
                s.orderConfirmTitle, // "Order Confirmed!"
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.orderConfirmBody, // "Your Order has been placed successfully\nOrder #ORD-5804"
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
                    s.orderConfirmTrackButton, // "Track Order"
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
                    s.orderConfirmContinueButton, // "Continue Shopping"
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
