class UserModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String? email;
  final LocationData location;
  final DateTime createdAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.email,
    required this.location,
    required this.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? json['mobile'] ?? '',
      email: json['email'],
      location: LocationData.fromJson(json['location'] ?? {}),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'location': location.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  
  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
  });
  
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lon'] ?? 0.0).toDouble(),
      address: json['address'],
      city: json['city'],
      state: json['state'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
    };
  }
}
