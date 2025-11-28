import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../utils/validators.dart';
import 'otp_coming_soon_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _useEmailRegister = true; // Default to email registration

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _registerWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<app_auth.AuthProvider>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: widget.role,
      );

      if (success && mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/login?role=${widget.role}');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please verify your email and login.')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Register as ${widget.role}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),

              // Toggle between OTP and Email registration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_useEmailRegister ? 'Email Registration' : 'Phone Registration'),
                  Switch(
                    value: _useEmailRegister,
                    onChanged: (value) {
                      setState(() => _useEmailRegister = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '+91XXXXXXXXXX or XXXXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),

              if (_useEmailRegister) ...[
                // Email/Password Registration
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
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
                    labelText: 'Password *',
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
                          onPressed: _registerWithEmail,
                          child: const Text('Register'),
                        ),
                ),
              ] else ...[
                // Phone OTP Registration (Coming Soon)
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showOTPComingSoon,
                    child: const Text('Send OTP'),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
