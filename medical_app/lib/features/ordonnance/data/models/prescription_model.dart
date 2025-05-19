import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/prescription_entity.dart';

class PrescriptionModel extends PrescriptionEntity {
  const PrescriptionModel({
    required String id,
    required String appointmentId,
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required List<MedicationEntity> medications,
    String? note,
    DateTime? expiresAt,
    String status = 'active',
    DateTime? issuedAt,
  }) : super(
         id: id,
         appointmentId: appointmentId,
         patientId: patientId,
         patientName: patientName,
         doctorId: doctorId,
         doctorName: doctorName,
         date: date,
         medications: medications,
         note: note,
         expiresAt: expiresAt,
         status: status,
         issuedAt: issuedAt,
       );

  // Convert to JSON for API or storage
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'appointment': appointmentId,
      'patient': patientId,
      'medecin': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'medications': medications.map((m) => m.toJson()).toList(),
      'note': note,
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
      'issuedAt':
          issuedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from JSON
  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    List<MedicationEntity> meds = [];
    if (json['medications'] != null) {
      final medications = json['medications'] as List;
      meds =
          medications
              .map((m) => MedicationEntity.fromJson(m as Map<String, dynamic>))
              .toList();
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.parse(value as String);
    }

    final id = json['_id'] as String? ?? json['id'] as String? ?? '';
    final appointmentId =
        json['appointment'] as String? ??
        json['appointmentId'] as String? ??
        '';
    final patientId =
        json['patient'] is String
            ? json['patient'] as String
            : json['patientId'] as String? ?? '';
    final doctorId =
        json['medecin'] is String
            ? json['medecin'] as String
            : json['doctorId'] as String? ?? '';

    return PrescriptionModel(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      patientName: json['patientName'] as String? ?? '',
      doctorId: doctorId,
      doctorName: json['doctorName'] as String? ?? '',
      date: parseDate(json['date']),
      medications: meds,
      note: json['note'] as String?,
      expiresAt:
          json['expiresAt'] != null ? parseDate(json['expiresAt']) : null,
      status: json['status'] as String? ?? 'active',
      issuedAt: json['issuedAt'] != null ? parseDate(json['issuedAt']) : null,
    );
  }

  // Create from entity
  factory PrescriptionModel.fromEntity(PrescriptionEntity entity) {
    return PrescriptionModel(
      id: entity.id,
      appointmentId: entity.appointmentId,
      patientId: entity.patientId,
      patientName: entity.patientName,
      doctorId: entity.doctorId,
      doctorName: entity.doctorName,
      date: entity.date,
      medications: entity.medications,
      note: entity.note,
      expiresAt: entity.expiresAt,
      status: entity.status,
      issuedAt: entity.issuedAt,
    );
  }
}
