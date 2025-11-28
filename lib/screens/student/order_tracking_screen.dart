import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder(
        stream: context.read<OrderProvider>().getOrders(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active orders'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.orderId.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateFormat('MMM dd, hh:mm a').format(order.timestamp)),
                        ],
                      ),
                      const Divider(),
                      ...order.items.map((item) => Text('${item.quantity}x ${item.name}')),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total: ₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text(order.status),
                            backgroundColor: _getStatusColor(order.status),
                            labelStyle: const TextStyle(color: Colors.white),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Placed': return Colors.blue;
      case 'Cooking': return Colors.orange;
      case 'Out for delivery': return Colors.purple;
      case 'Delivered': return Colors.green;
      default: return Colors.grey;
    }
  }
}
