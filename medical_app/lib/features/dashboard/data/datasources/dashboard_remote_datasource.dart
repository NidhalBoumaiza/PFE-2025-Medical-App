import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  /// Fetch upcoming appointments for a doctor
  /// Throws [ServerException] if something goes wrong
  Future<List<AppointmentModel>> getUpcomingAppointments(
    String doctorId, {
    int limit = 5,
  });

  /// Count appointments by status for a doctor
  /// Throws [ServerException] if something goes wrong
  Future<Map<String, int>> getAppointmentsCountByStatus(String doctorId);

  /// Count total patients for a doctor
  /// Throws [ServerException] if something goes wrong
  Future<int> getTotalPatientsCount(String doctorId);

  /// Fetch complete dashboard statistics for a doctor
  /// Throws [ServerException] if something goes wrong
  Future<DashboardStatsModel> getDoctorDashboardStats(String doctorId);

  /// Method to fetch doctor's patients with pagination
  Future<Map<String, dynamic>> getDoctorPatients(
    String doctorId, {
    int limit = 10,
    String? lastPatientId,
  });
}

/// Implementation that uses Firebase Firestore
class FirebaseDashboardRemoteDataSourceImpl
    implements DashboardRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseDashboardRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments(
    String doctorId, {
    int limit = 5,
  }) async {
    try {
      final now = DateTime.now();
      print('Fetching upcoming appointments for doctor: $doctorId');

      // Query for all appointments for this doctor, not just pending ones
      final querySnapshot =
          await firestore
              .collection('rendez_vous')
              .where('doctorId', isEqualTo: doctorId)
              // Exclude cancelled appointments
              .where('status', whereNotIn: ['cancelled'])
              .get();

      print('Found ${querySnapshot.docs.length} total appointments');

      // Filter for future appointments in memory
      final allAppointments =
          querySnapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;

                // Handle timestamp conversion
                final timestamp = data['startTime'];
                DateTime appointmentDate;

                if (timestamp is Timestamp) {
                  appointmentDate = timestamp.toDate();
                } else if (timestamp is String) {
                  appointmentDate = DateTime.parse(timestamp);
                } else {
                  // Default to now if we can't determine the date
                  appointmentDate = DateTime.now();
                }

                return AppointmentModel(
                  id: doc.id,
                  patientId: data['patientId'] ?? '',
                  patientName: data['patientName'] ?? 'Unknown Patient',
                  appointmentDate: appointmentDate,
                  status: data['status'] ?? 'pending',
                  appointmentType:
                      data['speciality'] ??
                      data['appointmentType'] ??
                      'Consultation',
                );
              })
              .where((appointment) {
                // Keep only future appointments or today's appointments
                return appointment.appointmentDate.isAfter(
                  DateTime(now.year, now.month, now.day),
                );
              })
              .toList();

      // Sort by date (nearest first)
      allAppointments.sort(
        (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
      );

      // Take only the specified limit
      final limitedAppointments = allAppointments.take(limit).toList();
      print('Returning ${limitedAppointments.length} upcoming appointments');

      return limitedAppointments;
    } catch (e) {
      print('Error getting upcoming appointments: $e');
      return [];
    }
  }

  @override
  Future<Map<String, int>> getAppointmentsCountByStatus(String doctorId) async {
    try {
      final result = {
        'pending': 0,
        'accepted': 0,
        'cancelled': 0,
        'completed': 0,
        'total': 0,
      };

      // Count all appointments
      final totalQuery =
          await firestore
              .collection('rendez_vous')
              .where('doctorId', isEqualTo: doctorId)
              .count()
              .get();

      result['total'] = totalQuery.count ?? 0;

      // Count pending appointments
      final pendingQuery =
          await firestore
              .collection('rendez_vous')
              .where('doctorId', isEqualTo: doctorId)
              .where('status', isEqualTo: 'pending')
              .count()
              .get();

      result['pending'] = pendingQuery.count ?? 0;

      // Count accepted appointments
      final acceptedQuery =
          await firestore
              .collection('rendez_vous')
              .where('doctorId', isEqualTo: doctorId)
              .where('status', isEqualTo: 'accepted')
              .count()
              .get();

      result['accepted'] = acceptedQuery.count ?? 0;

      // Count cancelled appointments
      final cancelledQuery =
          await firestore
              .collection('rendez_vous')
              .where('doctorId', isEqualTo: doctorId)
              .where('status', isEqualTo: 'cancelled')
              .count()
              .get();

      result['cancelled'] = cancelledQuery.count ?? 0;

      // Count completed appointments
      final completedQuery =
          await firestore
              .collection('rendez_vous')
              .where('doctorId', isEqualTo: doctorId)
              .where('status', isEqualTo: 'completed')
              .count()
              .get();

      result['completed'] = completedQuery.count ?? 0;

      return result;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firebase error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<int> getTotalPatientsCount(String doctorId) async {
    try {
      // Get unique patients who have appointments with this doctor
      final querySnapshot =
          await firestore
              .collection('rendez_vous')
              .where('doctorId', isEqualTo: doctorId)
              .get();

      // Extract unique patient IDs
      final uniquePatientIds =
          querySnapshot.docs
              .map((doc) => doc.data()['patientId'] as String?)
              .where((id) => id != null)
              .toSet();

      return uniquePatientIds.length;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firebase error');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<DashboardStatsModel> getDoctorDashboardStats(String doctorId) async {
    try {
      // Get all required data in parallel for efficiency
      final appointmentsCountFuture = getAppointmentsCountByStatus(doctorId);
      final upcomingAppointmentsFuture = getUpcomingAppointments(doctorId);
      final totalPatientsFuture = getTotalPatientsCount(doctorId);

      // Wait for all operations to complete
      final results = await Future.wait([
        appointmentsCountFuture,
        upcomingAppointmentsFuture,
        totalPatientsFuture,
      ]);

      final appointmentsCount = results[0] as Map<String, int>;
      final upcomingAppointments = results[1] as List<AppointmentModel>;
      final totalPatients = results[2] as int;

      return DashboardStatsModel.fromFirestore(
        totalPatients: totalPatients,
        totalAppointments: appointmentsCount['total'] ?? 0,
        pendingAppointments: appointmentsCount['pending'] ?? 0,
        completedAppointments: appointmentsCount['completed'] ?? 0,
        cancelledAppointments: appointmentsCount['cancelled'] ?? 0,
        upcomingAppointments: upcomingAppointments,
      );
    } on ServerException catch (e) {
      // Re-throw the original ServerException
      throw e;
    } catch (e, stackTrace) {
      // Detailed error reporting for debugging
      print('Error in getDoctorDashboardStats: $e');
      print('Stack trace: $stackTrace');
      throw ServerException(message: 'Failed to get dashboard stats: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDoctorPatients(
    String doctorId, {
    int limit = 10,
    String? lastPatientId,
  }) async {
    try {
      print(
        'Fetching patients for doctor: $doctorId, limit: $limit, lastPatientId: $lastPatientId',
      );

      // Create a base query to find all patients who have had appointments with this doctor
      Query query = firestore
          .collection('rendez_vous')
          .where('doctorId', isEqualTo: doctorId);

      // Apply pagination if we have a last patient ID
      if (lastPatientId != null) {
        // Get the last document
        DocumentSnapshot lastDoc =
            await firestore.collection('rendez_vous').doc(lastPatientId).get();

        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      // Execute the query with limit
      final appointmentsSnapshot = await query.limit(limit).get();

      print('Found ${appointmentsSnapshot.docs.length} appointments');

      // Extract unique patient IDs
      Set<String> uniquePatientIds = {};
      List<Map<String, dynamic>> patientsData = [];

      for (var doc in appointmentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final patientId = data['patientId'] as String?;

        if (patientId != null && !uniquePatientIds.contains(patientId)) {
          uniquePatientIds.add(patientId);

          try {
            // Get patient details from patients collection
            final patientDoc =
                await firestore.collection('patients').doc(patientId).get();

            if (patientDoc.exists) {
              final patientData = patientDoc.data() as Map<String, dynamic>;
              patientData['id'] = patientId;

              // Get the most recent appointment for this patient
              final lastAppointmentQuery =
                  await firestore
                      .collection('rendez_vous')
                      .where('patientId', isEqualTo: patientId)
                      .where('doctorId', isEqualTo: doctorId)
                      .orderBy('startTime', descending: true)
                      .limit(1)
                      .get();

              if (lastAppointmentQuery.docs.isNotEmpty) {
                final lastAppointmentData =
                    lastAppointmentQuery.docs.first.data();
                final timestamp = lastAppointmentData['startTime'];

                DateTime appointmentDate;
                if (timestamp is Timestamp) {
                  appointmentDate = timestamp.toDate();
                } else if (timestamp is String) {
                  appointmentDate = DateTime.parse(timestamp);
                } else {
                  appointmentDate = DateTime.now();
                }

                patientData['lastAppointment'] =
                    appointmentDate.toIso8601String();
                patientData['lastAppointmentStatus'] =
                    lastAppointmentData['status'];
              }

              patientsData.add(patientData);
            } else {
              // Patient document doesn't exist but we have an appointment for them
              // Create a minimal patient record based on the appointment data
              final patientName =
                  data['patientName'] as String? ?? 'Patient inconnu';
              patientsData.add({
                'id': patientId,
                'name': patientName.split(' ').first,
                'lastName':
                    patientName.split(' ').length > 1
                        ? patientName.split(' ').last
                        : '',
                'email': 'patient@example.com',
                'phoneNumber': '',
                'lastAppointment':
                    (data['startTime'] is Timestamp)
                        ? (data['startTime'] as Timestamp)
                            .toDate()
                            .toIso8601String()
                        : DateTime.now().toIso8601String(),
                'lastAppointmentStatus': data['status'] ?? 'unknown',
              });
            }
          } catch (e) {
            print('Error fetching patient $patientId: $e');
          }
        }
      }

      // Sort by most recent appointment
      patientsData.sort((a, b) {
        final aDate = a['lastAppointment'] as String?;
        final bDate = b['lastAppointment'] as String?;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return DateTime.parse(bDate).compareTo(DateTime.parse(aDate));
      });

      // Determine if there are more patients to load
      bool hasMore = appointmentsSnapshot.docs.length >= limit;
      String? nextPatientId =
          hasMore && appointmentsSnapshot.docs.isNotEmpty
              ? appointmentsSnapshot.docs.last.id
              : null;

      return {
        'patients': patientsData,
        'hasMore': hasMore,
        'nextPatientId': nextPatientId,
      };
    } catch (e) {
      print('Error getting doctor patients: $e');
      return {'patients': [], 'hasMore': false, 'nextPatientId': null};
    }
  }
}

/// MongoDB implementation that uses HTTP API
class MongoDBDashboardRemoteDataSourceImpl
    implements DashboardRemoteDataSource {
  final http.Client client;

  MongoDBDashboardRemoteDataSourceImpl({required this.client});

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};

    try {
      // Get token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';
      if (authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }
    } catch (e) {
      print('Error getting auth token: $e');
    }

    return headers;
  }

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments(
    String doctorId, {
    int limit = 5,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse(
          '${AppConstants.appointmentsEndpoint}/upcoming?medecin=$doctorId&limit=$limit',
        ),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch upcoming appointments: ${response.body}',
        );
      }

      final jsonData = json.decode(response.body);
      final appointmentsData = jsonData['data'] as List<dynamic>;

      return appointmentsData.map((appointment) {
        return AppointmentModel(
          id: appointment['_id'],
          patientId: appointment['patient'],
          patientName: appointment['patientName'] ?? 'Unknown Patient',
          appointmentDate: DateTime.parse(appointment['startDate']),
          status: appointment['status'] ?? 'pending',
          appointmentType: appointment['serviceName'] ?? 'Consultation',
        );
      }).toList();
    } catch (e) {
      print('Error getting upcoming appointments: $e');
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch upcoming appointments: $e',
      );
    }
  }

  @override
  Future<Map<String, int>> getAppointmentsCountByStatus(String doctorId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse(
          '${AppConstants.dashboardEndpoint}/stats/appointments?medecin=$doctorId',
        ),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch appointment counts: ${response.body}',
        );
      }

      final jsonData = json.decode(response.body);
      final statsData = jsonData['data'];

      return {
        'pending': statsData['pendingAppointments'] ?? 0,
        'accepted': statsData['acceptedAppointments'] ?? 0,
        'cancelled': statsData['cancelledAppointments'] ?? 0,
        'completed': statsData['completedAppointments'] ?? 0,
        'total': statsData['totalAppointments'] ?? 0,
      };
    } catch (e) {
      print('Error getting appointment counts: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch appointment counts: $e');
    }
  }

  @override
  Future<int> getTotalPatientsCount(String doctorId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse(
          '${AppConstants.dashboardEndpoint}/stats/patients?medecin=$doctorId',
        ),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch patient count: ${response.body}',
        );
      }

      final jsonData = json.decode(response.body);
      return jsonData['data']['totalPatients'] ?? 0;
    } catch (e) {
      print('Error getting total patients count: $e');
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch total patients count: $e',
      );
    }
  }

  @override
  Future<DashboardStatsModel> getDoctorDashboardStats(String doctorId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('${AppConstants.dashboardEndpoint}/doctor/$doctorId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch dashboard stats: ${response.body}',
        );
      }

      final jsonData = json.decode(response.body);
      final statsData = jsonData['data'];

      // Get upcoming appointments separately as they need to be parsed into models
      final upcomingAppointmentsFuture = getUpcomingAppointments(doctorId);

      // Wait for the upcoming appointments to be fetched
      final upcomingAppointments = await upcomingAppointmentsFuture;

      return DashboardStatsModel.fromJson(
        statsData,
        upcomingAppointments: upcomingAppointments,
      );
    } catch (e) {
      print('Error getting dashboard stats: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch dashboard stats: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDoctorPatients(
    String doctorId, {
    int limit = 10,
    String? lastPatientId,
  }) async {
    try {
      final headers = await _getHeaders();
      String url =
          '${AppConstants.dashboardEndpoint}/patients?medecin=$doctorId&limit=$limit';

      if (lastPatientId != null) {
        url += '&lastId=$lastPatientId';
      }

      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch doctor patients: ${response.body}',
        );
      }

      final jsonData = json.decode(response.body);
      final patientsData = jsonData['data']['patients'] as List<dynamic>;

      List<Map<String, dynamic>> formattedPatients =
          patientsData.map((patient) {
            return {
              'id': patient['_id'],
              'name': patient['name'] ?? '',
              'lastName': patient['lastName'] ?? '',
              'email': patient['email'] ?? '',
              'phoneNumber': patient['phoneNumber'] ?? '',
              'lastAppointment':
                  patient['lastAppointment'] ??
                  DateTime.now().toIso8601String(),
              'lastAppointmentStatus':
                  patient['lastAppointmentStatus'] ?? 'unknown',
            };
          }).toList();

      return {
        'patients': formattedPatients,
        'hasMore': jsonData['data']['hasMore'] ?? false,
        'nextPatientId': jsonData['data']['nextPatientId'],
      };
    } catch (e) {
      print('Error getting doctor patients: $e');
      if (e is ServerException) rethrow;
      return {'patients': [], 'hasMore': false, 'nextPatientId': null};
    }
  }
}
