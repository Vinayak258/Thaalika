import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 100, color: Color(0xFFFF8A00)),
            const SizedBox(height: 24),
            Text(
              'Welcome to Thaalika',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF8A00),
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delicious homemade food delivered to you.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.go('/role-selection');
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
