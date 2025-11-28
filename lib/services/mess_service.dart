import 'dart:io';
import 'dart:math' show cos, sqrt, asin;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/mess_model.dart';

class MessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Create a new mess profile
  Future<void> createMess(MessModel mess) async {
    try {
      await _firestore.collection('messes').doc(mess.messId).set(mess.toJson());
    } catch (e) {
      print('Error creating mess: $e');
      rethrow;
    }
  }

  /// Update existing mess profile
  Future<void> updateMess(MessModel mess) async {
    try {
      await _firestore.collection('messes').doc(mess.messId).update(mess.toJson());
    } catch (e) {
      print('Error updating mess: $e');
      rethrow;
    }
  }

  /// Check if owner has a mess profile
  Future<MessModel?> fetchMessByOwnerUid(String ownerUid) async {
    try {
      final querySnapshot = await _firestore
          .collection('messes')
          .where('ownerUid', isEqualTo: ownerUid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return MessModel.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      print('Error fetching mess by owner UID: $e');
      return null;
    }
  }

  /// Fetch specific mess by ID
  Future<MessModel?> fetchMessById(String messId) async {
    try {
      final doc = await _firestore.collection('messes').doc(messId).get();
      if (!doc.exists) {
        return null;
      }
      return MessModel.fromJson(doc.data()!);
    } catch (e) {
      print('Error fetching mess by ID: $e');
      return null;
    }
  }

  /// Fetch all messes for student browsing
  Future<List<MessModel>> fetchAllMesses() async {
    try {
      final querySnapshot = await _firestore.collection('messes').get();
      return querySnapshot.docs
          .map((doc) => MessModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching all messes: $e');
      return [];
    }
  }

  /// Fetch messes within radius (client-side filtering for simplicity)
  Future<List<MessModel>> getMessesNear(double lat, double lng, double radiusInKm) async {
    try {
      // In a real app with many records, use GeoFlutterFire or server-side filtering
      final allMesses = await fetchAllMesses();
      
      // We need geolocator to calculate distance
      // Since we can't easily import geolocator here without adding it to the file imports,
      // we'll do a basic calculation or assume the caller handles it?
      // Better to add the import.
      
      // For now, return all messes and let the UI filter or add simple math here.
      // Implementing Haversine formula for distance
      return allMesses.where((mess) {
        if (mess.latitude == 0 && mess.longitude == 0) return false;
        
        final double distance = _calculateDistance(lat, lng, mess.latitude, mess.longitude);
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      print('Error fetching nearby messes: $e');
      return [];
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  /// Upload mess logo to Firebase Storage
  Future<String?> uploadMessLogo(File image, String messId) async {
    try {
      final ref = _storage.ref().child('mess_logos/$messId.jpg');
      final uploadTask = await ref.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading mess logo: $e');
      return null;
    }
  }

  /// Stream of all messes for real-time updates
  Stream<List<MessModel>> messesStream() {
    return _firestore.collection('messes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MessModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Stream of a specific mess for real-time updates
  Stream<MessModel?> messStream(String messId) {
    return _firestore.collection('messes').doc(messId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MessModel.fromJson(doc.data()!);
    });
  }
}
