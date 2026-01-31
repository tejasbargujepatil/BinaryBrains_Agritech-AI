/// App-wide constants
class AppConstants {
  // App Information
  static const String appName = 'KrishiMitra';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your AI Agriculture Partner';
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyLanguage = 'selected_language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const int requestTimeout = 30; // seconds
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Image Quality
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  
  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
  ];
  
  // Health Status
  static const String healthExcellent = 'EXCELLENT';
  static const String healthGood = 'GOOD';
  static const String healthFair = 'FAIR';
  static const String healthPoor = 'POOR';
  
  // Crop Stages
  static const String stageSowing = 'SOWING';
  static const String stageGermination = 'GERMINATION';
  static const String stageVegetative = 'VEGETATIVE';
  static const String stageFlowering = 'FLOWERING';
  static const String stageFruiting = 'FRUITING';
  static const String stageMaturity = 'MATURITY';
  static const String stageHarvesting = 'HARVESTING';
  
  // Irrigation Types
  static const List<String> irrigationTypes = [
    'Drip Irrigation',
    'Sprinkler',
    'Flood Irrigation',
    'Rainfed',
    'Other',
  ];
  
  // Alert Types
  static const String alertDisease = 'DISEASE';
  static const String alertWeather = 'WEATHER';
  static const String alertHarvest = 'HARVEST';
  static const String alertPhoto = 'PHOTO_REMINDER';
  static const String alertGeneral = 'GENERAL';
  
  // Alert Severity
  static const String severityLow = 'LOW';
  static const String severityMedium = 'MEDIUM';
  static const String severityHigh = 'HIGH';
  static const String severityCritical = 'CRITICAL';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
  static const String timeFormat = 'hh:mm a';
  
  // Error Messages (These are keys, actual messages come from localization)
  static const String errorNetworkTitle = 'network_error';
  static const String errorServerTitle = 'server_error';
  static const String errorAuthTitle = 'auth_error';
  static const String errorUnknownTitle = 'unknown_error';
}
