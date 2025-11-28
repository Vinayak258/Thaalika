import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/mess_provider.dart';
import '../../models/order_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.userModel;

    if (user == null || cart.items.isEmpty || cart.messId == null) return;

    setState(() => _isLoading = true);

    try {
      // Fetch mess details for coupon value and cutoff time
      final messProvider = context.read<MessProvider>();
      // We need to find the mess object. Assuming fetchMesses was called or we fetch specific mess.
      // For safety, let's try to find it in provider or fetch it.
      // Since fetchMesses() is called on dashboard, it might be there.
      // Better approach: Fetch specific mess to be sure.
      // But MessProvider doesn't have fetchMessById exposed easily without modifying it.
      // Let's assume it's in the list or we can get it from previous screen.
      // Actually, CartProvider only stores messId.
      // Let's iterate provider messes to find it.
      
      final mess = messProvider.messes.firstWhere(
        (m) => m.messId == cart.messId,
        orElse: () => throw Exception('Mess details not found. Please refresh.'),
      );

      double totalAmount = cart.totalAmount;
      int couponsToUse = 0;
      double walletDeduction = 0.0;
      
      // Calculate Coupons
      // Logic: 1 coupon = mess.couponValue
      final availableCoupons = user.coupons[cart.messId] ?? 0;
      final couponValue = mess.couponValue;
      
      // Calculate max coupons we can use based on total amount
      // e.g. Total 100, Coupon 50 -> 2 coupons
      // e.g. Total 80, Coupon 50 -> 1 coupon + 30 wallet
      
      int maxCouponsNeeded = (totalAmount / couponValue).ceil();
      
      if (availableCoupons >= maxCouponsNeeded) {
        // We have enough coupons to cover fully or mostly
        // Wait, if Total 80, Coupon 50.
        // 1 coupon = 50. Remaining 30.
        // 2 coupons = 100. (Waste 20? Or not allowed?)
        // Prompt: "If coupon value < price → wallet pays remaining amount"
        // This implies we use coupons up to the price, but don't overpay?
        // Or "1 coupon per meal".
        // Let's stick to: Use coupons for full value coverage if possible, else split.
        // Actually, usually 1 coupon is for 1 thali.
        // Let's assume: Use as many coupons as possible such that coupon_value * count <= total_amount.
        // Remaining paid by wallet.
        
        int couponsCanUse = (totalAmount / couponValue).floor();
        
        // Use min(available, can_use)
        couponsToUse = availableCoupons < couponsCanUse ? availableCoupons : couponsCanUse;
        
        double couponCoveredAmount = couponsToUse * couponValue;
        walletDeduction = totalAmount - couponCoveredAmount;
        
      } else {
        // Use all available coupons
        couponsToUse = availableCoupons;
        double couponCoveredAmount = couponsToUse * couponValue;
        walletDeduction = totalAmount - couponCoveredAmount;
      }

      if (user.wallet < walletDeduction) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient wallet balance for remaining amount!')),
        );
        return;
      }

      final order = OrderModel(
        orderId: const Uuid().v4(),
        userId: user.uid,
        messId: cart.messId!,
        items: cart.items,
        totalAmount: totalAmount,
        couponUsed: couponsToUse,
        extraPaid: walletDeduction,
        status: 'Placed',
        timestamp: DateTime.now(),
      );

      // Pass mess and user coupons for validation in provider
      await context.read<OrderProvider>().placeOrder(order, mess, user.coupons);
      
      // Deduct wallet and coupons (mess-specific)
      await context.read<WalletProvider>().deduct(
        user.uid, 
        walletDeduction, 
        couponsToUse, 
        messId: cart.messId
      );
      
      // Refresh user data
      await userProvider.fetchUser(user.uid);
      
      cart.clearCart();
      
      if (mounted) {
        context.go('/order-tracking');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('₹${item.price} x ${item.quantity}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => cart.removeFromCart(item.menuItemId),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${cart.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _placeOrder,
                              child: const Text('Place Order'),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
