import '../../domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends UserEntity {
  final String? fcmToken;

  UserModel({
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
    DateTime? validationCodeExpiresAt,
    this.fcmToken,
    Map<String, String?>? address,
    Map<String, dynamic>? location,
    String? profilePicture,
    bool? isOnline,
    DateTime? lastActive,
    String? oneSignalPlayerId,
    String? passwordResetCode,
    DateTime? passwordResetExpires,
    String? refreshToken,
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle potential null or wrong types for each field
    final String id = json['id'] is String ? json['id'] as String : '';
    final String name = json['name'] is String ? json['name'] as String : '';
    final String lastName =
        json['lastName'] is String ? json['lastName'] as String : '';
    final String email = json['email'] is String ? json['email'] as String : '';
    final String role =
        json['role'] is String ? json['role'] as String : 'user';
    final String gender =
        json['gender'] is String ? json['gender'] as String : 'Homme';
    final String phoneNumber =
        json['phoneNumber'] is String ? json['phoneNumber'] as String : '';

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

    return UserModel(
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

  /// Creates a valid UserModel from potentially corrupted document data
  /// This can help recover accounts when data is malformed
  static UserModel recoverFromCorruptDoc(
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
      'role': 'user',
      'gender': 'Homme',
      'phoneNumber': '',
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
      if (docData['role'] is String) safeData['role'] = docData['role'];
      if (docData['fcmToken'] is String)
        safeData['fcmToken'] = docData['fcmToken'];

      // Handle new fields
      if (docData['address'] is Map) safeData['address'] = docData['address'];
      if (docData['location'] is Map)
        safeData['location'] = docData['location'];
      if (docData['profilePicture'] is String)
        safeData['profilePicture'] = docData['profilePicture'];
      if (docData['isOnline'] is bool)
        safeData['isOnline'] = docData['isOnline'];
      if (docData['oneSignalPlayerId'] is String)
        safeData['oneSignalPlayerId'] = docData['oneSignalPlayerId'];
      if (docData['passwordResetCode'] is String)
        safeData['passwordResetCode'] = docData['passwordResetCode'];
      if (docData['refreshToken'] is String)
        safeData['refreshToken'] = docData['refreshToken'];

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

      // Handle lastActive
      if (docData['lastActive'] is String &&
          (docData['lastActive'] as String).isNotEmpty) {
        try {
          DateTime lastActive = DateTime.parse(docData['lastActive'] as String);
          safeData['lastActive'] = lastActive.toIso8601String();
        } catch (_) {
          // Invalid date format, don't add to safeData
        }
      } else if (docData['lastActive'] is Timestamp) {
        try {
          DateTime lastActive = (docData['lastActive'] as Timestamp).toDate();
          safeData['lastActive'] = lastActive.toIso8601String();
        } catch (_) {
          // Invalid timestamp, don't add to safeData
        }
      }

      // Handle passwordResetExpires
      if (docData['passwordResetExpires'] is String &&
          (docData['passwordResetExpires'] as String).isNotEmpty) {
        try {
          DateTime passwordResetExpires = DateTime.parse(
            docData['passwordResetExpires'] as String,
          );
          safeData['passwordResetExpires'] =
              passwordResetExpires.toIso8601String();
        } catch (_) {
          // Invalid date format, don't add to safeData
        }
      } else if (docData['passwordResetExpires'] is Timestamp) {
        try {
          DateTime passwordResetExpires =
              (docData['passwordResetExpires'] as Timestamp).toDate();
          safeData['passwordResetExpires'] =
              passwordResetExpires.toIso8601String();
        } catch (_) {
          // Invalid timestamp, don't add to safeData
        }
      }
    }

    return UserModel.fromJson(safeData);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'lastName': lastName,
      'email': email,
      'role': role,
      'gender': gender,
      'phoneNumber': phoneNumber,
    };
    if (id != null) {
      data['id'] = id;
    }
    if (dateOfBirth != null) {
      data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    }
    if (accountStatus != null) {
      data['accountStatus'] = accountStatus;
    }
    if (verificationCode != null) {
      data['verificationCode'] = verificationCode;
    }
    if (validationCodeExpiresAt != null) {
      data['validationCodeExpiresAt'] =
          validationCodeExpiresAt!.toIso8601String();
    }
    if (fcmToken != null) {
      data['fcmToken'] = fcmToken;
    }

    // Add new fields
    if (address != null) {
      data['address'] = address;
    }
    if (location != null) {
      data['location'] = location;
    }
    if (profilePicture != null) {
      data['profilePicture'] = profilePicture;
    }
    if (isOnline != null) {
      data['isOnline'] = isOnline;
    }
    if (lastActive != null) {
      data['lastActive'] = lastActive!.toIso8601String();
    }
    if (oneSignalPlayerId != null) {
      data['oneSignalPlayerId'] = oneSignalPlayerId;
    }
    if (passwordResetCode != null) {
      data['passwordResetCode'] = passwordResetCode;
    }
    if (passwordResetExpires != null) {
      data['passwordResetExpires'] = passwordResetExpires!.toIso8601String();
    }
    if (refreshToken != null) {
      data['refreshToken'] = refreshToken;
    }

    return data;
  }

  UserModel copyWith({
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
    return UserModel(
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
      address: address ?? this.address,
      location: location ?? this.location,
      profilePicture: profilePicture ?? this.profilePicture,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      oneSignalPlayerId: oneSignalPlayerId ?? this.oneSignalPlayerId,
      passwordResetCode: passwordResetCode ?? this.passwordResetCode,
      passwordResetExpires: passwordResetExpires ?? this.passwordResetExpires,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
