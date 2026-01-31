class SoilModel {
  final String soilType;
  final double moisture; // percentage
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double? ph;
  final DateTime timestamp;
  
  SoilModel({
    required this.soilType,
    required this.moisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    this.ph,
    required this.timestamp,
  });
  
  factory SoilModel.fromJson(Map<String, dynamic> json) {
    return SoilModel(
      soilType: json['soilType'] ?? json['soil_type'] ?? 'Unknown',
      moisture: (json['moisture'] ?? 0.0).toDouble(),
      nitrogen: (json['nitrogen'] ?? json['n'] ?? 0.0).toDouble(),
      phosphorus: (json['phosphorus'] ?? json['p'] ?? 0.0).toDouble(),
      potassium: (json['potassium'] ?? json['k'] ?? 0.0).toDouble(),
      ph: json['ph'] != null ? json['ph'].toDouble() : null,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'soilType': soilType,
      'moisture': moisture,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  // Helper methods to assess NPK levels
  String getNitrogenLevel() {
    if (nitrogen >= 300) return 'HIGH';
    if (nitrogen >= 150) return 'MEDIUM';
    return 'LOW';
  }
  
  String getPhosphorusLevel() {
    if (phosphorus >= 25) return 'HIGH';
    if (phosphorus >= 10) return 'MEDIUM';
    return 'LOW';
  }
  
  String getPotassiumLevel() {
    if (potassium >= 300) return 'HIGH';
    if (potassium >= 150) return 'MEDIUM';
    return 'LOW';
  }
}
