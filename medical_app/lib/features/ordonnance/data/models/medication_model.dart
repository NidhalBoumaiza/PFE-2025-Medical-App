import '../../domain/entities/prescription_entity.dart';

class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final String? frequency;
  final String? duration;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    this.frequency,
    this.duration,
  });

  factory MedicationModel.fromEntity(MedicationEntity entity) {
    return MedicationModel(
      id: entity.id,
      name: entity.name,
      dosage: entity.dosage,
      instructions: entity.instructions,
      frequency: entity.frequency,
      duration: entity.duration,
    );
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    // Handle both MongoDB _id and regular id
    final id = json['_id'] != null ? json['_id'] : (json['id'] ?? '');

    return MedicationModel(
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
      // Don't include id for new medications (MongoDB will generate it)
      // Use _id for MongoDB compatibility
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      if (frequency != null) 'frequency': frequency,
      if (duration != null) 'duration': duration,
    };
  }

  MedicationEntity toEntity() {
    return MedicationEntity(
      id: id,
      name: name,
      dosage: dosage,
      instructions: instructions,
      frequency: frequency,
      duration: duration,
    );
  }
}
