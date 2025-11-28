import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/mess_provider.dart';
import '../../models/mess_model.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _locationPermissionDenied = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationAndFetchMesses();
    });
  }

  Future<void> _requestLocationAndFetchMesses() async {
    setState(() {
      _isLoadingLocation = true;
      _locationPermissionDenied = false;
      _locationError = null;
    });

    try {
      // Request location permission
      final status = await Permission.location.request();
      
      if (status.isGranted) {
        // Get current position
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        // Fetch messes with location filtering
        if (mounted) {
          await context.read<MessProvider>().fetchMessesNearLocation(
            position.latitude,
            position.longitude,
            5.0, // 5 km radius
          );
        }
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _locationPermissionDenied = true;
          _isLoadingLocation = false;
          _locationError = 'Location permission permanently denied';
        });
        // Fetch all messes without filtering
        if (mounted) {
          await context.read<MessProvider>().fetchMesses();
        }
      } else {
        setState(() {
          _locationPermissionDenied = true;
          _isLoadingLocation = false;
          _locationError = 'Location permission denied';
        });
        // Fetch all messes without filtering
        if (mounted) {
          await context.read<MessProvider>().fetchMesses();
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Error getting location: ${e.toString()}';
      });
      // Fetch all messes without filtering
      if (mounted) {
        await context.read<MessProvider>().fetchMesses();
      }
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thaalika'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.push('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/wallet'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Location Status Banner
          if (_isLoadingLocation)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue[100],
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Getting your location...'),
                ],
              ),
            )
          else if (_locationPermissionDenied)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange[100],
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Allow location access to see nearby messes',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _requestLocationAndFetchMesses,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_locationError?.contains('permanently') ?? false)
                        TextButton.icon(
                          onPressed: _openAppSettings,
                          icon: const Icon(Icons.settings, size: 16),
                          label: const Text('Open Settings'),
                        ),
                    ],
                  ),
                ],
              ),
            )
          else if (_currentPosition != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Showing messes within 5 km',
                    style: TextStyle(color: Colors.green[900]),
                  ),
                ],
              ),
            ),

          // Filter Chips
          Consumer<MessProvider>(
            builder: (context, provider, _) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: provider.filterType == 'all',
                    onSelected: (selected) {
                      if (selected) provider.setFilter('all');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Veg',
                    isSelected: provider.filterType == 'veg',
                    onSelected: (selected) {
                      if (selected) provider.setFilter('veg');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Non-Veg',
                    isSelected: provider.filterType == 'non-veg',
                    onSelected: (selected) {
                      if (selected) provider.setFilter('non-veg');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Both',
                    isSelected: provider.filterType == 'both',
                    onSelected: (selected) {
                      if (selected) provider.setFilter('both');
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Mess List
          Expanded(
            child: Consumer<MessProvider>(
              builder: (context, messProvider, child) {
                if (messProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (messProvider.messes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _currentPosition != null
                              ? 'No messes found in your area'
                              : 'No messes found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_currentPosition != null)
                          const Text(
                            'Try expanding your search radius or check back later',
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messProvider.messes.length,
                  itemBuilder: (context, index) {
                    final mess = messProvider.messes[index];
                    
                    // Calculate distance if we have current position
                    double? distance;
                    if (_currentPosition != null && 
                        mess.latitude != 0.0 && 
                        mess.longitude != 0.0) {
                      distance = _calculateDistance(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                        mess.latitude,
                        mess.longitude,
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Icon(
                          mess.messType == 'veg' ? Icons.eco : Icons.restaurant,
                          size: 40,
                          color: mess.messType == 'veg' ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          mess.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mess.address),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  mess.messType.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mess.messType == 'veg' ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (distance != null) ...[
                                  const SizedBox(width: 8),
                                  const Text('•', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${distance.toStringAsFixed(1)} km away',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.push('/mess-detail', extra: mess),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/order-tracking'),
        child: const Icon(Icons.receipt_long),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      checkmarkColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
