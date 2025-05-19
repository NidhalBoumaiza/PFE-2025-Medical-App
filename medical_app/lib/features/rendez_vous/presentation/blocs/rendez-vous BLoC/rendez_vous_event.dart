part of 'rendez_vous_bloc.dart';

abstract class RendezVousEvent extends Equatable {
  const RendezVousEvent();

  @override
  List<Object?> get props => [];
}

class FetchRendezVous extends RendezVousEvent {
  final String? patientId;
  final String? doctorId;
  final String? appointmentId;

  const FetchRendezVous({this.patientId, this.doctorId, this.appointmentId});

  @override
  List<Object?> get props => [patientId, doctorId, appointmentId];
}

class UpdateRendezVousStatus extends RendezVousEvent {
  final String rendezVousId;
  final String status;

  const UpdateRendezVousStatus({
    required this.rendezVousId,
    required this.status,
  });

  @override
  List<Object> get props => [rendezVousId, status];
}

class CreateRendezVous extends RendezVousEvent {
  final RendezVousEntity rendezVous;

  const CreateRendezVous(this.rendezVous);

  @override
  List<Object> get props => [rendezVous];
}

class FetchDoctorsBySpecialty extends RendezVousEvent {
  final String specialty;
  final DateTime? startDate;
  final DateTime? endDate;

  const FetchDoctorsBySpecialty(this.specialty, {this.startDate, this.endDate});

  @override
  List<Object?> get props => [specialty, startDate, endDate];
}

class CancelAppointment extends RendezVousEvent {
  final String appointmentId;

  const CancelAppointment(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}

class RateDoctor extends RendezVousEvent {
  final String appointmentId;
  final double rating;

  const RateDoctor({required this.appointmentId, required this.rating});

  @override
  List<Object> get props => [appointmentId, rating];
}

class GetDoctorAppointmentsForDay extends RendezVousEvent {
  final String doctorId;
  final DateTime date;

  const GetDoctorAppointmentsForDay({
    required this.doctorId,
    required this.date,
  });

  @override
  List<Object> get props => [doctorId, date];
}

class AcceptAppointment extends RendezVousEvent {
  final String appointmentId;

  const AcceptAppointment(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}

class RefuseAppointment extends RendezVousEvent {
  final String appointmentId;

  const RefuseAppointment(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}

class CheckAndUpdatePastAppointments extends RendezVousEvent {
  final String userId;
  final String userRole;

  const CheckAndUpdatePastAppointments({
    required this.userId,
    required this.userRole,
  });

  @override
  List<Object> get props => [userId, userRole];
}
