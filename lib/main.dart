import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/menu_service.dart';
import 'services/order_service.dart';
import 'services/wallet_service.dart';
import 'services/notification_service.dart';
import 'services/mess_service.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/mess_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/notification_provider.dart';

import 'core/router/app_router.dart';
import 'themes/app_theme.dart';
import 'utils/seed_data.dart';

// Background FCM handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔔 Background notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Run Seed Data (will only run once based on Firestore flag)
  // await SeedData.seedFirestore();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<MenuService>(create: (_) => MenuService()),
        Provider<OrderService>(create: (_) => OrderService()),
        Provider<WalletService>(create: (_) => WalletService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<MessService>(create: (_) => MessService()),

        /// 🔥 AuthProvider (needs Auth + User + Mess service)
        ChangeNotifierProxyProvider3<AuthService, UserService, MessService, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<UserService>(),
            context.read<MessService>(),
          ),
          update: (_, authService, userService, messService, __) =>
              AuthProvider(authService, userService, messService),
        ),

        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (context) => UserProvider(context.read<UserService>()),
          update: (_, userService, __) => UserProvider(userService),
        ),
        ChangeNotifierProvider(create: (_) => MessProvider(MessService())),
        ChangeNotifierProxyProvider<MenuService, MenuProvider>(
          create: (context) => MenuProvider(context.read<MenuService>()),
          update: (_, menuService, __) => MenuProvider(menuService),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProxyProvider<OrderService, OrderProvider>(
          create: (context) => OrderProvider(context.read<OrderService>()),
          update: (_, orderService, __) => OrderProvider(orderService),
        ),
        ChangeNotifierProxyProvider<WalletService, WalletProvider>(
          create: (context) => WalletProvider(context.read<WalletService>()),
          update: (_, walletService, __) => WalletProvider(walletService),
        ),
        ChangeNotifierProxyProvider<NotificationService, NotificationProvider>(
          create: (context) =>
              NotificationProvider(context.read<NotificationService>()),
          update: (_, notificationService, __) =>
              NotificationProvider(notificationService),
        ),
      ],
      child: MaterialApp.router(
        title: 'Thaalika App',
        theme: AppTheme.theme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
