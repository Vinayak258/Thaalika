import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../providers/order_provider.dart';
import '../../services/user_service.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const DeliveryDetailsScreen({super.key, required this.order});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final UserService _userService = UserService();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  Future<UserModel?> _getStudent(String uid) async {
    return await _userService.fetchUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Order #${widget.order.orderId.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.order.items.map((item) => Text('${item.quantity}x ${item.name}')),
            const SizedBox(height: 24),
            const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold)),
            
            FutureBuilder<UserModel?>(
              future: _getStudent(widget.order.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading details...');
                }
                final student = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student?.location ?? 'Location not set', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Customer: ${student?.name ?? 'Unknown'}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.call),
                          label: const Text('Call Customer'),
                          onPressed: student?.phone != null && student!.phone.isNotEmpty
                              ? () => _makePhoneCall(student.phone)
                              : null,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark Delivered'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          onPressed: () async {
                            await context.read<OrderProvider>().updateStatus(widget.order.orderId, 'Delivered');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order marked as delivered')),
                              );
                              context.pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
