import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/mess_model.dart';
import '../services/mess_service.dart';

class MessProvider with ChangeNotifier {
  final MessService _messService;

  List<MessModel> _messes = [];
  MessModel? _currentOwnerMess;
  bool _isLoading = false;
  String _filterType = 'all'; // 'all', 'veg', 'non-veg', 'both'

  List<MessModel> get messes {
    if (_filterType == 'all') {
      return _messes;
    }
    return _messes.where((mess) => mess.messType == _filterType).toList();
  }

  MessModel? get currentOwnerMess => _currentOwnerMess;
  bool get isLoading => _isLoading;
  String get filterType => _filterType;

  MessProvider(this._messService);

  /// Fetch all messes for student browsing
  Future<void> fetchMesses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _messes = await _messService.fetchAllMesses();
    } catch (e) {
      debugPrint('Error fetching messes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch messes near a specific location within a radius (in km)
  Future<void> fetchMessesNearLocation(double userLat, double userLng, double radiusKm) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch all messes
      final allMesses = await _messService.fetchAllMesses();
      
      // Filter messes within radius and sort by distance
      final nearbyMesses = <MessModel>[];
      final messesWithDistance = <Map<String, dynamic>>[];

      for (var mess in allMesses) {
        // Skip messes without valid coordinates
        if (mess.latitude == 0.0 && mess.longitude == 0.0) {
          continue;
        }

        // Calculate distance
        final distance = Geolocator.distanceBetween(
          userLat,
          userLng,
          mess.latitude,
          mess.longitude,
        ) / 1000; // Convert to km

        // Only include if within radius
        if (distance <= radiusKm) {
          messesWithDistance.add({
            'mess': mess,
            'distance': distance,
          });
        }
      }

      // Sort by distance (nearest first)
      messesWithDistance.sort((a, b) => 
        (a['distance'] as double).compareTo(b['distance'] as double)
      );

      // Extract sorted messes
      _messes = messesWithDistance.map((item) => item['mess'] as MessModel).toList();

    } catch (e) {
      debugPrint('Error fetching nearby messes: $e');
      _messes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set filter type for mess browsing
  void setFilter(String type) {
    _filterType = type;
    notifyListeners();
  }

  /// Fetch owner's mess profile
  Future<MessModel?> fetchOwnerMess(String ownerUid) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentOwnerMess = await _messService.fetchMessByOwnerUid(ownerUid);
      return _currentOwnerMess;
    } catch (e) {
      debugPrint('Error fetching owner mess: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new mess profile
  Future<bool> createMess(MessModel mess, {File? logoFile}) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Upload logo if provided
      String? logoUrl;
      if (logoFile != null) {
        logoUrl = await _messService.uploadMessLogo(logoFile, mess.messId);
      }

      // Create mess with logo URL
      final messWithLogo = mess.copyWith(logoUrl: logoUrl);
      await _messService.createMess(messWithLogo);
      _currentOwnerMess = messWithLogo;
      
      return true;
    } catch (e) {
      debugPrint('Error creating mess: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update existing mess profile
  Future<bool> updateMess(MessModel mess, {File? newLogoFile}) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Upload new logo if provided
      String? logoUrl = mess.logoUrl;
      if (newLogoFile != null) {
        logoUrl = await _messService.uploadMessLogo(newLogoFile, mess.messId);
      }

      // Update mess with new logo URL if changed
      final messWithLogo = newLogoFile != null ? mess.copyWith(logoUrl: logoUrl) : mess;
      await _messService.updateMess(messWithLogo);
      _currentOwnerMess = messWithLogo;
      
      // Update in local list if exists
      final index = _messes.indexWhere((m) => m.messId == mess.messId);
      if (index != -1) {
        _messes[index] = messWithLogo;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error updating mess: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch specific mess by ID
  Future<MessModel?> fetchMessById(String messId) async {
    try {
      return await _messService.fetchMessById(messId);
    } catch (e) {
      debugPrint('Error fetching mess by ID: $e');
      return null;
    }
  }

  /// Clear current owner mess (for logout)
  void clearOwnerMess() {
    _currentOwnerMess = null;
    notifyListeners();
  }
}
