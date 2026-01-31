import 'package:flutter/material.dart';
import 'package:krishi_mitra/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize notifications in background (non-blocking)
  _initializeNotifications();
  
  runApp(const KrishiMitraApp());
}

/// Initialize notifications without blocking app launch
Future<void> _initializeNotifications() async {
  try {
    // Initialize notification service
    await NotificationService.initialize();
    
    // Request notification permissions
    await NotificationService.requestPermissions();
    
    // Schedule daily weather notification
    await NotificationService.scheduleDailyNotification(
      id: 1001,
      title: '☁️ Weather Update',
      body: 'Check today\'s weather forecast',
      hour: 7,
      minute: 0,
      channel: NotificationChannel.weather,
    );
    
    print('✅ Notifications initialized successfully');
  } catch (e) {
    print('⚠️ Notification initialization failed: $e');
    // Don't crash the app if notifications fail
  }
}

class KrishiMitraApp extends StatelessWidget {
  const KrishiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrishiMitra',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          AppTheme.lightTheme.textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.displayLarge,
          ),
          displayMedium: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.displayMedium,
          ),
          displaySmall: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.displaySmall,
          ),
          headlineMedium: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.headlineMedium,
          ),
          headlineSmall: GoogleFonts.poppins(
            textStyle: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
        ),
      ),
      
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('mr'), // Marathi
      ],
      
      // Routing
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
