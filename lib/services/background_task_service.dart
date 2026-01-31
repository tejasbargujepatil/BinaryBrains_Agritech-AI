import 'package:workmanager/workmanager.dart';
import '../config/app_config.dart';
import 'notification_service.dart';
import 'weather_service.dart';
import 'weather_forecast_service.dart';
import 'crop_service.dart';

/// Background task callback - runs in isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case BackgroundTaskService.weatherUpdateTask:
          await _handleWeatherUpdate();
          break;
        case BackgroundTaskService.forecastTask:
          await _handleDailyForecast();
          break;
        case BackgroundTaskService.irrigationCheckTask:
          await _handleIrrigationCheck();
          break;
        case BackgroundTaskService.fertilizationCheckTask:
          await _handleFertilizationCheck();
          break;
        default:
          print('Unknown task: $task');
      }
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

/// Handle weather update check
Future<void> _handleWeatherUpdate() async {
  await NotificationService.initialize();
  
  final result = await WeatherService.getUserWeather();
  if (result['success']) {
    final weather = result['weather'];
    
    // Check for extreme conditions
    if (weather.temperature > 40) {
      await NotificationService.showWeatherAlert(
        title: 'Extreme Heat Alert',
        body: 'Temperature is ${weather.temperature}°C. Ensure adequate irrigation.',
      );
    } else if (weather.temperature < 10) {
      await NotificationService.showWeatherAlert(
        title: 'Cold Weather Alert',
        body: 'Temperature is ${weather.temperature}°C. Protect sensitive crops.',
      );
    }
    
    // Check for high rain probability
    if (weather.rainProbability > 70) {
      await NotificationService.showWeatherAlert(
        title: 'Rain Expected',
        body: '${weather.rainProbability}% chance of rain. Plan accordingly.',
      );
    }
  }
}

/// Handle daily forecast notification
Future<void> _handleDailyForecast() async {
  await NotificationService.initialize();
  
  final forecast = await WeatherForecastService.get5DayForecast();
  if (forecast.isNotEmpty) {
    final today = forecast.first;
    await NotificationService.showWeatherAlert(
      title: '5-Day Weather Forecast',
      body: 'Today: ${today.condition}, ${today.tempMin}-${today.tempMax}°C. Tap for details.',
      payload: 'weather_forecast',
    );
  }
}

/// Handle irrigation schedule check
Future<void> _handleIrrigationCheck() async {
  await NotificationService.initialize();
  
  // TODO: Check irrigation schedules from crops
  final result = await CropService.getCrops();
  if (result['success']) {
    // Example logic - implement based on crop model
    // Check if any crops need irrigation today
  }
}

/// Handle fertilization schedule check
Future<void> _handleFertilizationCheck() async {
  await NotificationService.initialize();
  
  // TODO: Check fertilization schedules from crops
  final result = await CropService.getCrops();
  if (result['success']) {
    // Example logic - implement based on crop model
    // Check if any crops need fertilization this week
  }
}

class BackgroundTaskService {
  static const weatherUpdateTask = 'weatherUpdateTask';
  static const forecastTask = 'dailyForecastTask';
  static const irrigationCheckTask = 'irrigationCheckTask';
  static const fertilizationCheckTask = 'fertilizationCheckTask';

  /// Initialize background tasks
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: AppConfig.isDemoMode,
    );
  }

  /// Register all background tasks
  static Future<void> registerTasks() async {
    // Weather updates every 6 hours
    await Workmanager().registerPeriodicTask(
      weatherUpdateTask,
      weatherUpdateTask,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    // Daily forecast at 7 AM
    await Workmanager().registerPeriodicTask(
      forecastTask,
      forecastTask,
      frequency: const Duration(days: 1),
      initialDelay: _calculateInitialDelay(7, 0),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    // Irrigation check daily at 6 AM
    await Workmanager().registerPeriodicTask(
      irrigationCheckTask,
      irrigationCheckTask,
      frequency: const Duration(days: 1),
      initialDelay: _calculateInitialDelay(6, 0),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    // Fertilization check weekly
    await Workmanager().registerPeriodicTask(
      fertilizationCheckTask,
      fertilizationCheckTask,
      frequency: const Duration(days: 7),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Calculate initial delay to target time
  static Duration _calculateInitialDelay(int hour, int minute) {
    final now = DateTime.now();
    var targetTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (targetTime.isBefore(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }
    
    return targetTime.difference(now);
  }

  /// Cancel all tasks
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
