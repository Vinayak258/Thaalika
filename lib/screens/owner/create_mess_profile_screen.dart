import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mess_provider.dart';
import '../../models/mess_model.dart';
import '../../models/extra_item_model.dart';

class CreateMessProfileScreen extends StatefulWidget {
  const CreateMessProfileScreen({super.key});

  @override
  State<CreateMessProfileScreen> createState() => _CreateMessProfileScreenState();
}

class _CreateMessProfileScreenState extends State<CreateMessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _lunchMenuController = TextEditingController();
  final _dinnerMenuController = TextEditingController();
  
  String _messType = 'both';
  File? _logoFile;
  List<ExtraItem> _extrasItems = [];
  bool _isLoading = false;
  
  // Location fields
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedAddress;

  // Get API key from environment variable
  static const String _googleApiKey = String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: '',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _ownerNameController.text = user.name;
        _contactController.text = user.phone;
      }
    });
  }

  @override
  void dispose() {
    _messNameController.dispose();
    _ownerNameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _lunchMenuController.dispose();
    _dinnerMenuController.dispose();
    for (var item in _extrasItems) {
      item.nameController.dispose();
      item.priceController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  void _addExtraItem() {
    setState(() {
      _extrasItems.add(ExtraItem(
        nameController: TextEditingController(),
        priceController: TextEditingController(),
      ));
    });
  }

  void _removeExtraItem(int index) {
    setState(() {
      _extrasItems[index].nameController.dispose();
      _extrasItems[index].priceController.dispose();
      _extrasItems.removeAt(index);
    });
  }

  Future<void> _onPlaceSelected(Prediction prediction) async {
    try {
      final locations = await locationFromAddress(prediction.description ?? '');
      if (locations.isNotEmpty) {
        setState(() {
          _selectedLat = locations.first.latitude;
          _selectedLng = locations.first.longitude;
          _selectedAddress = prediction.description;
          _addressController.text = prediction.description ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location from autocomplete suggestions')),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final messId = 'mess_${user.uid}';

      final extrasModels = _extrasItems.map((item) {
        return ExtraItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + item.nameController.text.replaceAll(' ', '_'),
          name: item.nameController.text.trim(),
          price: double.tryParse(item.priceController.text.trim()) ?? 0.0,
        );
      }).toList();

      final mess = MessModel(
        messId: messId,
        ownerUid: user.uid,
        name: _messNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        contactNumber: _contactController.text.trim(),
        address: _selectedAddress ?? _addressController.text.trim(),
        messType: _messType,
        couponValue: 50.0,
        subscriptionPrice: 2000.0,
        latitude: _selectedLat!,
        longitude: _selectedLng!,
        location: _selectedAddress ?? _addressController.text.trim(),
        todayLunchMenu: _lunchMenuController.text.trim(),
        todayDinnerMenu: _dinnerMenuController.text.trim(),
        extrasItems: extrasModels,
      );

      final success = await context.read<MessProvider>().createMess(
        mess,
        logoFile: _logoFile,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mess profile created successfully!')),
        );
        context.go('/owner-dashboard');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create mess profile')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Mess Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Upload
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: _logoFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(_logoFile!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                                    const SizedBox(height: 8),
                                    Text('Add Logo', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _messNameController,
                      decoration: const InputDecoration(
                        labelText: 'Mess Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mess name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter owner name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location with Google Places Autocomplete
                    Text(
                      'Location *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_googleApiKey.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(
                                  'Google API Key Required',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Run app with: flutter run --dart-define=GOOGLE_API_KEY=your_key',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    else
                      GooglePlaceAutoCompleteTextField(
                        textEditingController: _addressController,
                        googleAPIKey: _googleApiKey,
                        inputDecoration: InputDecoration(
                          labelText: 'Search location',
                          hintText: 'Type area, PIN code, or landmark',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: _selectedLat != null
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        ),
                        debounceTime: 800,
                        countries: const ["in"],
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          _onPlaceSelected(prediction);
                        },
                        itemClick: (Prediction prediction) {
                          _addressController.text = prediction.description ?? '';
                          _addressController.selection = TextSelection.fromPosition(
                            TextPosition(offset: prediction.description?.length ?? 0),
                          );
                        },
                        seperatedBuilder: const Divider(),
                        containerHorizontalPadding: 10,
                        itemBuilder: (context, index, Prediction prediction) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.grey),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    prediction.description ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        isCrossBtnShown: true,
                      ),
                    if (_selectedLat != null && _selectedLng != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Location confirmed: ${_selectedLat!.toStringAsFixed(6)}, ${_selectedLng!.toStringAsFixed(6)}',
                          style: TextStyle(fontSize: 12, color: Colors.green[700]),
                        ),
                      ),
                    const SizedBox(height: 16),

                    Text(
                      'Mess Type *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _messType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.dining),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'veg', child: Text('Vegetarian')),
                        DropdownMenuItem(value: 'non-veg', child: Text('Non-Vegetarian')),
                        DropdownMenuItem(value: 'both', child: Text('Both')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _messType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _lunchMenuController,
                      decoration: const InputDecoration(
                        labelText: 'Today\'s Lunch Menu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lunch_dining),
                        hintText: 'e.g., Dal, Rice, Roti, Salad',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _dinnerMenuController,
                      decoration: const InputDecoration(
                        labelText: 'Today\'s Dinner Menu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.dinner_dining),
                        hintText: 'e.g., Paneer, Naan, Rice',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Extras / Fast Food Items',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: Theme.of(context).primaryColor,
                          onPressed: _addExtraItem,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._extrasItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: item.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Item Name',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: item.priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  prefixText: '₹',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeExtraItem(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Create Mess Profile', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}

class ExtraItem {
  final TextEditingController nameController;
  final TextEditingController priceController;

  ExtraItem({
    required this.nameController,
    required this.priceController,
  });
}
