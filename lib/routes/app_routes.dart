import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import'../screens/home/new_home_screen.dart';
import '../screens/main_app_scaffold.dart';
import '../screens/crops/add_crop_screen.dart';
import '../screens/crops/crops_list_screen.dart';
import '../screens/crops/crop_agent_dashboard.dart';
import '../screens/weather/full_weather_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';

/// Centralized route management
class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addCrop = '/add-crop';
  static const String cropsList = '/crops-list';
  static const String cropAgentDashboard = '/crop-agent-dashboard';
  static const String fullWeather = '/full-weather';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainAppScaffold());
        
      case '/add-crop':
        return MaterialPageRoute(builder: (_) => const AddCropScreen());
        
      case '/crops-list':
        return MaterialPageRoute(builder: (_) => const CropsListScreen());
        
      case '/crop-agent-dashboard':
        final cropId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CropAgentDashboard(cropId: cropId),
        );
        
      case '/full-weather':
        return MaterialPageRoute(builder: (_) => const FullWeatherScreen());
        
      case '/alerts':
        return MaterialPageRoute(builder: (_) => const AlertsScreen());
        
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
        
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  // Navigation Helpers
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }
  
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }
  
  static void navigateToCropDashboard(BuildContext context, String cropId) {
    Navigator.pushNamed(context, cropAgentDashboard, arguments: cropId);
  }
}
