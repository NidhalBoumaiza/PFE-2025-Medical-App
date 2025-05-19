import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id;
  final String name;
  final String lastName;
  final String email;
  final String role;
  final String gender;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final bool? accountStatus;
  final int? verificationCode;
  final DateTime? validationCodeExpiresAt;
  final String? fcmToken;
  final String? token; // Added token field needed for SocketService

  // New fields to match MongoDB schema
  final Map<String, String?>? address;
  final Map<String, dynamic>? location;
  final String? profilePicture;
  final bool? isOnline;
  final DateTime? lastActive;
  final String? oneSignalPlayerId;
  final String? passwordResetCode;
  final DateTime? passwordResetExpires;
  final String? refreshToken;

  UserEntity({
    this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
    required this.gender,
    required this.phoneNumber,
    this.dateOfBirth,
    this.accountStatus,
    this.verificationCode,
    this.validationCodeExpiresAt,
    this.fcmToken,
    this.token,
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
    token,
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
