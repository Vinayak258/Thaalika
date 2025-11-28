import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mess_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../models/mess_model.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  MessModel? _currentMess;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMess();
  }

  Future<void> _loadMess() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final mess = await context.read<MessProvider>().fetchOwnerMess(user.uid);
      setState(() {
        _currentMess = mess;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showQuickEditDialog(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLunchMenu() async {
    if (_currentMess == null) return;
    
    _showQuickEditDialog(
      'Update Lunch Menu',
      _currentMess!.todayLunchMenu,
      (newMenu) async {
        final updated = _currentMess!.copyWith(todayLunchMenu: newMenu);
        final success = await context.read<MessProvider>().updateMess(updated);
        if (success) {
          setState(() => _currentMess = updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lunch menu updated')),
            );
          }
        }
      },
    );
  }

  Future<void> _updateDinnerMenu() async {
    if (_currentMess == null) return;
    
    _showQuickEditDialog(
      'Update Dinner Menu',
      _currentMess!.todayDinnerMenu,
      (newMenu) async {
        final updated = _currentMess!.copyWith(todayDinnerMenu: newMenu);
        final success = await context.read<MessProvider>().updateMess(updated);
        if (success) {
          setState(() => _currentMess = updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dinner menu updated')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentMess == null
              ? Center(
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
                          'No mess profile found',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create your mess profile to start managing orders and menus.',
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
                )
              : RefreshIndicator(
                  onRefresh: _loadMess,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Owner'}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _currentMess!.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.push('/edit-mess-profile'),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                title: 'Update Lunch',
                                icon: Icons.lunch_dining,
                                color: Colors.orange,
                                onTap: _updateLunchMenu,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionCard(
                                title: 'Update Dinner',
                                icon: Icons.dinner_dining,
                                color: Colors.purple,
                                onTap: _updateDinnerMenu,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Main Actions
                        _DashboardCard(
                          title: 'View Orders',
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                          onTap: () => context.push('/order-management'),
                        ),
                        const SizedBox(height: 12),
                        _DashboardCard(
                          title: 'Manage Menu Items',
                          icon: Icons.restaurant_menu,
                          color: Colors.green,
                          onTap: () => context.push('/menu-management'),
                        ),
                        const SizedBox(height: 12),
                        _DashboardCard(
                          title: 'Manage Extras',
                          icon: Icons.fastfood,
                          color: Colors.deepOrange,
                          onTap: () => context.push('/extras-management'),
                        ),
                        const SizedBox(height: 24),

                        // Financial Summary
                        Consumer<OrderProvider>(
                          builder: (context, orderProvider, child) {
                            return StreamBuilder<List<OrderModel>>(
                              stream: orderProvider.getOwnerOrders(_currentMess!.messId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(child: CircularProgressIndicator()),
                                    ),
                                  );
                                }

                                final orders = snapshot.data!;
                                final today = DateTime.now();
                                final todayOrders = orders.where((o) => 
                                  o.timestamp.year == today.year && 
                                  o.timestamp.month == today.month && 
                                  o.timestamp.day == today.day
                                ).toList();

                                int totalCoupons = 0;
                                double walletRevenue = 0;

                                for (var order in todayOrders) {
                                  totalCoupons += order.couponUsed;
                                  walletRevenue += order.extraPaid;
                                }

                                return Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Today\'s Summary',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _SummaryItem(
                                              label: 'Orders',
                                              value: '${todayOrders.length}',
                                              color: Colors.blue,
                                            ),
                                            _SummaryItem(
                                              label: 'Wallet Revenue',
                                              value: '₹${walletRevenue.toStringAsFixed(0)}',
                                              color: Colors.green,
                                            ),
                                            _SummaryItem(
                                              label: 'Coupons Used',
                                              value: '$totalCoupons',
                                              color: Colors.orange,
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
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
