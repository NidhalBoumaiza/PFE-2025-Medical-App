import 'package:equatable/equatable.dart';

class RendezVousEntity extends Equatable {
  final String? id; // MongoDB _id
  final DateTime startDate; // Start date of appointment
  final DateTime endDate; // End date of appointment
  final String serviceName; // Name of the service
  final String patient; // MongoDB ObjectId reference
  final String medecin; // MongoDB ObjectId reference
  final String
  status; // Status: "En attente", "Accepté", "Refusé", "Annulé", "Terminé"
  final String? motif; // Reason for appointment
  final String? notes; // Additional notes
  final List<String>? symptoms; // List of symptoms
  final bool isRated; // Whether the appointment has been rated
  final bool hasPrescription; // Whether the appointment has a prescription
  final DateTime? createdAt; // Creation date

  // Additional fields for UI display purposes
  final String? patientName; // UI display - not in MongoDB schema
  final String? patientLastName; // UI display - not in MongoDB schema
  final String? patientProfilePicture; // UI display - not in MongoDB schema
  final String? patientPhoneNumber; // UI display - not in MongoDB schema
  final String? medecinName; // UI display - not in MongoDB schema
  final String? medecinLastName; // UI display - not in MongoDB schema
  final String? medecinProfilePicture; // UI display - not in MongoDB schema
  final String? medecinSpeciality; // UI display - not in MongoDB schema

  const RendezVousEntity({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.serviceName,
    required this.patient,
    required this.medecin,
    required this.status,
    this.motif,
    this.notes,
    this.symptoms,
    this.isRated = false,
    this.hasPrescription = false,
    this.createdAt,
    // UI display fields
    this.patientName,
    this.patientLastName,
    this.patientProfilePicture,
    this.patientPhoneNumber,
    this.medecinName,
    this.medecinLastName,
    this.medecinProfilePicture,
    this.medecinSpeciality,
  });

  factory RendezVousEntity.create({
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
  }) {
    return RendezVousEntity(
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
  }

  @override
  List<Object?> get props => [
    id,
    startDate,
    endDate,
    serviceName,
    patient,
    medecin,
    status,
    motif,
    notes,
    symptoms,
    isRated,
    hasPrescription,
    createdAt,
    patientName,
    patientLastName,
    patientProfilePicture,
    patientPhoneNumber,
    medecinName,
    medecinLastName,
    medecinProfilePicture,
    medecinSpeciality,
  ];
}
