class AlertModel {
  final String id;
  final String userId;
  final String type; // DISEASE, WEATHER, HARVEST, PHOTO_REMINDER, GENERAL
  final String severity; // LOW, MEDIUM, HIGH, CRITICAL
  final String title;
  final String message;
  final String? cropId;
  final bool isRead;
  final DateTime createdAt;
  
  AlertModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.cropId,
    this.isRead = false,
    required this.createdAt,
  });
  
  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      type: json['type'] ?? 'GENERAL',
      severity: json['severity'] ?? 'MEDIUM',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      cropId: json['cropId'] ?? json['crop_id'],
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'severity': severity,
      'title': title,
      'message': message,
      'cropId': cropId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
