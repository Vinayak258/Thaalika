class ExtraItemModel {
  final String id;
  final String name;
  final double price;
  final bool available;

  ExtraItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.available = true,
  });

  factory ExtraItemModel.fromJson(Map<String, dynamic> json) {
    return ExtraItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      available: json['available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'available': available,
    };
  }

  ExtraItemModel copyWith({
    String? id,
    String? name,
    double? price,
    bool? available,
  }) {
    return ExtraItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      available: available ?? this.available,
    );
  }
}
