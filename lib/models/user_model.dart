class UserModel {
  final String id;
  final String email;
  final String userType;
  final bool isServiceProvider;
  final bool isApproved;
  final String? name;
  final String? phoneNumber;
  final String? profileImage;
  final String? address;

  UserModel({
    required this.id,
    required this.email,
    required this.userType,
    this.isServiceProvider = false,
    this.isApproved = false,
    this.name,
    this.phoneNumber,
    this.profileImage,
    this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] ?? map['id'] ?? '',
      email: map['email'] ?? '',
      userType: map['userType'] ?? 'customer',
      isServiceProvider: map['isServiceProvider'] ?? false,
      isApproved: map['isApproved'] ?? false,
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      profileImage: map['profileImage'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'userType': userType,
      'isServiceProvider': isServiceProvider,
      'isApproved': isApproved,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'address': address,
    };
  }

  bool isValid() {
    return id.isNotEmpty && email.isNotEmpty && userType.isNotEmpty;
  }

  bool canAccessBarberFeatures() {
    return isServiceProvider && isApproved;
  }
}