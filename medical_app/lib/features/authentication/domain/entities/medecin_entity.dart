import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';

class MedecinEntity extends UserEntity {
  final String? speciality;
  final String? numLicence;
  final int appointmentDuration; // Duration in minutes for each appointment (default 30 minutes)

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
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    speciality,
    numLicence,
    appointmentDuration,
  ];
}