class SoilModel {
  final String soilType;
  final dynamic moisture; // String ("Moderate") or double
  final dynamic nitrogen; // String ("0.15%") or double
  final dynamic phosphorus; // String ("Estimated") or double
  final dynamic potassium; // String ("Estimated") or double
  final double? ph;
  final String? organicCarbon; // Added
  final DateTime timestamp;
  
  SoilModel({
    required this.soilType,
    required this.moisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    this.ph,
    this.organicCarbon,
    required this.timestamp,
  });
  
  factory SoilModel.fromJson(Map<String, dynamic> json) {
    return SoilModel(
      soilType: json['soilType'] ?? json['soil_type'] ?? 'Unknown',
      moisture: json['moisture'] ?? 0.0,
      nitrogen: json['nitrogen'] ?? json['n'] ?? 0.0,
      phosphorus: json['phosphorus'] ?? json['p'] ?? 0.0,
      potassium: json['potassium'] ?? json['k'] ?? 0.0,
      ph: json['ph'] != null ? json['ph'].toDouble() : null,
      organicCarbon: json['organicCarbon'],
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
      'organicCarbon': organicCarbon,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  // Helper methods to assess NPK levels (Graceful handling for Strings)
  String getNitrogenLevel() {
    if (nitrogen is String) return nitrogen.toString(); 
    final val = (nitrogen as num).toDouble();
    if (val >= 300) return 'HIGH';
    if (val >= 150) return 'MEDIUM';
    return 'LOW';
  }
  
  String getPhosphorusLevel() {
    if (phosphorus is String) return phosphorus.toString();
    final val = (phosphorus as num).toDouble();
    if (val >= 25) return 'HIGH';
    if (val >= 10) return 'MEDIUM';
    return 'LOW';
  }
  
  String getPotassiumLevel() {
    if (potassium is String) return potassium.toString();
    final val = (potassium as num).toDouble();
    if (val >= 300) return 'HIGH';
    if (val >= 150) return 'MEDIUM';
    return 'LOW';
  }
}
