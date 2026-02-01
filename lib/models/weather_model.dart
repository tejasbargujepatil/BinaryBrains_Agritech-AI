class WeatherModel {
  final double temperature;
  final double humidity;
  final double rainProbability;
  final double? rainfall;
  final double? windSpeed;
  final String condition; // sunny, rainy, cloudy, etc.
  final String? iconCode;
  final String location; // Added location field
  final DateTime timestamp;
  
  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.rainProbability,
    this.rainfall,
    this.windSpeed,
    required this.condition,
    this.iconCode,
    required this.location,
    required this.timestamp,
  });
  
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] ?? json['temp'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      rainProbability: (json['rainProbability'] ?? json['rain_probability'] ?? 0.0).toDouble(),
      rainfall: json['rainfall'] != null ? json['rainfall'].toDouble() : null,
      windSpeed: json['windSpeed'] != null ? json['windSpeed'].toDouble() : null,
      condition: json['condition'] ?? 'unknown',
      iconCode: json['iconCode'] ?? json['icon'],
      location: json['location'] ?? json['name'] ?? 'Unknown',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'rainProbability': rainProbability,
      'rainfall': rainfall,
      'windSpeed': windSpeed,
      'condition': condition,
      'iconCode': iconCode,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class WeatherForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double rainProbability;
  final String condition;
  final String? iconCode;
  
  WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainProbability,
    required this.condition,
    this.iconCode,
  });
  
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date']),
      maxTemp: (json['maxTemp'] ?? json['max_temp'] ?? 0.0).toDouble(),
      minTemp: (json['minTemp'] ?? json['min_temp'] ?? 0.0).toDouble(),
      rainProbability: (json['rainProbability'] ?? json['rain_probability'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? 'unknown',
      iconCode: json['iconCode'] ?? json['icon'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'rainProbability': rainProbability,
      'condition': condition,
      'iconCode': iconCode,
    };
  }
}
