import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/user_provider.dart';
import '../../models/menu_item_model.dart';
import '../../services/menu_service.dart';
import '../../providers/menu_provider.dart'; // Ensure this is imported if used, but we are using MenuService directly in state? 
// Wait, the previous code used MenuProvider in build but MenuService in dialog. 
// Let's stick to the pattern. The user asked for "Use menuService.addMenuItem...".
// I will use MenuService directly as requested in the prompt "Use menuService.addMenuItem".

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final MenuService _menuService = MenuService();

  void _showAddEditDialog([MenuItemModel? item]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item?.name);
    final priceController = TextEditingController(text: item?.price.toString());
    String type = item?.type ?? 'veg';
    bool available = item?.available ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Edit Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return _menuService.searchCatalog(textEditingValue.text);
                  },
                  onSelected: (String selection) {
                    nameController.text = selection;
                  },
                  fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                    if (nameController.text.isNotEmpty && fieldTextEditingController.text.isEmpty) {
                       fieldTextEditingController.text = nameController.text;
                    }
                    
                    fieldTextEditingController.addListener(() {
                      nameController.text = fieldTextEditingController.text;
                    });

                    return TextFormField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Price is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: type,
                  items: ['veg', 'non-veg']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (val) => type = val!,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                CheckboxListTile(
                  title: const Text('Available'),
                  value: available,
                  onChanged: (val) {
                    available = val!;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final user = context.read<UserProvider>().userModel;
              if (user?.messId == null) return;

              final newItem = MenuItemModel(
                id: item?.id ?? const Uuid().v4(),
                messId: user!.messId!,
                name: nameController.text.trim(),
                price: double.parse(priceController.text.trim()),
                available: available,
                type: type,
              );

              if (item == null) {
                await _menuService.addMenuItem(newItem);
                await _menuService.addToCatalog(newItem.name);
              } else {
                await _menuService.updateMenuItem(newItem);
              }

              if (mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    
    if (user?.messId == null) {
      return const Scaffold(
        body: Center(child: Text('No Mess ID found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Menu')),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: _menuService.getMenuStream(user!.messId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final menuItems = snapshot.data ?? [];

          if (menuItems.isEmpty) {
            return const Center(child: Text('No menu items added yet.'));
          }

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('₹${item.price} • ${item.type}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: item.available,
                      onChanged: (val) {
                        _menuService.updateAvailability(item.id, val);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _menuService.deleteMenuItem(item.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
