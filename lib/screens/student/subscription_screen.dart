import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/mess_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  final MessModel mess;
  const SubscriptionScreen({super.key, required this.mess});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscribe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mess.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a Plan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  // Default Plan (Legacy support)
                  if (widget.mess.plans.isEmpty)
                    _PlanCard(
                      name: 'Standard Monthly',
                      price: widget.mess.subscriptionPrice,
                      coupons: 30,
                      onTap: () => _confirmPurchase('Standard Monthly', widget.mess.subscriptionPrice, 30),
                    ),
                  
                  // Dynamic Plans
                  ...widget.mess.plans.map((plan) {
                    return _PlanCard(
                      name: plan['name'] ?? 'Plan',
                      price: (plan['price'] ?? 0).toDouble(),
                      coupons: plan['coupons'] ?? 0,
                      onTap: () => _confirmPurchase(
                        plan['name'] ?? 'Plan',
                        (plan['price'] ?? 0).toDouble(),
                        plan['coupons'] ?? 0,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPurchase(String planName, double price, int coupons) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Subscription'),
        content: Text('Subscribe to $planName for ₹$price?\nYou will get $coupons coupons.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _subscribe(price, coupons);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe(double price, int coupons) async {
    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) return;

      if (user.wallet < price) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient wallet balance!')),
          );
        }
        return;
      }

      await context.read<WalletProvider>().purchaseSubscription(
        user.uid,
        widget.mess.messId,
        price,
        coupons,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription successful! $coupons coupons added.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final double price;
  final int coupons;
  final VoidCallback onTap;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.coupons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('$coupons Meals', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
