import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_remote_data_source.dart';
import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_local_data_source.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/repositories/rendez_vous_repository.dart';
import '../models/RendezVous.dart';

class RendezVousRepositoryImpl implements RendezVousRepository {
  final RendezVousRemoteDataSource remoteDataSource;
  final RendezVousLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RendezVousRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RendezVousEntity>>> getRendezVous({
    String? patientId,
    String? doctorId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final rendezVousModels = await remoteDataSource.getRendezVous(
          patientId: patientId,
          doctorId: doctorId,
        );
        // Convert to entities (though in this case they're already entities as models extend entities)
        final rendezVousEntities = rendezVousModels;
        return Right(rendezVousEntities);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final cachedRendezVous = await localDataSource.getCachedRendezVous();
        return Right(cachedRendezVous);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> updateRendezVousStatus(
    String rendezVousId,
    String status,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateRendezVousStatus(rendezVousId, status);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> createRendezVous(
    RendezVousEntity rendezVous,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        // Create model from entity
        final rendezVousModel = RendezVousModel(
          id: rendezVous.id,
          startDate: rendezVous.startDate,
          endDate: rendezVous.endDate,
          serviceName: rendezVous.serviceName,
          patient: rendezVous.patient,
          medecin: rendezVous.medecin,
          status: rendezVous.status,
          motif: rendezVous.motif,
          notes: rendezVous.notes,
          symptoms: rendezVous.symptoms,
          isRated: rendezVous.isRated,
          hasPrescription: rendezVous.hasPrescription,
          createdAt: rendezVous.createdAt,
        );

        await remoteDataSource.createRendezVous(rendezVousModel);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, List<MedecinEntity>>> getDoctorsBySpecialty(
    String specialty, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final doctors = await remoteDataSource.getDoctorsBySpecialty(
          specialty,
          startDate: startDate,
          endDate: endDate,
        );
        return Right(doctors);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, RendezVousEntity>> getRendezVousDetails(
    String rendezVousId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final appointment = await remoteDataSource.getRendezVousDetails(
          rendezVousId,
        );
        return Right(appointment);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelAppointment(String rendezVousId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelAppointment(rendezVousId);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> rateDoctor(
    String appointmentId,
    double rating,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.rateDoctor(appointmentId, rating);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, List<RendezVousEntity>>> getDoctorAppointmentsForDay(
    String doctorId,
    DateTime date,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final appointments = await remoteDataSource.getDoctorAppointmentsForDay(
          doctorId,
          date,
        );
        return Right(appointments);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptAppointment(String rendezVousId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.acceptAppointment(rendezVousId);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> refuseAppointment(String rendezVousId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.refuseAppointment(rendezVousId);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
