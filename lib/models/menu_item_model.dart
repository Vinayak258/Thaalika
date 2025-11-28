class MenuItemModel {
  final String id;
  final String messId;
  final String name;
  final double price;
  final bool available;
  final String type; // 'veg', 'non-veg'

  MenuItemModel({
    required this.id,
    required this.messId,
    required this.name,
    required this.price,
    required this.available,
    required this.type,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? '',
      messId: json['messId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      available: json['available'] ?? true,
      type: json['type'] ?? 'veg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messId': messId,
      'name': name,
      'price': price,
      'available': available,
      'type': type,
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? messId,
    String? name,
    double? price,
    bool? available,
    String? type,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      name: name ?? this.name,
      price: price ?? this.price,
      available: available ?? this.available,
      type: type ?? this.type,
    );
  }
}
