import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';

class RendezVousModel extends RendezVousEntity {
  RendezVousModel({
    String? id,
    required DateTime startDate,
    required DateTime endDate,
    required String serviceName,
    required String patient,
    required String medecin,
    required String status,
    String? motif,
    String? notes,
    List<String>? symptoms,
    bool isRated = false,
    bool hasPrescription = false,
    DateTime? createdAt,
    // UI display fields
    String? patientName,
    String? patientLastName,
    String? patientProfilePicture,
    String? patientPhoneNumber,
    String? medecinName,
    String? medecinLastName,
    String? medecinProfilePicture,
    String? medecinSpeciality,
  }) : super(
         id: id,
         startDate: startDate,
         endDate: endDate,
         serviceName: serviceName,
         patient: patient,
         medecin: medecin,
         status: status,
         motif: motif,
         notes: notes,
         symptoms: symptoms,
         isRated: isRated,
         hasPrescription: hasPrescription,
         createdAt: createdAt,
         patientName: patientName,
         patientLastName: patientLastName,
         patientProfilePicture: patientProfilePicture,
         patientPhoneNumber: patientPhoneNumber,
         medecinName: medecinName,
         medecinLastName: medecinLastName,
         medecinProfilePicture: medecinProfilePicture,
         medecinSpeciality: medecinSpeciality,
       );

  factory RendezVousModel.fromJson(Map<String, dynamic> json) {
    // Handle nested patient data
    final Map<String, dynamic>? patientData =
        json['patient'] is Map
            ? Map<String, dynamic>.from(json['patient'] as Map)
            : null;

    // Handle nested medecin data
    final Map<String, dynamic>? medecinData =
        json['medecin'] is Map
            ? Map<String, dynamic>.from(json['medecin'] as Map)
            : null;

    return RendezVousModel(
      id:
          json['_id'] as String? ??
          json['id'] as String?, // Handle both _id and id
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      serviceName: json['serviceName'] as String,
      patient:
          json['patient'] is String
              ? json['patient'] as String
              : patientData?['_id'] as String? ?? '',
      medecin:
          json['medecin'] is String
              ? json['medecin'] as String
              : medecinData?['_id'] as String? ?? '',
      status: json['status'] as String,
      motif: json['motif'] as String?,
      notes: json['notes'] as String?,
      symptoms:
          json['symptoms'] != null
              ? List<String>.from(json['symptoms'] as List)
              : null,
      isRated: json['isRated'] as bool? ?? false,
      hasPrescription: json['hasPrescription'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,

      // UI display fields from populated patient data
      patientName: patientData?['name'] as String?,
      patientLastName: patientData?['lastName'] as String?,
      patientProfilePicture: patientData?['profilePicture'] as String?,
      patientPhoneNumber: patientData?['phoneNumber'] as String?,

      // UI display fields from populated medecin data
      medecinName: medecinData?['name'] as String?,
      medecinLastName: medecinData?['lastName'] as String?,
      medecinProfilePicture: medecinData?['profilePicture'] as String?,
      medecinSpeciality: medecinData?['speciality'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'serviceName': serviceName,
      'patient': patient,
      'medecin': medecin,
      'status': status,
      if (motif != null) 'motif': motif,
      if (notes != null) 'notes': notes,
      if (symptoms != null) 'symptoms': symptoms,
      'isRated': isRated,
      'hasPrescription': hasPrescription,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),

      // Don't include UI display fields in toJson as they're not part of the main schema
    };
  }
}
