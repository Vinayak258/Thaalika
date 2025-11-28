import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../models/mess_model.dart';
import '../../services/user_service.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final MessModel mess;
  
  const OrderConfirmationScreen({super.key, required this.mess});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _useCoupon = false;
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userModel;

    if (user == null || cartProvider.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Confirmation')),
        body: const Center(child: Text('No items in cart')),
      );
    }

    // Get available coupons for this mess
    final availableCoupons = user.coupons[widget.mess.messId] ?? 0;
    final totalAmount = cartProvider.totalAmount;
    
    // Calculate payment breakdown
    double couponAmount = 0;
    double walletAmount = 0;
    double upiAmount = 0;
    double remainingAmount = totalAmount;

    if (_useCoupon && availableCoupons > 0) {
      // Each coupon is worth the mess's coupon value
      couponAmount = widget.mess.couponValue;
      remainingAmount = totalAmount - couponAmount;
      if (remainingAmount < 0) remainingAmount = 0;
    }

    // Deduct from wallet
    if (remainingAmount > 0) {
      if (user.wallet >= remainingAmount) {
        walletAmount = remainingAmount;
        remainingAmount = 0;
      } else {
        walletAmount = user.wallet;
        remainingAmount -= user.wallet;
      }
    }

    // Rest goes to UPI
    upiAmount = remainingAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mess Info
            Card(
              child: ListTile(
                leading: Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
                title: Text(widget.mess.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.mess.address),
              ),
            ),
            const SizedBox(height: 16),

            // Order Items
            Text('Order Items', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...cartProvider.items.map((item) => Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('Qty: ${item.quantity}'),
                trailing: Text('₹${(item.price * item.quantity).toStringAsFixed(0)}'),
              ),
            )),
            const Divider(height: 32),

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // Use Coupon Checkbox
            if (availableCoupons > 0)
              Card(
                color: Colors.green[50],
                child: CheckboxListTile(
                  title: const Text('Use Coupon'),
                  subtitle: Text('Available: $availableCoupons | Value: ₹${widget.mess.couponValue}'),
                  value: _useCoupon,
                  onChanged: (value) {
                    setState(() => _useCoupon = value ?? false);
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Payment Breakdown
            Text('Payment Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_useCoupon && couponAmount > 0)
                      _PaymentRow(
                        label: 'Coupon Discount',
                        amount: couponAmount,
                        color: Colors.green,
                      ),
                    if (walletAmount > 0)
                      _PaymentRow(
                        label: 'From Wallet',
                        amount: walletAmount,
                        color: Colors.blue,
                      ),
                    if (upiAmount > 0)
                      _PaymentRow(
                        label: 'UPI Payment Required',
                        amount: upiAmount,
                        color: Colors.orange,
                      ),
                    if (upiAmount == 0 && (_useCoupon || walletAmount > 0))
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Fully paid with coupon & wallet', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Wallet Balance Info
            Card(
              color: Colors.blue[50],
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Current Wallet Balance'),
                trailing: Text('₹${user.wallet.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : () => _placeOrder(
                  context,
                  totalAmount,
                  couponAmount,
                  walletAmount,
                  upiAmount,
                ),
                child: _isPlacingOrder
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        upiAmount > 0 ? 'Proceed to UPI Payment (₹${upiAmount.toStringAsFixed(0)})' : 'Place Order',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    double totalAmount,
    double couponAmount,
    double walletAmount,
    double upiAmount,
  ) async {
    setState(() => _isPlacingOrder = true);

    try {
      final cartProvider = context.read<CartProvider>();
      final userProvider = context.read<UserProvider>();
      final orderProvider = context.read<OrderProvider>();
      final userService = context.read<UserService>();
      
      final user = userProvider.userModel!;
      final couponsUsed = _useCoupon && couponAmount > 0 ? 1 : 0;

      // Create order
      final order = OrderModel(
        orderId: const Uuid().v4(),
        userId: user.uid,
        messId: widget.mess.messId,
        items: cartProvider.items,
        totalAmount: totalAmount,
        couponUsed: couponsUsed,
        extraPaid: walletAmount,
        couponAmount: couponAmount,
        walletAmount: walletAmount,
        upiAmount: upiAmount,
        paymentStatus: upiAmount > 0 ? 'pending' : 'completed',
        status: 'Placed',
        timestamp: DateTime.now(),
      );

      // Place order in Firestore
      await orderProvider.placeOrder(order, widget.mess, user.coupons);

      // Update user's coupons and wallet in Firestore
      final updatedCoupons = Map<String, int>.from(user.coupons);
      if (couponsUsed > 0) {
        final currentCount = updatedCoupons[widget.mess.messId] ?? 0;
        if (currentCount > 0) {
          updatedCoupons[widget.mess.messId] = currentCount - 1;
        }
      }

      final updatedWallet = user.wallet - walletAmount;

      final updatedUser = user.copyWith(
        coupons: updatedCoupons,
        wallet: updatedWallet,
      );

      await userService.updateUser(updatedUser);
      userProvider.updateUser(updatedUser);

      // Clear cart
      cartProvider.clearCart();

      if (mounted) {
        // Show success/pending dialog
        if (upiAmount > 0) {
          _showUPIDialog(upiAmount);
        } else {
          _showSuccessDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Order Placed!'),
          ],
        ),
        content: const Text('Your order has been successfully placed.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/student-dashboard');
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  void _showUPIDialog(double upiAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.orange, size: 32),
            SizedBox(width: 8),
            Text('UPI Payment Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount to pay: ₹${upiAmount.toStringAsFixed(0)}', 
                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Please complete the UPI payment to confirm your order.'),
            const SizedBox(height: 8),
            const Text('(UPI integration coming soon)', 
                 style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/student-dashboard');
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _PaymentRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color)),
          Text(
            '- ₹${amount.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
