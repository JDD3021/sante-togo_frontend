/// Centralized constants for SANTÉ+ TOGO
class AppConstants {
  AppConstants._();

  // Spacing
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 28.0;
  static const double radiusPill = 999.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Animation durations
  static const int animationFast = 150;
  static const int animationNormal = 300;
  static const int animationSlow = 500;

  // Touch target minimum size
  static const double touchTargetMin = 48.0;

  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String apiVersion = '/api/v1';
  static const String patientsEndpoint = '$apiVersion/patients';
  static const String consultationsEndpoint = '$apiVersion/consultations';
  static const String queueEndpoint = '$apiVersion/queue';
}
