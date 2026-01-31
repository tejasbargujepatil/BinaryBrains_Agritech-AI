/// Application configuration for demo/production mode
class AppConfig {
  // Set to true to use dummy data (for testing UI without backend)
  // Set to false to use real API calls
  static const bool isDemoMode = true;
  
  // Demo user credentials
  static const String demoMobileNumber = '7972720204';
  static const String demoPassword = '12345678';
  static const String demoUserName = 'Demo Farmer';
  
  // Demo location
  static const double demoLatitude = 18.5204;
  static const double demoLongitude = 73.8567;
  static const String demoAddress = 'Pune, Maharashtra, India';
}
