class WeatherForecastModel {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int rainProbability;
  final String description;

  WeatherForecastModel({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.description,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return WeatherForecastModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      condition: json['weather'][0]['main'] ?? 'Clear',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      rainProbability: ((json['pop'] ?? 0.0) * 100).toInt(),
      description: json['weather'][0]['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tempMin': tempMin,
      'tempMax': tempMax,
      'condition': condition,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rainProbability': rainProbability,
      'description': description,
    };
  }

  /// Get weather icon based on condition
  String get weatherIcon {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}

/// Daily forecast aggregating hourly data
class DailyForecastModel {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String condition;
  final int rainProbability;
  final int humidity;
  final double windSpeed;
  final List<WeatherForecastModel> hourlyData;

  DailyForecastModel({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.rainProbability,
    required this.humidity,
    required this.windSpeed,
    required this.hourlyData,
  });

  String get weatherIcon {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  String get dayName {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return 'Tomorrow';
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }
  }
}
