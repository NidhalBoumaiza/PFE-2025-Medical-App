import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/constants.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/core/services/api_service.dart';
import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_local_data_source.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/authentication/data/models/medecin_model.dart';
import '../models/RendezVous.dart';

abstract class RendezVousRemoteDataSource {
  Future<List<RendezVousModel>> getRendezVous({
    String? patientId,
    String? doctorId,
  });

  Future<void> updateRendezVousStatus(String rendezVousId, String status);

  Future<void> createRendezVous(RendezVousModel rendezVous);

  Future<List<MedecinEntity>> getDoctorsBySpecialty(
    String specialty, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<RendezVousModel> getRendezVousDetails(String rendezVousId);

  Future<void> cancelAppointment(String rendezVousId);

  Future<void> rateDoctor(String appointmentId, double rating);

  Future<List<RendezVousModel>> getDoctorAppointmentsForDay(
    String doctorId,
    DateTime date,
  );

  Future<void> acceptAppointment(String rendezVousId);

  Future<void> refuseAppointment(String rendezVousId);
}

class RendezVousRemoteDataSourceImpl implements RendezVousRemoteDataSource {
  final RendezVousLocalDataSource localDataSource;

  RendezVousRemoteDataSourceImpl({required this.localDataSource});

  @override
  Future<List<RendezVousModel>> getRendezVous({
    String? patientId,
    String? doctorId,
  }) async {
    if (patientId == null && doctorId == null) {
      throw ServerException(
        message: 'Either patientId or doctorId must be provided',
      );
    }

    try {
      String url;
      if (patientId != null) {
        // For patient, use the patient route
        url = '${AppConstants.appointmentsEndpoint}/myAppointments';
      } else {
        // For doctor, use the doctor route
        url = '${AppConstants.appointmentsEndpoint}/doctorAppointments';
      }

      final response = await ApiService.getRequest(url);
      final appointmentsData = response['data']['appointments'] as List;

      final rendezVous =
          appointmentsData
              .map((appointment) => RendezVousModel.fromJson(appointment))
              .toList();

      await localDataSource.cacheRendezVous(rendezVous);
      return rendezVous;
    } catch (e) {
      throw ServerException(message: 'Error fetching appointments: $e');
    }
  }

  @override
  Future<void> updateRendezVousStatus(
    String rendezVousId,
    String status,
  ) async {
    try {
      String endpoint;
      switch (status) {
        case 'Accepté':
          endpoint =
              '${AppConstants.appointmentsEndpoint}/acceptAppointment/$rendezVousId';
          break;
        case 'Refusé':
          endpoint =
              '${AppConstants.appointmentsEndpoint}/refuseAppointment/$rendezVousId';
          break;
        case 'Annulé':
          endpoint =
              '${AppConstants.appointmentsEndpoint}/cancelAppointment/$rendezVousId';
          break;
        default:
          throw ServerException(message: 'Unsupported status: $status');
      }

      await ApiService.patchRequest(endpoint, {});
    } catch (e) {
      throw ServerException(message: 'Error updating appointment status: $e');
    }
  }

  @override
  Future<void> createRendezVous(RendezVousModel rendezVous) async {
    try {
      final data = {
        'startDate': rendezVous.startDate.toIso8601String(),
        'endDate': rendezVous.endDate.toIso8601String(),
        'serviceName': rendezVous.serviceName,
        'medecinId': rendezVous.medecin,
        'motif': rendezVous.motif,
        'symptoms': rendezVous.symptoms,
      };

      await ApiService.postRequest(
        '${AppConstants.appointmentsEndpoint}/createAppointment',
        data,
      );
    } catch (e) {
      throw ServerException(message: 'Error creating appointment: $e');
    }
  }

  @override
  Future<List<MedecinEntity>> getDoctorsBySpecialty(
    String specialty, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final data = {'speciality': specialty};

      // Add date range if provided
      if (startDate != null && endDate != null) {
        data['startDate'] = startDate.toIso8601String();
        data['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService.postRequest(
        '${AppConstants.appointmentsEndpoint}/getAvailableDoctors',
        data,
      );

      final doctorsData = response['data']['doctors'] as List;

      // Create a list of MedecinEntity objects
      List<MedecinEntity> doctorEntities = [];
      for (var doctor in doctorsData) {
        MedecinModel doctorModel = MedecinModel.fromJson(doctor);
        doctorEntities.add(doctorModel.toEntity());
      }

      return doctorEntities;
    } catch (e) {
      throw ServerException(message: 'Error fetching doctors by specialty: $e');
    }
  }

  @override
  Future<RendezVousModel> getRendezVousDetails(String rendezVousId) async {
    try {
      final response = await ApiService.getRequest(
        '${AppConstants.appointmentsEndpoint}/$rendezVousId',
      );

      return RendezVousModel.fromJson(response['data']['appointment']);
    } catch (e) {
      throw ServerException(message: 'Error fetching appointment details: $e');
    }
  }

  @override
  Future<void> cancelAppointment(String rendezVousId) async {
    try {
      await ApiService.patchRequest(
        '${AppConstants.appointmentsEndpoint}/cancelAppointment/$rendezVousId',
        {},
      );
    } catch (e) {
      throw ServerException(message: 'Error canceling appointment: $e');
    }
  }

  @override
  Future<void> rateDoctor(String appointmentId, double rating) async {
    try {
      await ApiService.postRequest(
        '${AppConstants.appointmentsEndpoint}/rateDoctor',
        {'appointmentId': appointmentId, 'rating': rating},
      );
    } catch (e) {
      throw ServerException(message: 'Error rating doctor: $e');
    }
  }

  @override
  Future<List<RendezVousModel>> getDoctorAppointmentsForDay(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final response = await ApiService.postRequest(
        '${AppConstants.appointmentsEndpoint}/doctorAppointmentsForDay',
        {'date': date.toIso8601String()},
      );

      final appointmentsData = response['data']['appointments'] as List;

      final rendezVous =
          appointmentsData
              .map((appointment) => RendezVousModel.fromJson(appointment))
              .toList();

      return rendezVous;
    } catch (e) {
      throw ServerException(
        message: 'Error fetching doctor appointments for day: $e',
      );
    }
  }

  @override
  Future<void> acceptAppointment(String rendezVousId) async {
    try {
      await ApiService.patchRequest(
        '${AppConstants.appointmentsEndpoint}/acceptAppointment/$rendezVousId',
        {},
      );
    } catch (e) {
      throw ServerException(message: 'Error accepting appointment: $e');
    }
  }

  @override
  Future<void> refuseAppointment(String rendezVousId) async {
    try {
      await ApiService.patchRequest(
        '${AppConstants.appointmentsEndpoint}/refuseAppointment/$rendezVousId',
        {},
      );
    } catch (e) {
      throw ServerException(message: 'Error refusing appointment: $e');
    }
  }
}
