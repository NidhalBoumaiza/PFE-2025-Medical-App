import '../../domain/entities/medecin_entity.dart';
import './user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    String? fcmToken,
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
         fcmToken: fcmToken,
       );

  factory MedecinModel.fromJson(Map<String, dynamic> json) {
    // Handle potential null or wrong types for each field
    final String id = json['id'] is String ? json['id'] as String : '';
    final String name = json['name'] is String ? json['name'] as String : '';
    final String lastName =
        json['lastName'] is String ? json['lastName'] as String : '';
    final String email = json['email'] is String ? json['email'] as String : '';
    final String role =
        json['role'] is String ? json['role'] as String : 'medecin';
    final String gender =
        json['gender'] is String ? json['gender'] as String : 'Homme';
    final String phoneNumber =
        json['phoneNumber'] is String ? json['phoneNumber'] as String : '';
    final String speciality =
        json['speciality'] is String
            ? json['speciality'] as String
            : 'Généraliste';
    final String numLicence =
        json['numLicence'] is String ? json['numLicence'] as String : '';

    // Handle appointment duration with robust type checking
    int appointmentDuration = 30; // Default value
    if (json['appointmentDuration'] is int) {
      appointmentDuration = json['appointmentDuration'] as int;
    } else if (json['appointmentDuration'] is String &&
        (json['appointmentDuration'] as String).isNotEmpty) {
      try {
        appointmentDuration = int.parse(json['appointmentDuration'] as String);
      } catch (_) {
        // Keep default value if parsing fails
      }
    }

    // Handle nullable fields with proper type checking
    DateTime? dateOfBirth;
    if (json['dateOfBirth'] is String &&
        (json['dateOfBirth'] as String).isNotEmpty) {
      try {
        dateOfBirth = DateTime.parse(json['dateOfBirth'] as String);
      } catch (_) {
        dateOfBirth = null;
      }
    }

    bool? accountStatus;
    if (json['accountStatus'] is bool) {
      accountStatus = json['accountStatus'] as bool;
    } else if (json['accountStatus'] is String) {
      accountStatus = (json['accountStatus'] as String).toLowerCase() == 'true';
    } else {
      accountStatus = false;
    }

    int? verificationCode;
    if (json['verificationCode'] is int) {
      verificationCode = json['verificationCode'] as int;
    } else if (json['verificationCode'] is String &&
        (json['verificationCode'] as String).isNotEmpty) {
      try {
        verificationCode = int.parse(json['verificationCode'] as String);
      } catch (_) {
        verificationCode = null;
      }
    }

    DateTime? validationCodeExpiresAt;
    if (json['validationCodeExpiresAt'] is String &&
        (json['validationCodeExpiresAt'] as String).isNotEmpty) {
      try {
        validationCodeExpiresAt = DateTime.parse(
          json['validationCodeExpiresAt'] as String,
        );
      } catch (_) {
        validationCodeExpiresAt = null;
      }
    }

    String? fcmToken;
    if (json['fcmToken'] is String) {
      fcmToken = json['fcmToken'] as String;
    }

    return MedecinModel(
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
      accountStatus: accountStatus,
      verificationCode: verificationCode,
      validationCodeExpiresAt: validationCodeExpiresAt,
      fcmToken: fcmToken,
      appointmentDuration: appointmentDuration,
    );
  }

  /// Creates a valid MedecinModel from potentially corrupted document data
  /// This can help recover accounts when data is malformed
  static MedecinModel recoverFromCorruptDoc(
    Map<String, dynamic>? docData,
    String userId,
    String userEmail,
  ) {
    // Default values for required fields if missing or corrupted
    final Map<String, dynamic> safeData = {
      'id': userId,
      'name': '',
      'lastName': '',
      'email': userEmail,
      'role': 'medecin',
      'gender': 'Homme',
      'phoneNumber': '',
      'speciality': 'Généraliste',
      'numLicence': '',
      'appointmentDuration': 30,
      'accountStatus': true,
    };

    // Use existing data when available and valid
    if (docData != null) {
      if (docData['name'] is String) safeData['name'] = docData['name'];
      if (docData['lastName'] is String)
        safeData['lastName'] = docData['lastName'];
      if (docData['gender'] is String) safeData['gender'] = docData['gender'];
      if (docData['phoneNumber'] is String)
        safeData['phoneNumber'] = docData['phoneNumber'];
      if (docData['fcmToken'] is String)
        safeData['fcmToken'] = docData['fcmToken'];
      if (docData['speciality'] is String)
        safeData['speciality'] = docData['speciality'];
      if (docData['numLicence'] is String)
        safeData['numLicence'] = docData['numLicence'];

      // Handle appointment duration safely
      if (docData['appointmentDuration'] is int) {
        safeData['appointmentDuration'] = docData['appointmentDuration'];
      } else if (docData['appointmentDuration'] is String &&
          (docData['appointmentDuration'] as String).isNotEmpty) {
        try {
          safeData['appointmentDuration'] = int.parse(
            docData['appointmentDuration'] as String,
          );
        } catch (_) {
          // Keep default value if parsing fails
        }
      }

      // Handle dateOfBirth properly
      if (docData['dateOfBirth'] is String &&
          (docData['dateOfBirth'] as String).isNotEmpty) {
        try {
          DateTime dateOfBirth = DateTime.parse(
            docData['dateOfBirth'] as String,
          );
          safeData['dateOfBirth'] = dateOfBirth.toIso8601String();
        } catch (_) {
          // Invalid date format, don't add to safeData
        }
      } else if (docData['dateOfBirth'] is Timestamp) {
        try {
          DateTime dateOfBirth = (docData['dateOfBirth'] as Timestamp).toDate();
          safeData['dateOfBirth'] = dateOfBirth.toIso8601String();
        } catch (_) {
          // Invalid timestamp, don't add to safeData
        }
      }
    }

    return MedecinModel.fromJson(safeData);
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
    String? fcmToken,
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
      validationCodeExpiresAt:
          validationCodeExpiresAt ?? this.validationCodeExpiresAt,
      speciality: speciality ?? this.speciality,
      numLicence: numLicence ?? this.numLicence,
      appointmentDuration: appointmentDuration ?? this.appointmentDuration,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
