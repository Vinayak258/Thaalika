import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];
  String? _messId; // Cart can only have items from one mess

  List<CartItemModel> get items => _items;
  String? get messId => _messId;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void addToCart(CartItemModel item, String messId) {
    if (_messId != null && _messId != messId) {
      // Clear cart if adding from different mess
      _items.clear();
    }
    _messId = messId;

    final index = _items.indexWhere((i) => i.menuItemId == item.menuItemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(String menuItemId) {
    _items.removeWhere((item) => item.menuItemId == menuItemId);
    if (_items.isEmpty) {
      _messId = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _messId = null;
    notifyListeners();
  }
}
