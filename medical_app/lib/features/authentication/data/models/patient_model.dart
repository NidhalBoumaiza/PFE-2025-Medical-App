import '../../domain/entities/patient_entity.dart';
import './user_model.dart';

class PatientModel extends UserModel {
  final String antecedent;

  PatientModel({
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
    required this.antecedent,
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

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
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
      antecedent: json['antecedent'] as String,
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
    data['antecedent'] = antecedent;
    return data;
  }

  PatientEntity toEntity() {
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
  PatientModel copyWith({
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
    String? antecedent,
  }) {
    return PatientModel(
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
      antecedent: antecedent ?? this.antecedent,
    );
  }
}