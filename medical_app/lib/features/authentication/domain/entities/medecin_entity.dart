import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';

class MedecinEntity extends UserEntity {
  final String? speciality;
  final String? numLicence;
  final int appointmentDuration; // Duration in minutes for each appointment (default 30 minutes)
  
  // New fields from MongoDB schema
  final List<Map<String, String>>? education; // List of education history (institution, degree, year)
  final List<Map<String, String>>? experience; // List of professional experience (position, organization, years)
  final Map<String, List<String>>? availability; // Map of day to available time slots
  final double? averageRating; // Average rating from patients
  final int? totalRatings; // Total number of ratings received
  final double? consultationFee; // Fee charged for consultation
  final List<String>? acceptedInsurance; // List of accepted insurance providers

  MedecinEntity({
    String? id,
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    this.speciality,
    this.numLicence = '',
    this.appointmentDuration = 30, // Default 30 minutes
    bool? accountStatus,
    int? verificationCode,
    DateTime? validationCodeExpiresAt,
    Map<String, String?>? address,
    Map<String, dynamic>? location,
    String? profilePicture,
    bool? isOnline,
    DateTime? lastActive,
    String? oneSignalPlayerId,
    String? passwordResetCode,
    DateTime? passwordResetExpires,
    String? refreshToken,
    this.education,
    this.experience,
    this.availability,
    this.averageRating,
    this.totalRatings,
    this.consultationFee,
    this.acceptedInsurance,
  }) : super(
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

  factory MedecinEntity.create({
    String? id,
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? speciality,
    String? numLicence = '',
    int appointmentDuration = 30, // Default 30 minutes
    bool? accountStatus,
    int? verificationCode,
    DateTime? validationCodeExpiresAt,
    Map<String, String?>? address,
    Map<String, dynamic>? location,
    String? profilePicture,
    bool? isOnline,
    DateTime? lastActive,
    String? oneSignalPlayerId,
    String? passwordResetCode,
    DateTime? passwordResetExpires,
    String? refreshToken,
    List<Map<String, String>>? education,
    List<Map<String, String>>? experience,
    Map<String, List<String>>? availability,
    double? averageRating,
    int? totalRatings,
    double? consultationFee,
    List<String>? acceptedInsurance,
  }) {
    return MedecinEntity(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      role: role,
      gender: gender,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      speciality: speciality,
      numLicence: numLicence,
      appointmentDuration: appointmentDuration,
      accountStatus: accountStatus,
      verificationCode: verificationCode,
      validationCodeExpiresAt: validationCodeExpiresAt,
      address: address,
      location: location,
      profilePicture: profilePicture,
      isOnline: isOnline,
      lastActive: lastActive,
      oneSignalPlayerId: oneSignalPlayerId,
      passwordResetCode: passwordResetCode,
      passwordResetExpires: passwordResetExpires,
      refreshToken: refreshToken,
      education: education,
      experience: experience,
      availability: availability,
      averageRating: averageRating,
      totalRatings: totalRatings,
      consultationFee: consultationFee,
      acceptedInsurance: acceptedInsurance,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    speciality,
    numLicence,
    appointmentDuration,
    education,
    experience,
    availability,
    averageRating,
    totalRatings,
    consultationFee,
    acceptedInsurance,
  ];
}