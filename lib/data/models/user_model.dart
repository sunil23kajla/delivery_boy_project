class UserModel {
  final int? id;
  final String? name;
  final String email;
  final String mobileNumber;
  final String? profilePhoto;
  final String? token;
  final String? address;

  UserModel({
    this.id,
    this.name,
    required this.email,
    required this.mobileNumber,
    this.profilePhoto,
    this.token,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      profilePhoto: json['profile_photo'],
      token: json['token'],
      address: json['address'],
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
    };
  }
}
