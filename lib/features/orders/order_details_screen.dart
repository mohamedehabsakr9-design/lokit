import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import '../rating/rate_experience_dialog.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final bool isCompleted;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.isCompleted,
  });

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
            s.orderDetailsTitle,
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
              // العنوان والشكر
              Text(
                s.orderDetailsThankYouTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.orderDetailsThankYouBody,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // خط الفاصل
              const Divider(),
              const SizedBox(height: 8),

              // قسم بيانات الطلب
              Text(
                s.orderDetailsSectionTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: s.orderDetailsStatusLabel,
                value: isCompleted
                    ? s.orderStatusCompleted
                    : s.orderStatusPending,
                valueColor: isCompleted ? Colors.green : Colors.deepOrange,
                icon: isCompleted ? Icons.check_circle : Icons.schedule,
              ),
              _DetailRow(
                label: s.orderDetailsNumberLabel,
                value: orderId,
                icon: Icons.receipt_long_outlined,
              ),
              _DetailRow(
                label: s.orderDetailsDateLabel,
                value: '5 / 5 / 2025',
                icon: Icons.calendar_today,
              ),
              _DetailRow(
                label: s.orderDetailsPaymentMethodLabel,
                value: s.paymentCashOnDelivery,
                icon: Icons.payment,
              ),
              _DetailRow(
                label: s.orderDetailsPhoneLabel,
                value: '010336658997',
                icon: Icons.phone,
              ),
              _DetailRow(
                label: s.orderDetailsAddressLabel,
                value: 'Cairo - Almaadi - Street 9',
                icon: Icons.location_on_outlined,
                isMultiline: true,
              ),

              // خط الفاصل الثاني
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // قسم حالة الطلب (Timeline)
              Text(
                s.orderDetailsStatusSectionTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Timeline - تم التأكيد
              _TimelineItem(
                dateText: isArabic
                    ? '16 نوفمبر\n11:00 مساءً'
                    : 'November 16\n11:00 pm',
                title: s.timelineConfirmedTitle,
                subtitle: s.timelineConfirmedBody,
                isActive: true,
                icon: Icons.check_circle_outline,
                iconColor: Colors.green,
              ),

              // Timeline - تم الشحن
              _TimelineItem(
                dateText: isArabic
                    ? '18 نوفمبر\n2:00 مساءً'
                    : 'November 18\n2:00 pm',
                title: s.timelineShippedTitle,
                subtitle: s.timelineShippedBody,
                isActive: isCompleted,
                icon: Icons.local_shipping_outlined,
                iconColor: isCompleted ? Colors.green : Colors.grey,
              ),

              // Timeline - تم التوصيل
              _TimelineItem(
                dateText: isArabic
                    ? '19 نوفمبر\n4:00 مساءً'
                    : 'November 19\n4:00 pm',
                title: s.timelineDeliveredTitle,
                subtitle: s.timelineDeliveredBody,
                isActive: isCompleted,
                isLast: true,
                icon: Icons.delivery_dining_outlined,
                iconColor: isCompleted ? Colors.green : Colors.grey,
              ),

              const SizedBox(height: 16),

              // خط الفاصل الثالث
              const Divider(),
              const SizedBox(height: 8),

              // قسم التقييم أو الإلغاء حسب حالة الطلب
              if (isCompleted) ...[
                _RateOrderSection(s: s),
                const SizedBox(height: 16),
              ] else ...[
                _CancelOrderSection(s: s),
                const SizedBox(height: 16),
              ],

              // شكر إضافي في النهاية للطلبات المكتملة
              if (isCompleted) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  s.orderDetailsThankYouTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.orderDetailsThankYouBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// سطر بيانات بسيط مع أيقونة
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;
  final Color? valueColor;
  final IconData? icon;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isMultiline = false,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 4,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              alignment:
                  isMultiline ? Alignment.topRight : Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor ?? Colors.black54,
                ),
                textAlign: TextAlign.end,
                maxLines: isMultiline ? 2 : 1,
                overflow: isMultiline ? TextOverflow.ellipsis : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر واحد في Timeline
class _TimelineItem extends StatelessWidget {
  final String dateText;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isLast;
  final IconData icon;
  final Color iconColor;

  const _TimelineItem({
    required this.dateText,
    required this.title,
    required this.subtitle,
    required this.isActive,
    this.isLast = false,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // التاريخ والوقت
          SizedBox(
            width: 90,
            child: Text(
              dateText,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // الخط العمودي + الدائرة
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? iconColor : Colors.grey[300],
                  border: Border.all(
                    color: isActive ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 10,
                  color: isActive ? Colors.white : Colors.grey,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),

          // المحتوى
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isActive ? Colors.green.withOpacity(0.05) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isActive ? Colors.green[700] : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'مكتمل',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.green[700] : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// قسم التقييم للطلبات المكتملة
class _RateOrderSection extends StatelessWidget {
  final AppStrings s;

  const _RateOrderSection({required this.s});

  @override
  Widget build(BuildContext context) {
    final isArabic = s.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              s.orderRateSectionTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            s.orderRateSectionBody,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.black, Colors.black87],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextButton(
            onPressed: () async {
              final result = await showRateExperienceDialog(context, s);
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic
                          ? 'تم إرسال تقييمك بنجاح!'
                          : 'Your rating has been submitted successfully!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  s.orderRateButton,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// قسم الإلغاء للطلبات المعلقة
class _CancelOrderSection extends StatelessWidget {
  final AppStrings s;

  const _CancelOrderSection({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.orderCancelSectionTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.orderCancelSectionBody,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextButton(
            onPressed: () {
              _showCancelConfirmationDialog(context, s);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cancel_outlined,
                  color: Colors.deepOrange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  s.orderCancelButton,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, AppStrings s) {
    final isArabic = s.isArabic;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber,
              color: Colors.deepOrange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              s.orderCancelDialogTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          s.orderCancelDialogBody,
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              s.orderCancelDialogNo,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: استدعاء API إلغاء الطلب
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'تم إلغاء الطلب بنجاح'
                        : 'Order cancelled successfully',
                  ),
                  backgroundColor: Colors.deepOrange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              s.orderCancelDialogYes,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
