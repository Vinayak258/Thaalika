import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/mess_model.dart';
import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import 'subscription_screen.dart';

class MessDetailScreen extends StatelessWidget {
  final MessModel mess;
  const MessDetailScreen({super.key, required this.mess});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userModel;
    final hasSubscription = user != null && (user.coupons[mess.messId] ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(mess.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mess Logo
            if (mess.logoUrl != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(mess.logoUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mess Name & Type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mess.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      _MessTypeChip(messType: mess.messType),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Owner Info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text('Owner: ${mess.ownerName}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Contact Number
                  InkWell(
                    onTap: () => _makePhoneCall(mess.contactNumber),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          mess.contactNumber,
                          style: const TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(mess.address, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Today's Lunch Menu
                  _MenuSection(
                    title: 'Today\'s Lunch',
                    icon: Icons.lunch_dining,
                    content: mess.todayLunchMenu.isEmpty ? 'No menu available' : mess.todayLunchMenu,
                  ),
                  const SizedBox(height: 16),

                  // Today's Dinner Menu
                  _MenuSection(
                    title: 'Today\'s Dinner',
                    icon: Icons.dinner_dining,
                    content: mess.todayDinnerMenu.isEmpty ? 'No menu available' : mess.todayDinnerMenu,
                  ),
                  const SizedBox(height: 16),

                  // Subscription Info
                  Card(
                    color: hasSubscription ? Colors.green[50] : Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subscription Price:', style: TextStyle(fontSize: 16)),
                              Text('₹${mess.subscriptionPrice.toStringAsFixed(0)}', 
                                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Coupon Value:', style: TextStyle(fontSize: 16)),
                              Text('₹${mess.couponValue.toStringAsFixed(0)}', 
                                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (hasSubscription) ...[
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Your Coupons:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('${user!.coupons[mess.messId]}', 
                                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subscribe/Order Button
                  Builder(
                    builder: (context) {
                      // Parse cutoff time
                      // Format expected: "10:00 AM"
                      // Simple parsing logic
                      bool isPastCutoff = false;
                      try {
                        final now = TimeOfDay.now();
                        final cutoffParts = mess.cutoffTime.split(' '); // ["10:00", "AM"]
                        final timeParts = cutoffParts[0].split(':'); // ["10", "00"]
                        int hour = int.parse(timeParts[0]);
                        int minute = int.parse(timeParts[1]);
                        if (cutoffParts.length > 1 && cutoffParts[1] == 'PM' && hour != 12) hour += 12;
                        if (cutoffParts.length > 1 && cutoffParts[1] == 'AM' && hour == 12) hour = 0;
                        
                        final cutoff = TimeOfDay(hour: hour, minute: minute);
                        
                        // Compare
                        final nowMinutes = now.hour * 60 + now.minute;
                        final cutoffMinutes = cutoff.hour * 60 + cutoff.minute;
                        
                        if (nowMinutes > cutoffMinutes) {
                          isPastCutoff = true;
                        }
                      } catch (e) {
                        print("Error parsing cutoff: $e");
                      }

                      return Column(
                        children: [
                          if (isPastCutoff)
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.red[100],
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Ordering closed. Cutoff was ${mess.cutoffTime}', style: const TextStyle(color: Colors.red))),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: isPastCutoff && hasSubscription 
                                  ? null // Disable if past cutoff
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubscriptionScreen(mess: mess),
                                  ),
                                );
                              },
                              icon: Icon(hasSubscription ? Icons.shopping_bag : Icons.card_membership),
                              label: Text(
                                hasSubscription ? 'Order Now' : 'Subscribe Now',
                                style: const TextStyle(fontSize: 18),
                              ),
                              style: isPastCutoff && hasSubscription 
                                  ? ElevatedButton.styleFrom(backgroundColor: Colors.grey) 
                                  : null,
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 24),

                  // Extras Section
                  if (mess.extrasItems.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Extras / Fast Food',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...mess.extrasItems.map((extra) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(extra.name),
                            subtitle: Text('₹${extra.price.toStringAsFixed(0)}'),
                            trailing: extra.available
                                ? ElevatedButton(
                                    onPressed: () {
                                      context.read<CartProvider>().addToCart(
                                            CartItemModel(
                                              menuItemId: extra.id,
                                              name: extra.name,
                                              price: extra.price,
                                              quantity: 1,
                                            ),
                                            mess.messId,
                                          );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Added to cart'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: const Text('Add'),
                                  )
                                : const Text('Unavailable', style: TextStyle(color: Colors.red)),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              // Navigate to cart screen - we'll implement this later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart functionality coming soon')),
              );
            },
            label: Text('${cart.items.length} Items | ₹${cart.totalAmount.toStringAsFixed(0)}'),
            icon: const Icon(Icons.shopping_cart),
          );
        },
      ),
    );
  }
}

class _MessTypeChip extends StatelessWidget {
  final String messType;
  const _MessTypeChip({required this.messType});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;
    String label;

    switch (messType.toLowerCase()) {
      case 'veg':
        backgroundColor = Colors.green;
        icon = Icons.eco;
        label = 'Veg';
        break;
      case 'non-veg':
        backgroundColor = Colors.red;
        icon = Icons.restaurant;
        label = 'Non-Veg';
        break;
      default:
        backgroundColor = Colors.orange;
        icon = Icons.dining;
        label = 'Both';
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const _MenuSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
