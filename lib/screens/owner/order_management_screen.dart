import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/mess_provider.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    
    // Handle case where user has no messId
    if (user?.messId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Orders')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Please create your Mess Profile first',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You need to set up your mess profile before you can manage orders.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/create-mess-profile'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Mess Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: StreamBuilder(
        stream: context.read<OrderProvider>().getOwnerOrders(user!.messId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading orders: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger rebuild
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.orderId.substring(0, 8)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(DateFormat('hh:mm a').format(order.timestamp)),
                        ],
                      ),
                      const Divider(),
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('${item.quantity}x ${item.name}'),
                      )),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${order.status}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: order.status,
                            items: ['Placed', 'Cooking', 'Out for delivery', 'Delivered']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                context.read<OrderProvider>().updateStatus(order.orderId, val);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
