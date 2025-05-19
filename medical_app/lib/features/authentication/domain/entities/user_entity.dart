import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id; // id is optional
  final String name;
  final String lastName;
  final String email;
  final String role;
  final String gender;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final bool? accountStatus; // accountStatus is optional
  final int? verificationCode; // verificationCode is optional
  final DateTime?
  validationCodeExpiresAt; // validationCodeExpiresAt is optional
  final String? fcmToken; // fcmToken is optional

  // New fields to match MongoDB schema
  final Map<String, String?>? address; // street, city, state, zipCode, country
  final Map<String, dynamic>?
  location; // type and coordinates for geospatial queries
  final String? profilePicture;
  final bool? isOnline;
  final DateTime? lastActive;
  final String? oneSignalPlayerId;
  final String? passwordResetCode;
  final DateTime? passwordResetExpires;
  final String? refreshToken;

  UserEntity({
    this.id, // id is not required
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
    required this.gender,
    required this.phoneNumber,
    this.dateOfBirth,
    this.accountStatus, // accountStatus is not required
    this.verificationCode, // verificationCode is not required
    this.validationCodeExpiresAt, // validationCodeExpiresAt is not required
    this.fcmToken, // fcmToken is not required
    this.address,
    this.location,
    this.profilePicture,
    this.isOnline,
    this.lastActive,
    this.oneSignalPlayerId,
    this.passwordResetCode,
    this.passwordResetExpires,
    this.refreshToken,
  });

  factory UserEntity.create({
    String? id, // id is optional
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    bool? accountStatus, // accountStatus is optional
    int? verificationCode,
    DateTime? validationCodeExpiresAt, // validationCodeExpiresAt is optional
    String? fcmToken, // fcmToken is optional
    Map<String, String?>? address,
    Map<String, dynamic>? location,
    String? profilePicture,
    bool? isOnline,
    DateTime? lastActive,
    String? oneSignalPlayerId,
    String? passwordResetCode,
    DateTime? passwordResetExpires,
    String? refreshToken,
  }) {
    return UserEntity(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      role: role,
      gender: gender,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      accountStatus: accountStatus,
      verificationCode: verificationCode,
      validationCodeExpiresAt: validationCodeExpiresAt,
      fcmToken: fcmToken,
      address: address,
      location: location,
      profilePicture: profilePicture,
      isOnline: isOnline,
      lastActive: lastActive,
      oneSignalPlayerId: oneSignalPlayerId,
      passwordResetCode: passwordResetCode,
      passwordResetExpires: passwordResetExpires,
      refreshToken: refreshToken,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    lastName,
    email,
    role,
    gender,
    phoneNumber,
    dateOfBirth,
    accountStatus,
    verificationCode,
    validationCodeExpiresAt,
    fcmToken,
    address,
    location,
    profilePicture,
    isOnline,
    lastActive,
    oneSignalPlayerId,
    passwordResetCode,
    passwordResetExpires,
    refreshToken,
  ];
}
