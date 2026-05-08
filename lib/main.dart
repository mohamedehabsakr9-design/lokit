// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// شاشات التطبيق
import 'features/splash/splash_screen1.dart';
import 'features/splash/splash_screen2.dart'; // فيه OnboardingScreen
import 'features/auth/sign_in_screen.dart' as auth;
import 'features/auth/sign_up_screen.dart' as register;
import 'features/auth/forget_password_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const LokitApp());
}

/// Root widget للتطبيق كله مع دعم تغيير اللغة
class LokitApp extends StatefulWidget {
  const LokitApp({super.key});

  /// دالة استاتيكية لتغيير اللغة من أي شاشة (مثلاً من شاشة البروفايل)
  static void setLocale(BuildContext context, Locale locale) {
    final _LokitAppState? state =
        context.findAncestorStateOfType<_LokitAppState>();
    state?.changeLocale(locale);
  }

  @override
  State<LokitApp> createState() => _LokitAppState();
}

class _LokitAppState extends State<LokitApp> {
  // اللغة الافتراضية: إنجليزي
  Locale _locale = const Locale('en');

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lokit',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),

      // اللغة الحالية
      locale: _locale,

      // اللغات المدعومة
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      // الـ delegates الخاصة بواجهات Flutter
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // اختيار أقرب لغة مدعومة + دعم RTL للعربي
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (final l in supportedLocales) {
          if (l.languageCode == locale.languageCode) return l;
        }
        return supportedLocales.first;
      },

      // أول شاشة هتفتح
      home: const SplashLogoScreen(),

      routes: {
        '/splash': (_) => const SplashLogoScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/signin': (_) => const auth.SignInScreen(),
        '/signup': (_) => const register.SignUpScreen(),
        '/forget-password': (_) => const ForgetPasswordScreen(),
    
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/home': (_) => const HomeScreen(), // شاشة الهوم بعد التعديلات
      },
    );
  }
}
