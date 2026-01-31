class CropModel {
  final String id;
  final String userId;
  final String cropName;
  final DateTime sowingDate;
  final double landArea; // in acres
  final String irrigationType;
  final String? cropVariety;
  final String currentStage;
  final String healthStatus;
  final DateTime? lastUpdate;
  final DateTime createdAt;
  
  CropModel({
    required this.id,
    required this.userId,
    required this.cropName,
    required this.sowingDate,
    required this.landArea,
    required this.irrigationType,
    this.cropVariety,
    this.currentStage = 'SOWING',
    this.healthStatus = 'GOOD',
    this.lastUpdate,
    required this.createdAt,
  });
  
  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      cropName: json['cropName'] ?? json['crop_name'] ?? '',
      sowingDate: json['sowingDate'] != null 
          ? DateTime.parse(json['sowingDate']) 
          : DateTime.now(),
      landArea: (json['landArea'] ?? json['land_area'] ?? 0.0).toDouble(),
      irrigationType: json['irrigationType'] ?? json['irrigation_type'] ?? 'Other',
      cropVariety: json['cropVariety'] ?? json['crop_variety'],
      currentStage: json['currentStage'] ?? json['current_stage'] ?? 'SOWING',
      healthStatus: json['healthStatus'] ?? json['health_status'] ?? 'GOOD',
      lastUpdate: json['lastUpdate'] != null 
          ? DateTime.parse(json['lastUpdate']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cropName': cropName,
      'sowingDate': sowingDate.toIso8601String(),
      'landArea': landArea,
      'irrigationType': irrigationType,
      'cropVariety': cropVariety,
      'currentStage': currentStage,
      'healthStatus': healthStatus,
      'lastUpdate': lastUpdate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // Helper method to get days since sowing
  int getDaysSinceSowing() {
    return DateTime.now().difference(sowingDate).inDays;
  }
}
