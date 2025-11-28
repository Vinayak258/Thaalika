// import 'package:cloud_functions/cloud_functions.dart';

class WalletService {
  // final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> addMoney(String userId, double amount) async {
    // TEMPORARY: Dummy implementation for GitHub upload safety
    // await _functions.httpsCallable('addWalletMoney').call({
    //   'userId': userId,
    //   'amount': amount,
    // });
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    print("Dummy addMoney success: $amount");
  }

  Future<void> deduct(String userId, double amount, int coupons, {String? messId}) async {
    // TEMPORARY: Dummy implementation for GitHub upload safety
    // await _functions.httpsCallable('deductWalletMoney').call({
    //   'userId': userId,
    //   'amount': amount,
    //   'coupons': coupons,
    //   'messId': messId,
    // });
    await Future.delayed(const Duration(seconds: 1));
    print("Dummy deduct success: $amount, coupons: $coupons");
  }

  Future<void> purchaseSubscription({
    required String userId,
    required String messId,
    required double planPrice,
    required int couponCount,
  }) async {
    // TEMPORARY: Dummy implementation for GitHub upload safety
    // await _functions.httpsCallable('purchaseSubscription').call({
    //   'userId': userId,
    //   'messId': messId,
    //   'planPrice': planPrice,
    //   'couponCount': couponCount,
    // });
    await Future.delayed(const Duration(seconds: 1));
    print("Dummy purchaseSubscription success: $planPrice");
  }
}
