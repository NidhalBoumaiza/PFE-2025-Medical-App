import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/status_appointment.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/create_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_doctors_by_specialty_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/update_rendez_vous_status_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/cancel_appointment_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/rate_doctor_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/get_doctor_appointments_for_day_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/accept_appointment_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/refuse_appointment_use_case.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'rendez_vous_event.dart';
part 'rendez_vous_state.dart';

class RendezVousBloc extends Bloc<RendezVousEvent, RendezVousState> {
  final FetchRendezVousUseCase fetchRendezVousUseCase;
  final UpdateRendezVousStatusUseCase updateRendezVousStatusUseCase;
  final CreateRendezVousUseCase createRendezVousUseCase;
  final FetchDoctorsBySpecialtyUseCase fetchDoctorsBySpecialtyUseCase;
  final CancelAppointmentUseCase cancelAppointmentUseCase;
  final RateDoctorUseCase rateDoctorUseCase;
  final GetDoctorAppointmentsForDayUseCase getDoctorAppointmentsForDayUseCase;
  final AcceptAppointmentUseCase acceptAppointmentUseCase;
  final RefuseAppointmentUseCase refuseAppointmentUseCase;
  final NotificationBloc? notificationBloc;

  RendezVousBloc({
    required this.fetchRendezVousUseCase,
    required this.updateRendezVousStatusUseCase,
    required this.createRendezVousUseCase,
    required this.fetchDoctorsBySpecialtyUseCase,
    required this.cancelAppointmentUseCase,
    required this.rateDoctorUseCase,
    required this.getDoctorAppointmentsForDayUseCase,
    required this.acceptAppointmentUseCase,
    required this.refuseAppointmentUseCase,
    this.notificationBloc,
  }) : super(RendezVousInitial()) {
    on<FetchRendezVous>(_onFetchRendezVous);
    on<UpdateRendezVousStatus>(_onUpdateRendezVousStatus);
    on<CreateRendezVous>(_onCreateRendezVous);
    on<FetchDoctorsBySpecialty>(_onFetchDoctorsBySpecialty);
    on<CancelAppointment>(_onCancelAppointment);
    on<RateDoctor>(_onRateDoctor);
    on<GetDoctorAppointmentsForDay>(_onGetDoctorAppointmentsForDay);
    on<AcceptAppointment>(_onAcceptAppointment);
    on<RefuseAppointment>(_onRefuseAppointment);
  }

  Future<void> _onFetchRendezVous(
    FetchRendezVous event,
    Emitter<RendezVousState> emit,
  ) async {
    emit(RendezVousLoading());

    if (event.appointmentId != null) {
      try {
        // This would need to be updated to use the getRendezVousDetails use case
        emit(
          RendezVousError(
            'Direct appointment lookup by ID not implemented yet',
          ),
        );
      } catch (e) {
        emit(RendezVousError('Error fetching appointment: $e'));
      }
      return;
    }

    // Fetch appointments based on patient or doctor ID
    final failureOrRendezVous = await fetchRendezVousUseCase(
      patientId: event.patientId,
      doctorId: event.doctorId,
    );

    emit(
      failureOrRendezVous.fold(
        (failure) => RendezVousError(_mapFailureToMessage(failure)),
        (rendezVous) => RendezVousLoaded(rendezVous),
      ),
    );
  }

  Future<void> _onUpdateRendezVousStatus(
    UpdateRendezVousStatus event,
    Emitter<RendezVousState> emit,
  ) async {
    try {
      emit(UpdatingRendezVousState());

      // Update the status using the use case
      final failureOrUnit = await updateRendezVousStatusUseCase(
        rendezVousId: event.rendezVousId,
        status: event.status,
      );

      emit(
        failureOrUnit.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (_) => RendezVousStatusUpdatedState(
            id: event.rendezVousId,
            status: event.status,
          ),
        ),
      );
    } catch (e) {
      emit(RendezVousErrorState(message: e.toString()));
    }
  }

  Future<void> _onCreateRendezVous(
    CreateRendezVous event,
    Emitter<RendezVousState> emit,
  ) async {
    try {
      emit(AddingRendezVousState());
      final result = await createRendezVousUseCase(event.rendezVous);

      result.fold(
        (failure) => emit(RendezVousErrorState(message: failure.message)),
        (_) {
          // Emit RendezVousCreated state for navigation in UI
          emit(RendezVousCreated());
        },
      );
    } catch (e) {
      emit(RendezVousErrorState(message: e.toString()));
    }
  }

  Future<void> _onFetchDoctorsBySpecialty(
    FetchDoctorsBySpecialty event,
    Emitter<RendezVousState> emit,
  ) async {
    emit(RendezVousLoading());
    final failureOrDoctors = await fetchDoctorsBySpecialtyUseCase(
      event.specialty,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    emit(
      failureOrDoctors.fold(
        (failure) => RendezVousError(_mapFailureToMessage(failure)),
        (doctors) => DoctorsLoaded(doctors),
      ),
    );
  }

  Future<void> _onCancelAppointment(
    CancelAppointment event,
    Emitter<RendezVousState> emit,
  ) async {
    try {
      emit(UpdatingRendezVousState());

      final result = await cancelAppointmentUseCase(event.appointmentId);

      emit(
        result.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (_) => AppointmentCancelled(event.appointmentId),
        ),
      );
    } catch (e) {
      emit(RendezVousErrorState(message: e.toString()));
    }
  }

  Future<void> _onRateDoctor(
    RateDoctor event,
    Emitter<RendezVousState> emit,
  ) async {
    try {
      emit(RatingDoctorState());

      final result = await rateDoctorUseCase(
        appointmentId: event.appointmentId,
        rating: event.rating,
      );

      emit(
        result.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (_) => DoctorRated(event.appointmentId, event.rating),
        ),
      );
    } catch (e) {
      emit(RendezVousErrorState(message: e.toString()));
    }
  }

  Future<void> _onGetDoctorAppointmentsForDay(
    GetDoctorAppointmentsForDay event,
    Emitter<RendezVousState> emit,
  ) async {
    try {
      emit(RendezVousLoading());

      final result = await getDoctorAppointmentsForDayUseCase(
        doctorId: event.doctorId,
        date: event.date,
      );

      emit(
        result.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (appointments) =>
              DoctorDailyAppointmentsLoaded(appointments, event.date),
        ),
      );
    } catch (e) {
      emit(RendezVousErrorState(message: e.toString()));
    }
  }

  Future<void> _onAcceptAppointment(
    AcceptAppointment event,
    Emitter<RendezVousState> emit,
  ) async {
    try {
      emit(UpdatingRendezVousState());

      final result = await acceptAppointmentUseCase(event.appointmentId);

      emit(
        result.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (_) => AppointmentAccepted(event.appointmentId),
        ),
      );
    } catch (e) {
      emit(RendezVousErrorState(message: e.toString()));
    }
  }

  Future<void> _onRefuseAppointment(
    RefuseAppointment event,
    Emitter<RendezVousState> emit,
  ) async {
    try {
      emit(UpdatingRendezVousState());

      final result = await refuseAppointmentUseCase(event.appointmentId);

      emit(
        result.fold(
          (failure) => RendezVousError(_mapFailureToMessage(failure)),
          (_) => AppointmentRefused(event.appointmentId),
        ),
      );
    } catch (e) {
      emit(RendezVousErrorState(message: e.toString()));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case EmptyCacheFailure:
        return 'No cached data found';
      case OfflineFailure:
        return 'No internet connection';
      default:
        return 'Unexpected error';
    }
  }

  // Helper methods to send notifications
  void _sendNewAppointmentNotification(RendezVousEntity rendezVous) {
    if (notificationBloc != null &&
        rendezVous.patient != null &&
        rendezVous.medecin != null) {
      // Format date for better readability
      String formattedDate = rendezVous.startDate.toString().substring(0, 10);
      String formattedTime = _formatTime(rendezVous.startDate);

      // Create notification data
      Map<String, dynamic> notificationData = {
        'patientName': rendezVous.patientName ?? 'Unknown',
        'doctorName': rendezVous.medecinName ?? 'Unknown',
        'appointmentDate': formattedDate,
        'appointmentTime': formattedTime,
        'speciality': rendezVous.medecinSpeciality ?? '',
        'type': 'newAppointment',
        'senderId': rendezVous.patient!,
        'recipientId': rendezVous.medecin!,
        'appointmentId': rendezVous.id,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      };

      // 1. Send through NotificationBloc (primary method)
      notificationBloc!.add(
        SendNotificationEvent(
          title: 'Nouveau rendez-vous',
          body:
              '${rendezVous.patientName ?? "Un patient"} a demandé un rendez-vous pour le $formattedDate à $formattedTime',
          senderId: rendezVous.patient!,
          recipientId: rendezVous.medecin!,
          type: NotificationType.newAppointment,
          appointmentId: rendezVous.id,
          data: notificationData,
        ),
      );

      // 2. Direct method attempt using Firebase (backup)
      try {
        _directlySendNotification(
          doctorId: rendezVous.medecin!,
          title: 'Nouveau rendez-vous',
          body:
              '${rendezVous.patientName ?? "Un patient"} a demandé un rendez-vous pour le $formattedDate à $formattedTime',
          data: notificationData,
        );
      } catch (e) {
        print('Error in direct notification sending: $e');
      }

      print(
        'Sent notification for new appointment to doctor ${rendezVous.medecin}',
      );
    } else {
      print(
        'Could not send notification: ${notificationBloc == null ? "NotificationBloc is null" : "Missing patient or doctor ID"}',
      );
    }
  }

  // Helper method for direct notification sending
  Future<void> _directlySendNotification({
    required String doctorId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Query Firestore to get doctor's FCM token - check in multiple collections
      final firestore = FirebaseFirestore.instance;
      String? fcmToken;

      // Try medecins collection first
      final doctorDoc =
          await firestore.collection('medecins').doc(doctorId).get();
      if (doctorDoc.exists && doctorDoc.data()?['fcmToken'] != null) {
        fcmToken = doctorDoc.data()?['fcmToken'] as String?;
      }

      // If not found, try users collection
      if (fcmToken == null || fcmToken.isEmpty) {
        final userDoc = await firestore.collection('users').doc(doctorId).get();
        if (userDoc.exists && userDoc.data()?['fcmToken'] != null) {
          fcmToken = userDoc.data()?['fcmToken'] as String?;
        }
      }

      if (fcmToken != null && fcmToken.isNotEmpty) {
        // Send the notification directly to FCM via server
        await _sendNotificationViaServer(
          token: fcmToken,
          title: title,
          body: body,
          data: data,
        );
        print('Sent direct notification to FCM token: $fcmToken');
      } else {
        print('Could not find FCM token for doctor: $doctorId');
      }
    } catch (e) {
      print('Error in _directlySendNotification: $e');
    }
  }

  // Helper method to send notification via server
  Future<void> _sendNotificationViaServer({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Use both localhost (10.0.2.2) for emulator and the IP address for real devices
      const String baseUrl = 'http://10.0.2.2:3000/api/v1';
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully via server');
      } else {
        print('Failed to send notification via server: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification via server: $e');

      // Fall back to saving directly to Firestore
      try {
        await FirebaseFirestore.instance.collection('fcm_requests').add({
          'token': token,
          'payload': {
            'notification': {'title': title, 'body': body},
            'data': data,
          },
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Saved notification request to Firestore as fallback');
      } catch (e) {
        print('Error saving notification to Firestore: $e');
      }
    }
  }

  // Helper method for time formatting
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _sendAppointmentAcceptedNotification(RendezVousEntity rendezVous) {
    if (notificationBloc != null &&
        rendezVous.patient != null &&
        rendezVous.medecin != null) {
      notificationBloc!.add(
        SendNotificationEvent(
          title: 'Appointment Accepted',
          body:
              'Dr. ${rendezVous.medecinName ?? "Unknown"} has accepted your appointment for ${rendezVous.startDate.toString().substring(0, 10)} at ${_formatTime(rendezVous.startDate)}',
          senderId: rendezVous.medecin!,
          recipientId: rendezVous.patient!,
          type: NotificationType.appointmentAccepted,
          appointmentId: rendezVous.id,
          data: {
            'doctorName': rendezVous.medecinName ?? 'Unknown',
            'patientName': rendezVous.patientName ?? 'Unknown',
            'appointmentDate': rendezVous.startDate.toString().substring(0, 10),
            'appointmentTime': _formatTime(rendezVous.startDate),
          },
        ),
      );
    }
  }

  void _sendAppointmentRejectedNotification(RendezVousEntity rendezVous) {
    if (notificationBloc != null &&
        rendezVous.patient != null &&
        rendezVous.medecin != null) {
      notificationBloc!.add(
        SendNotificationEvent(
          title: 'Appointment Rejected',
          body:
              'Dr. ${rendezVous.medecinName ?? "Unknown"} has rejected your appointment for ${rendezVous.startDate.toString().substring(0, 10)} at ${_formatTime(rendezVous.startDate)}',
          senderId: rendezVous.medecin!,
          recipientId: rendezVous.patient!,
          type: NotificationType.appointmentRejected,
          appointmentId: rendezVous.id,
          data: {
            'doctorName': rendezVous.medecinName ?? 'Unknown',
            'patientName': rendezVous.patientName ?? 'Unknown',
            'appointmentDate': rendezVous.startDate.toString().substring(0, 10),
            'appointmentTime': _formatTime(rendezVous.startDate),
          },
        ),
      );
    }
  }
}
