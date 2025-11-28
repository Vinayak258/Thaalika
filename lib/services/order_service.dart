import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  Future<void> placeOrder(OrderModel order) async {
    await _firestore.collection(_collection).doc(order.orderId).set(order.toJson());
  }

  Stream<List<OrderModel>> getOrdersByUserId(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }

  Stream<List<OrderModel>> getOrdersByMessId(String messId) {
    return _firestore
        .collection(_collection)
        .where('messId', isEqualTo: messId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(_collection).doc(orderId).update({'status': status});
  }
  

}
