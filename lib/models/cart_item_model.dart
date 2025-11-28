class CartItemModel {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;

  CartItemModel({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      menuItemId: json['menuItemId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
  }) {
    return CartItemModel(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
