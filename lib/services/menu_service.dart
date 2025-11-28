import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menu_items';

  Future<void> addMenuItem(MenuItemModel item) async {
    await _firestore.collection(_collection).doc(item.id).set(item.toJson());
  }

  Future<List<MenuItemModel>> getMenuByMessId(String messId) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_collection)
        .where('messId', isEqualTo: messId)
        .get();
    return snapshot.docs
        .map((doc) => MenuItemModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    await _firestore.collection(_collection).doc(item.id).update(item.toJson());
  }

  Future<void> deleteMenuItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<List<String>> searchCatalog(String query) async {
    if (query.isEmpty) return [];
    
    final snapshot = await _firestore
        .collection('food_catalog')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<void> addToCatalog(String name) async {
    final snapshot = await _firestore
        .collection('food_catalog')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      await _firestore.collection('food_catalog').add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<MenuItemModel>> getMenuStream(String messId) {
    return _firestore
        .collection(_collection)
        .where('messId', isEqualTo: messId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> updateAvailability(String id, bool available) async {
    await _firestore.collection(_collection).doc(id).update({'available': available});
  }
}
