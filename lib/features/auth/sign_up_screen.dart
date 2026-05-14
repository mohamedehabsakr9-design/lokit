// sign_up_screen.dart
import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import '../home/home_screen.dart';
import '../../app/app_strings.dart';
import '../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final s = AppStrings.of(context);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // ── التحقق من الحقول الفاضية
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.pleaseFillAllFields)),
      );
      return;
    }

    // ── التحقق من صيغة الإيميل
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email address')),
      );
      return;
    }

    // ── التحقق من رقم الهاتف (أرقام فقط)
    if (phone.length < 10 || !RegExp(r'^\d+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }

    // ✅ التحقق من طول الباسورد — السبب الرئيسي للـ 400
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    // ── التحقق من تطابق الباسورد
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password and confirm password do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );

      if (!mounted) return;

      // ✅ التحقق إن الـ token اتحفظ بعد التسجيل
      final token = await AuthService.getToken();

      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // ✅ لو مفيش token — ممكن الـ backend محتاج تأكيد إيميل أو حاجة تانية
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data?['message'] ?? 'Account created! Please sign in.',
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // ✅ رسائل خطأ واضحة حسب نوع الـ error
      String errorMsg = 'Sign up failed. Please try again.';
      final err = e.toString();

      if (err.contains('400')) {
        errorMsg = 'Invalid data. Please check your information.';
      } else if (err.contains('409') || err.contains('already')) {
        errorMsg = 'Email already registered. Please sign in.';
      } else if (err.contains('email')) {
        errorMsg = 'Invalid email address.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFE5E5E5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.signUpTitle,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ── First Name
                Text(s.signUpFirstName),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstNameController,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: s.signUpFirstName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Last Name
                Text(s.signUpLastName),
                const SizedBox(height: 8),
                TextField(
                  controller: _lastNameController,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: s.signUpLastName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Email
                Text(s.signUpEmailLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: s.signUpEmailLabel,
                    prefixIcon: const Icon(Icons.mail_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Phone
                Text(s.signUpPhone),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: s.signUpPhone,
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Password
                Text(s.signUpPassword),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: s.signUpPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    // ✅ hint للمستخدم إن الباسورد لازم 8 أحرف
                    helperText: 'At least 8 characters',
                    helperStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirm Password
                Text(s.signUpConfirmPassword),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: s.signUpConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── زر Sign Up
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      disabledBackgroundColor: Colors.black54,
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
                            s.signUpButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignInScreen(),
                              ),
                            );
                          },
                    child: Text.rich(
                      TextSpan(
                        text: s.signUpAlreadyHave,
                        children: [
                          TextSpan(
                            text: s.signUpSignIn,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}