import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/user_provider.dart';
import '../../utils/validators.dart';
import 'otp_coming_soon_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _useEmailLogin = true; // Default to email login

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showOTPComingSoon() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OTPComingSoonScreen()),
    );
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<app_auth.AuthProvider>().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        final user = context.read<app_auth.AuthProvider>().user;
        if (user != null) {
          await context.read<UserProvider>().fetchUser(user.uid);
        }

        final redirectPath = await context.read<app_auth.AuthProvider>().getRedirectScreen();
        
        if (mounted) {
          context.go(redirectPath);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed';
        if (e.code == 'invalid-credential' ||
            e.code == 'user-not-found' ||
            e.code == 'wrong-password') {
          errorMessage = 'Invalid email or password';
        } else if (e.code == 'email-not-verified') {
          errorMessage = 'Email not verified. Please check your inbox.';
        } else {
          errorMessage = 'Login failed: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login as ${widget.role}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              
              // Toggle between OTP and Email login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_useEmailLogin ? 'Email Login' : 'Phone Login'),
                  Switch(
                    value: _useEmailLogin,
                    onChanged: (value) {
                      setState(() => _useEmailLogin = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!_useEmailLogin) ...[
                // Phone OTP Login (Coming Soon)
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+91XXXXXXXXXX or XXXXXXXXXX',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showOTPComingSoon,
                    child: const Text('Send OTP'),
                  ),
                ),
              ] else ...[
                // Email/Password Login
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _loginWithEmail,
                          child: const Text('Login with Email'),
                        ),
                ),
              ],
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register?role=${widget.role}'),
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
