// sign_in_screen.dart
import 'package:flutter/material.dart';
import 'sign_up_screen.dart';
import 'forget_password_screen.dart';
import '../home/home_screen.dart';
import '../../app/app_strings.dart';
import '../../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await AuthService.login(email: email, password: password);

      if (!mounted) return;

      // ✅ نتحقق إن الـ token اتحفظ فعلاً
      final token = await AuthService.getToken();

      if (token != null && token.isNotEmpty) {
        // ✅ login ناجح — روح للهوم
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(showSuccess: true),
          ),
        );
      } else {
        // ❌ الـ backend ما رجعش token — اطبع الـ response للـ debug
        debugPrint('Login response: $data');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed: No token received from server'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFE5E5E5),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 80,
                child: Image.asset(
                  'lib/assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.signInTitle,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(s.signInEmailLabel),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: s.signInEmailHint,
                            prefixIcon: const Icon(Icons.mail_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.signInPasswordLabel),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgetPasswordScreen(),
                                        ),
                                      );
                                    },
                              child: Text(
                                s.signInForgotPassword,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: s.signInPasswordHint,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    s.signInButton,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(s.signInOrContinue),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            _SocialButton(
                              label: s.signInGoogle,
                              icon: Icons.g_mobiledata,
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            _SocialButton(
                              label: s.signInFacebook,
                              icon: Icons.facebook,
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            _SocialButton(
                              label: s.signInApple,
                              icon: Icons.apple,
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                            child: Text.rich(
                              TextSpan(
                                text: s.signInNoAccount,
                                children: [
                                  TextSpan(
                                    text: s.signInSignUp,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}