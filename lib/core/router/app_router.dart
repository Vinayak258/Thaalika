import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../screens/auth/onboarding_screen.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/student/student_dashboard_screen.dart';
import '../../screens/student/mess_detail_screen.dart';
import '../../screens/student/cart_screen.dart';
import '../../screens/student/order_confirmation_screen.dart';
import '../../screens/student/order_tracking_screen.dart';
import '../../screens/student/wallet_profile_screen.dart';
import '../../screens/student/student_main_screen.dart';
import '../../screens/student/profile_screen.dart';
import '../../screens/owner/owner_dashboard_screen.dart';
import '../../screens/owner/menu_management_screen.dart';
import '../../screens/owner/order_management_screen.dart';
import '../../screens/owner/create_mess_profile_screen.dart';
import '../../screens/owner/edit_mess_profile_screen.dart';
import '../../screens/owner/extras_management_screen.dart';
import '../../models/mess_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'student';
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'student';
          return RegisterScreen(role: role);
        },
      ),
      // Student Shell Route for Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return StudentMainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/student-dashboard',
            builder: (context, state) => const StudentDashboardScreen(),
          ),
          GoRoute(
            path: '/order-tracking',
            builder: (context, state) => const OrderTrackingScreen(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletProfileScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/mess-detail',
        builder: (context, state) {
          final mess = state.extra as MessModel;
          return MessDetailScreen(mess: mess);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) {
          final mess = state.extra as MessModel;
          return OrderConfirmationScreen(mess: mess);
        },
      ),
      GoRoute(
        path: '/owner-dashboard',
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
      GoRoute(
        path: '/menu-management',
        builder: (context, state) => const MenuManagementScreen(),
      ),
      GoRoute(
        path: '/order-management',
        builder: (context, state) => const OrderManagementScreen(),
      ),
      GoRoute(
        path: '/create-mess-profile',
        builder: (context, state) => const CreateMessProfileScreen(),
      ),
      GoRoute(
        path: '/edit-mess-profile',
        builder: (context, state) => const EditMessProfileScreen(),
      ),
      GoRoute(
        path: '/extras-management',
        builder: (context, state) => const ExtrasManagementScreen(),
      ),
    ],
  );
}
