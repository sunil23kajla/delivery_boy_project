class UserModel {
  final int? id;
  final String? name;
  final String email;
  final String mobileNumber;
  final String? profilePhoto;
  final String? token;
  final String? address;
  final bool isQuickFlow;
  final String? orderType;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? city;

  UserModel({
    this.id,
    this.name,
    required this.email,
    required this.mobileNumber,
    this.profilePhoto,
    this.token,
    this.address,
    this.isQuickFlow = false,
    this.orderType,
    this.vehicleType,
    this.vehicleNumber,
    this.city,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json.containsKey('delivery_man')
        ? json['delivery_man'] as Map<String, dynamic>
        : json;
    
    final orderType = userData['order_type']?.toString();
    final isQuickFlow = (orderType == 'express') || (userData['is_quick_flow'] ?? false);

    // Extract city name if nested
    String? cityName;
    if (userData['city'] is Map) {
      cityName = userData['city']['name']?.toString();
    } else {
      cityName = userData['city']?.toString();
    }

    return UserModel(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'] ?? '',
      mobileNumber: userData['mobile_number'] ?? '',
      profilePhoto: userData['profile_photo'],
      token: json['token'] ?? userData['token'],
      address: userData['address'],
      isQuickFlow: isQuickFlow,
      orderType: orderType,
      vehicleType: userData['vehicle_type']?.toString(),
      vehicleNumber: userData['vehicle_number']?.toString(),
      city: cityName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'profile_photo': profilePhoto,
      'token': token,
      'address': address,
      'is_quick_flow': isQuickFlow,
      'order_type': orderType,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'city': city,
    };
  }
}
