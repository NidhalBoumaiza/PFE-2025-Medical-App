import '../../domain/entities/medecin_entity.dart';
import './user_model.dart';

class MedecinModel extends UserModel {
  final String speciality;
  final String numLicence;
  final int appointmentDuration; // Duration in minutes for each appointment

  MedecinModel({
    String? id,
    required String name,
    required String lastName,
    required String email,
    required String role,
    required String gender,
    required String phoneNumber,
    DateTime? dateOfBirth,
    bool? accountStatus,
    int? verificationCode,
    required this.speciality,
    required this.numLicence,
    this.appointmentDuration = 30, // Default 30 minutes
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

  factory MedecinModel.fromJson(Map<String, dynamic> json) {
    return MedecinModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      gender: json['gender'] as String,
      phoneNumber: json['phoneNumber'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      speciality: json['speciality'] as String,
      numLicence: json['numLicence'] as String,
      appointmentDuration: json['appointmentDuration'] != null
          ? json['appointmentDuration'] as int
          : 30, // Default 30 minutes
      accountStatus: json['accountStatus'] as bool?,
      verificationCode: json['verificationCode'] as int?,
      validationCodeExpiresAt: json['validationCodeExpiresAt'] != null
          ? DateTime.parse(json['validationCodeExpiresAt'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['speciality'] = speciality;
    data['numLicence'] = numLicence;
    data['appointmentDuration'] = appointmentDuration;

    return data;
  }

  MedecinEntity toEntity() {
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
  MedecinModel copyWith({
    String? id,
    String? name,
    String? lastName,
    String? email,
    String? role,
    String? gender,
    String? phoneNumber,
    DateTime? dateOfBirth,
    bool? accountStatus,
    int? verificationCode,
    DateTime? validationCodeExpiresAt,
    String? speciality,
    String? numLicence,
    int? appointmentDuration,
  }) {
    return MedecinModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      accountStatus: accountStatus ?? this.accountStatus,
      verificationCode: verificationCode ?? this.verificationCode,
      validationCodeExpiresAt: validationCodeExpiresAt ?? this.validationCodeExpiresAt,
      speciality: speciality ?? this.speciality,
      numLicence: numLicence ?? this.numLicence,
      appointmentDuration: appointmentDuration ?? this.appointmentDuration,
    );
  }
}