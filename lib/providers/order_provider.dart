import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/mess_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  
  OrderProvider(this._orderService);

  Future<void> placeOrder(OrderModel order, MessModel mess, Map<String, int> userCoupons) async {
    // 1. Check Cutoff Time
    if (_isPastCutoff(mess.cutoffTime)) {
      throw Exception('Order cutoff time (${mess.cutoffTime}) has passed.');
    }

    // 2. Check Coupons if used
    if (order.couponUsed > 0) {
      final availableCoupons = userCoupons[mess.messId] ?? 0;
      if (availableCoupons < order.couponUsed) {
        throw Exception('Insufficient coupons for this mess.');
      }
    }

    await _orderService.placeOrder(order);
  }

  bool _isPastCutoff(String cutoffTimeStr) {
    try {
      final now = TimeOfDay.now();
      // Parse "10:00 AM"
      final parts = cutoffTimeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';

      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      final cutoff = TimeOfDay(hour: hour, minute: minute);

      if (now.hour > cutoff.hour) return true;
      if (now.hour == cutoff.hour && now.minute > cutoff.minute) return true;
      return false;
    } catch (e) {
      print("Error parsing cutoff time: $e");
      return false; // Fail safe
    }
  }
  
  Stream<List<OrderModel>> getOrders(String userId) {
    return _orderService.getOrdersByUserId(userId);
  }
  
  Stream<List<OrderModel>> getOwnerOrders(String messId) {
    return _orderService.getOrdersByMessId(messId);
  }
  
  Future<void> updateStatus(String orderId, String status) async {
    await _orderService.updateOrderStatus(orderId, status);
  }
}
