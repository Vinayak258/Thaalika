import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mess_provider.dart';
import '../../models/extra_item_model.dart';

class ExtrasManagementScreen extends StatefulWidget {
  const ExtrasManagementScreen({super.key});

  @override
  State<ExtrasManagementScreen> createState() => _ExtrasManagementScreenState();
}

class _ExtrasManagementScreenState extends State<ExtrasManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadMess();
  }

  Future<void> _loadMess() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await context.read<MessProvider>().fetchOwnerMess(user.uid);
    }
  }

  void _showAddEditDialog({ExtraItemModel? existing, int? index}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(0) : '',
    );
    final isAvailable = existing?.available ?? true;
    bool available = isAvailable;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Extra Item' : 'Edit Extra Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Available'),
                value: available,
                onChanged: (value) {
                  setState(() => available = value ?? true);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final price = double.tryParse(priceController.text.trim());
                if (price == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid price')),
                  );
                  return;
                }

                final newItem = ExtraItemModel(
                  id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  price: price,
                  available: available,
                );

                Navigator.pop(dialogContext);
                _saveExtra(newItem, index);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExtra(ExtraItemModel newItem, int? index) async {
    final messProvider = context.read<MessProvider>();
    final currentMess = messProvider.currentOwnerMess;

    if (currentMess == null) return;

    final updatedExtras = List<ExtraItemModel>.from(currentMess.extrasItems);
    
    if (index != null) {
      // Edit existing
      updatedExtras[index] = newItem;
    } else {
      // Add new
      updatedExtras.add(newItem);
    }

    final updatedMess = currentMess.copyWith(extrasItems: updatedExtras);
    final success = await messProvider.updateMess(updatedMess);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Extra item saved' : 'Failed to save')),
      );
    }
  }

  Future<void> _deleteExtra(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Extra Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final messProvider = context.read<MessProvider>();
    final currentMess = messProvider.currentOwnerMess;

    if (currentMess == null) return;

    final updatedExtras = List<ExtraItemModel>.from(currentMess.extrasItems);
    updatedExtras.removeAt(index);

    final updatedMess = currentMess.copyWith(extrasItems: updatedExtras);
    final success = await messProvider.updateMess(updatedMess);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Extra item deleted' : 'Failed to delete')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messProvider = context.watch<MessProvider>();
    final currentMess = messProvider.currentOwnerMess;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Extras'),
      ),
      body: currentMess == null
          ? const Center(child: CircularProgressIndicator())
          : currentMess.extrasItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No extras items yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap + to add your first extra item',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentMess.extrasItems.length,
                  itemBuilder: (context, index) {
                    final item = currentMess.extrasItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.fastfood,
                          color: item.available ? Colors.green : Colors.grey,
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '₹${item.price.toStringAsFixed(0)} • ${item.available ? "Available" : "Unavailable"}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditDialog(
                                existing: item,
                                index: index,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExtra(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Extra'),
      ),
    );
  }
}
