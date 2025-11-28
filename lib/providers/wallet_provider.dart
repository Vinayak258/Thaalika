import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService;

  WalletProvider(this._walletService);

  Future<void> deduct(String userId, double amount, int coupons, {String? messId}) async {
    await _walletService.deduct(userId, amount, coupons, messId: messId);
  }

  Future<void> purchaseSubscription(String userId, String messId, double price, int coupons) async {
    await _walletService.purchaseSubscription(
      userId: userId,
      messId: messId,
      planPrice: price,
      couponCount: coupons,
    );
  }
}
