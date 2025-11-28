import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: Text('User not found'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(user.email)),
          Center(child: Text(user.phone)),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Location'),
            subtitle: Text(user.location ?? 'Not set'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Implement edit location
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthProvider>().signOut();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
