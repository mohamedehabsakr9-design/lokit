import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // هنا ممكن تستبدلها بقائمة ديناميكية من API
    final dummyOrders = List.generate(4, (index) {
      final isPending = index.isEven;
      return OrderListItemData(
        id: '#ORD-580$index',
        amountText: '3000 EGP',
        statusText: isPending ? s.orderStatusPending : s.orderStatusCompleted,
        isPending: isPending,
        dateTimeText: '5 / 5 / 2025 3:45 Pm',
      );
    });

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTabController(
        length: 2,
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
              s.myOrdersTitle, // "My Orders"
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.deepOrange,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    tabs: [
                      Tab(text: s.myOrdersPendingTab), // "Pending"
                      Tab(text: s.myOrdersCompletedTab), // "Completed"
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _OrdersList(
                orders:
                    dummyOrders.where((o) => o.isPending).toList(growable: false),
              ),
              _OrdersList(
                orders: dummyOrders
                    .where((o) => !o.isPending)
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderListItemData {
  final String id;
  final String amountText;
  final String statusText;
  final bool isPending;
  final String dateTimeText;

  OrderListItemData({
    required this.id,
    required this.amountText,
    required this.statusText,
    required this.isPending,
    required this.dateTimeText,
  });
}

class _OrdersList extends StatelessWidget {
  final List<OrderListItemData> orders;

  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    if (orders.isEmpty) {
      return Center(
        child: Text(
          s.myOrdersEmptyText,
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsScreen(
                  orderId: order.id,
                  isCompleted: !order.isPending,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
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
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.myOrdersOrderLabel} ${order.id}', // "Order #ORD-5801"
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${s.myOrdersDateTimeLabel} : ${order.dateTimeText}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: order.isPending
                                ? Colors.deepOrange
                                : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.statusText,
                            style: TextStyle(
                              fontSize: 11,
                              color: order.isPending
                                  ? Colors.deepOrange
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.amountText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.myOrdersDetailsButton, // "Details"
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
