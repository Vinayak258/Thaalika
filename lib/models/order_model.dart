import 'cart_item_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String messId;
  final List<CartItemModel> items;
  final double totalAmount;
  final int couponUsed;
  final double extraPaid;
  final double couponAmount; // Amount paid using coupons
  final double walletAmount; // Amount paid from wallet
  final double upiAmount; // Amount pending/paid via UPI
  final String paymentStatus; // 'completed', 'pending'
  final String status; // 'Placed', 'Preparing', 'Ready for Pickup', '  Completed'
  final DateTime timestamp;
  final double? rating;
  final String? feedback;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.messId,
    required this.items,
    required this.totalAmount,
    required this.couponUsed,
    required this.extraPaid,
    this.couponAmount = 0.0,
    this.walletAmount = 0.0,
    this.upiAmount = 0.0,
    this.paymentStatus = 'completed',
    required this.status,
    required this.timestamp,
    this.rating,
    this.feedback,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      messId: json['messId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromJson(e))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      couponUsed: json['couponUsed'] ?? 0,
      extraPaid: (json['extraPaid'] ?? 0.0).toDouble(),
      couponAmount: (json['couponAmount'] ?? 0.0).toDouble(),
      walletAmount: (json['walletAmount'] ?? 0.0).toDouble(),
      upiAmount: (json['upiAmount'] ?? 0.0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'completed',
      status: json['status'] ?? 'Placed',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      rating: (json['rating'] as num?)?.toDouble(),
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'messId': messId,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'couponUsed': couponUsed,
      'extraPaid': extraPaid,
      'couponAmount': couponAmount,
      'walletAmount': walletAmount,
      'upiAmount': upiAmount,
      'paymentStatus': paymentStatus,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
    };
  }

  OrderModel copyWith({
    String? orderId,
    String? userId,
    String? messId,
    List<CartItemModel>? items,
    double? totalAmount,
    int? couponUsed,
    double? extraPaid,
    double? couponAmount,
    double? walletAmount,
    double? upiAmount,
    String? paymentStatus,
    String? status,
    DateTime? timestamp,
    double? rating,
    String? feedback,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      messId: messId ?? this.messId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      couponUsed: couponUsed ?? this.couponUsed,
      extraPaid: extraPaid ?? this.extraPaid,
      couponAmount: couponAmount ?? this.couponAmount,
      walletAmount: walletAmount ?? this.walletAmount,
      upiAmount: upiAmount ?? this.upiAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
    );
  }
}
