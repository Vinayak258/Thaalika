class PaymentModel {
  final String paymentId;
  final String userId;
  final double amount;
  final String method;
  final DateTime timestamp;

  PaymentModel({
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.timestamp,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['paymentId'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      method: json['method'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
