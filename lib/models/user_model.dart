class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role; // 'student', 'owner'
  final double wallet;
  final Map<String, int> coupons; // messId -> count
  final String? messId; // For owners
  final String? location;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.wallet = 0.0,
    this.coupons = const {},
    this.messId,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      wallet: (json['wallet'] ?? 0.0).toDouble(),
      coupons: _parseCoupons(json['coupons']),
      messId: json['messId'],
      location: json['location'],
    );
  }

  // Helper to parse coupons field - handles backward compatibility
  static Map<String, int> _parseCoupons(dynamic couponsData) {
    if (couponsData == null) {
      return {};
    }
    // If it's already a Map, return it
    if (couponsData is Map) {
      return Map<String, int>.from(couponsData);
    }
    // If it's an old-style int (from previous schema), convert to empty map
    // Old data will need manual migration or can be handled via seed data
    if (couponsData is int) {
      print('⚠️  Detected old coupon format (int: $couponsData). Migrating to new format (Map). User may need to re-seed data.');
      return {};
    }
    return {};
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'wallet': wallet,
      'coupons': coupons,
      'messId': messId,
      'location': location,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? role,
    double? wallet,
    Map<String, int>? coupons,
    String? messId,
    String? location,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      wallet: wallet ?? this.wallet,
      coupons: coupons ?? this.coupons,
      messId: messId ?? this.messId,
      location: location ?? this.location,
    );
  }
}
