import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';

abstract class RendezVousRepository {
  Future<Either<Failure, List<RendezVousEntity>>> getRendezVous({
    String? patientId,
    String? doctorId,
  });

  Future<Either<Failure, Unit>> updateRendezVousStatus(
    String rendezVousId,
    String status,
  );

  Future<Either<Failure, Unit>> createRendezVous(RendezVousEntity rendezVous);

  Future<Either<Failure, List<MedecinEntity>>> getDoctorsBySpecialty(
    String specialty, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, RendezVousEntity>> getRendezVousDetails(
    String rendezVousId,
  );

  Future<Either<Failure, Unit>> cancelAppointment(String rendezVousId);

  Future<Either<Failure, Unit>> rateDoctor(String appointmentId, double rating);

  Future<Either<Failure, List<RendezVousEntity>>> getDoctorAppointmentsForDay(
    String doctorId,
    DateTime date,
  );

  Future<Either<Failure, Unit>> acceptAppointment(String rendezVousId);

  Future<Either<Failure, Unit>> refuseAppointment(String rendezVousId);
}
