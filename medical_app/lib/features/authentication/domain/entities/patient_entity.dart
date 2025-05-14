import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';

class PatientEntity extends UserEntity {
  final String antecedent;

  PatientEntity({
    String? id,
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    required this.antecedent,
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

  factory PatientEntity.create({
    String? id,
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    required String antecedent,
    bool? accountStatus,
    int? verificationCode,
    DateTime? validationCodeExpiresAt,
  }) {
    return PatientEntity(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      role: role,
      gender: gender,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      antecedent: antecedent,
      accountStatus: accountStatus,
      verificationCode: verificationCode,
      validationCodeExpiresAt: validationCodeExpiresAt,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    antecedent,
  ];
}
