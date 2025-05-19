import 'package:equatable/equatable.dart';

class MedicationEntity extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final String? frequency;
  final String? duration;

  const MedicationEntity({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    this.frequency,
    this.duration,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    instructions,
    frequency,
    duration,
  ];

  factory MedicationEntity.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB _id vs regular id
    final id = json['_id'] != null ? json['_id'] : (json['id'] ?? '');

    return MedicationEntity(
      id: id.toString(),
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      frequency: json['frequency'] as String?,
      duration: json['duration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Use _id for MongoDB compatibility
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      if (frequency != null) 'frequency': frequency,
      if (duration != null) 'duration': duration,
    };
  }
}

class PrescriptionEntity extends Equatable {
  final String id;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final List<MedicationEntity> medications;
  final String? note;
  final DateTime? expiresAt;
  final String status;
  final DateTime? issuedAt;

  const PrescriptionEntity({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.medications,
    this.note,
    this.expiresAt,
    this.status = 'active',
    this.issuedAt,
  });

  @override
  List<Object?> get props => [
    id,
    appointmentId,
    patientId,
    patientName,
    doctorId,
    doctorName,
    date,
    medications,
    note,
    expiresAt,
    status,
    issuedAt,
  ];

  // Factory method to create a new prescription
  factory PrescriptionEntity.create({
    required String id,
    required String appointmentId,
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required List<MedicationEntity> medications,
    String? note,
    DateTime? expiresAt,
    String status = 'active',
  }) {
    final now = DateTime.now();
    return PrescriptionEntity(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      date: now,
      medications: medications,
      note: note,
      expiresAt:
          expiresAt ??
          now.add(const Duration(days: 30)), // Default 30 days validity
      status: status,
      issuedAt: now,
    );
  }
}
