class ApiEndpoints {
  static const String baseUrl = 'https://lokit-production.up.railway.app';
  static const String search  = '/products/search';

  // Auth
  static const String login            = '/auth/login';
  static const String register         = '/auth/register';
  static const String forgotPassword   = '/auth/forgot-password';
  static const String verifyResetCode  = '/auth/verify-reset-code';
  static const String resetPassword    = '/auth/reset-password';
}