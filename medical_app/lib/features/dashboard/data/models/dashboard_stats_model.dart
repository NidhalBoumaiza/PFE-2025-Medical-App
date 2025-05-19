import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required int totalPatients,
    required int totalAppointments,
    required int pendingAppointments,
    required int completedAppointments,
    required int cancelledAppointments,
    required List<AppointmentEntity> upcomingAppointments,
  }) : super(
         totalPatients: totalPatients,
         totalAppointments: totalAppointments,
         pendingAppointments: pendingAppointments,
         completedAppointments: completedAppointments,
         cancelledAppointments: cancelledAppointments,
         upcomingAppointments: upcomingAppointments,
       );

  factory DashboardStatsModel.fromFirestore({
    required int totalPatients,
    required int totalAppointments,
    required int pendingAppointments,
    required int completedAppointments,
    required int cancelledAppointments,
    required List<AppointmentModel> upcomingAppointments,
  }) {
    return DashboardStatsModel(
      totalPatients: totalPatients,
      totalAppointments: totalAppointments,
      pendingAppointments: pendingAppointments,
      completedAppointments: completedAppointments,
      cancelledAppointments: cancelledAppointments,
      upcomingAppointments: upcomingAppointments,
    );
  }

  // MongoDB JSON deserializer
  factory DashboardStatsModel.fromJson(
    Map<String, dynamic> json, {
    required List<AppointmentModel> upcomingAppointments,
  }) {
    return DashboardStatsModel(
      totalPatients: json['totalPatients'] ?? 0,
      totalAppointments: json['totalAppointments'] ?? 0,
      pendingAppointments: json['pendingAppointments'] ?? 0,
      completedAppointments: json['completedAppointments'] ?? 0,
      cancelledAppointments: json['cancelledAppointments'] ?? 0,
      upcomingAppointments: upcomingAppointments,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'totalPatients': totalPatients,
      'totalAppointments': totalAppointments,
      'pendingAppointments': pendingAppointments,
      'completedAppointments': completedAppointments,
      'cancelledAppointments': cancelledAppointments,
    };
  }
}

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required String id,
    required String patientId,
    required String patientName,
    required DateTime appointmentDate,
    required String status,
    String? appointmentType,
  }) : super(
         id: id,
         patientId: patientId,
         patientName: patientName,
         appointmentDate: appointmentDate,
         status: status,
         appointmentType: appointmentType,
       );

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime appointmentDate;
    try {
      if (data['startTime'] is Timestamp) {
        appointmentDate = (data['startTime'] as Timestamp).toDate();
      } else if (data['startTime'] is String) {
        // Try to parse the string as a DateTime
        appointmentDate = DateTime.parse(data['startTime'] as String);
      } else {
        // Default to current time if field is missing or invalid
        appointmentDate = DateTime.now();
      }
    } catch (e) {
      // Handle any parsing errors by using current time
      print('Error parsing date: $e');
      appointmentDate = DateTime.now();
    }

    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Unknown Patient',
      appointmentDate: appointmentDate,
      status: data['status'] ?? 'pending',
      appointmentType: data['appointmentType'],
    );
  }

  // Create from MongoDB JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    DateTime appointmentDate;
    try {
      if (json['startDate'] != null) {
        appointmentDate = DateTime.parse(json['startDate']);
      } else if (json['appointmentDate'] != null) {
        appointmentDate = DateTime.parse(json['appointmentDate']);
      } else {
        appointmentDate = DateTime.now();
      }
    } catch (e) {
      print('Error parsing appointment date: $e');
      appointmentDate = DateTime.now();
    }

    return AppointmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patient'] ?? json['patientId'] ?? '',
      patientName: json['patientName'] ?? 'Unknown Patient',
      appointmentDate: appointmentDate,
      status: json['status'] ?? 'pending',
      appointmentType:
          json['serviceName'] ?? json['appointmentType'] ?? 'Consultation',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'startTime': appointmentDate.toIso8601String(),
      'status': status,
      if (appointmentType != null) 'appointmentType': appointmentType,
    };
  }

  // Convert to MongoDB format
  Map<String, dynamic> toMongoJson() {
    return {
      '_id': id,
      'patient': patientId,
      'patientName': patientName,
      'startDate': appointmentDate.toIso8601String(),
      'status': status,
      'serviceName': appointmentType ?? 'Consultation',
    };
  }
}
