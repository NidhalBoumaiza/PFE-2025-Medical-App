import '../../domain/entities/medecin_entity.dart';
import './user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedecinModel extends UserModel {
  final String speciality;
  final String numLicence;
  final int appointmentDuration; // Duration in minutes for each appointment

  // New fields from MongoDB schema
  final List<Map<String, String>>? education;
  final List<Map<String, String>>? experience;
  final Map<String, List<String>>? availability;
  final double? averageRating;
  final int? totalRatings;
  final double? consultationFee;
  final List<String>? acceptedInsurance;

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
        json['speciality'] is String ? json['speciality'] as String : '';
    final String numLicence =
        json['numLicence'] is String ? json['numLicence'] as String : '';
    final int appointmentDuration =
        json['appointmentDuration'] is int
            ? json['appointmentDuration'] as int
            : 30;

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
    }

    int? verificationCode;
    if (json['verificationCode'] is int) {
      verificationCode = json['verificationCode'] as int;
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

    // Handle new fields
    Map<String, String?>? address;
    if (json['address'] is Map) {
      address = (json['address'] as Map).cast<String, String?>();
    }

    Map<String, dynamic>? location;
    if (json['location'] is Map) {
      location = (json['location'] as Map).cast<String, dynamic>();
    }

    String? profilePicture;
    if (json['profilePicture'] is String) {
      profilePicture = json['profilePicture'] as String;
    }

    bool? isOnline;
    if (json['isOnline'] is bool) {
      isOnline = json['isOnline'] as bool;
    }

    DateTime? lastActive;
    if (json['lastActive'] is String &&
        (json['lastActive'] as String).isNotEmpty) {
      try {
        lastActive = DateTime.parse(json['lastActive'] as String);
      } catch (_) {
        lastActive = null;
      }
    }

    String? oneSignalPlayerId;
    if (json['oneSignalPlayerId'] is String) {
      oneSignalPlayerId = json['oneSignalPlayerId'] as String;
    }

    String? passwordResetCode;
    if (json['passwordResetCode'] is String) {
      passwordResetCode = json['passwordResetCode'] as String;
    }

    DateTime? passwordResetExpires;
    if (json['passwordResetExpires'] is String &&
        (json['passwordResetExpires'] as String).isNotEmpty) {
      try {
        passwordResetExpires = DateTime.parse(
          json['passwordResetExpires'] as String,
        );
      } catch (_) {
        passwordResetExpires = null;
      }
    }

    String? refreshToken;
    if (json['refreshToken'] is String) {
      refreshToken = json['refreshToken'] as String;
    }

    // Handle doctor-specific fields
    List<Map<String, String>>? education;
    if (json['education'] is List) {
      education =
          (json['education'] as List)
              .map((item) => (item as Map).cast<String, String>())
              .toList();
    }

    List<Map<String, String>>? experience;
    if (json['experience'] is List) {
      experience =
          (json['experience'] as List)
              .map((item) => (item as Map).cast<String, String>())
              .toList();
    }

    Map<String, List<String>>? availability;
    if (json['availability'] is Map) {
      availability = {};
      (json['availability'] as Map).forEach((key, value) {
        if (value is List) {
          availability![key as String] = (value as List).cast<String>();
        }
      });
    }

    double? averageRating;
    if (json['averageRating'] is num) {
      averageRating = (json['averageRating'] as num).toDouble();
    }

    int? totalRatings;
    if (json['totalRatings'] is int) {
      totalRatings = json['totalRatings'] as int;
    }

    double? consultationFee;
    if (json['consultationFee'] is num) {
      consultationFee = (json['consultationFee'] as num).toDouble();
    }

    List<String>? acceptedInsurance;
    if (json['acceptedInsurance'] is List) {
      acceptedInsurance = (json['acceptedInsurance'] as List).cast<String>();
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
      appointmentDuration: appointmentDuration,
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
      education: education,
      experience: experience,
      availability: availability,
      averageRating: averageRating,
      totalRatings: totalRatings,
      consultationFee: consultationFee,
      acceptedInsurance: acceptedInsurance,
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

    // Add new fields
    if (education != null) {
      data['education'] = education;
    }
    if (experience != null) {
      data['experience'] = experience;
    }
    if (availability != null) {
      data['availability'] = availability;
    }
    if (averageRating != null) {
      data['averageRating'] = averageRating;
    }
    if (totalRatings != null) {
      data['totalRatings'] = totalRatings;
    }
    if (consultationFee != null) {
      data['consultationFee'] = consultationFee;
    }
    if (acceptedInsurance != null) {
      data['acceptedInsurance'] = acceptedInsurance;
    }

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
    String? fcmToken,
    String? speciality,
    String? numLicence,
    int? appointmentDuration,
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
      fcmToken: fcmToken ?? this.fcmToken,
      speciality: speciality ?? this.speciality,
      numLicence: numLicence ?? this.numLicence,
      appointmentDuration: appointmentDuration ?? this.appointmentDuration,
      address: address ?? this.address,
      location: location ?? this.location,
      profilePicture: profilePicture ?? this.profilePicture,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      oneSignalPlayerId: oneSignalPlayerId ?? this.oneSignalPlayerId,
      passwordResetCode: passwordResetCode ?? this.passwordResetCode,
      passwordResetExpires: passwordResetExpires ?? this.passwordResetExpires,
      refreshToken: refreshToken ?? this.refreshToken,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      availability: availability ?? this.availability,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      consultationFee: consultationFee ?? this.consultationFee,
      acceptedInsurance: acceptedInsurance ?? this.acceptedInsurance,
    );
  }
}
