import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Thaalika';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String messesCollection = 'messes';
  static const String menuItemsCollection = 'menu_items';
  static const String ordersCollection = 'orders';
  static const String paymentsCollection = 'payments';

  // Order Status
  static const String orderStatusPlaced = 'Placed';
  static const String orderStatusCooking = 'Cooking';
  static const String orderStatusOutForDelivery = 'Out for delivery';
  static const String orderStatusDelivered = 'Delivered';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleOwner = 'owner';
  static const String roleDelivery = 'delivery';

  // Default Values
  static const double defaultWalletBalance = 1000.0;
  static const int defaultCoupons = 10;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
