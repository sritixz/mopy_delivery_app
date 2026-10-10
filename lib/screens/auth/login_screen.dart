import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../dashboard/runner_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+91 98765 12345');
  final _passwordController = TextEditingController(text: 'runner123');
  bool _obscureText = true;
  bool _isOtpMode = false;
  final _otpController = TextEditingController(text: '4826');

  Future<void> _handleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RunnerDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed. Please check credentials.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Icon
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delivery_dining_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title & Subtitle
                  const Center(
                    child: Text(
                      'MOPY RUNNER',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Kiosk-to-Desk Corporate Delivery Partner App',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mode Selector: OTP vs Password
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgCardDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isOtpMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isOtpMode ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Staff Password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: !_isOtpMode ? Colors.white : AppColors.textMutedLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isOtpMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isOtpMode ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Mobile OTP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _isOtpMode ? Colors.white : AppColors.textMutedLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mobile / Email Input
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: _isOtpMode ? 'Registered Mobile Number' : 'Staff Mobile / Email',
                      prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppColors.primary),
                      filled: true,
                      fillColor: isDark ? AppColors.bgCardDark : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password or OTP input
                  if (!_isOtpMode)
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textMutedLight,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.bgCardDark : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '4-Digit OTP',
                              prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary),
                              filled: true,
                              fillColor: isDark ? AppColors.bgCardDark : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OTP sent to registered mobile: 4826')),
                            );
                          },
                          child: const Text('RESEND OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleLogin,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('START SHIFT & LOGIN'),
                  ),
                  const SizedBox(height: 16),

                  // Quick Demo Autofill Pill
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _phoneController.text = '+91 98765 12345';
                          _passwordController.text = 'runner123';
                        });
                        _handleLogin();
                      },
                      icon: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.goldAccent),
                      label: const Text(
                        'Demo Partner 1-Tap Login',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.goldAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
