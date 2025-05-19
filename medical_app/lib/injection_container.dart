import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/core/services/api_service.dart';
import 'package:medical_app/core/utils/constants.dart';
import 'package:medical_app/cubit/theme_cubit/theme_cubit.dart';
import 'package:medical_app/cubit/toggle%20cubit/toggle_cubit.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_local_data_source.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_remote_data_source.dart';
import 'package:medical_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:medical_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:medical_app/features/authentication/domain/usecases/create_account_use_case.dart';
import 'package:medical_app/features/authentication/domain/usecases/send_verification_code_use_case.dart';
import 'package:medical_app/features/authentication/domain/usecases/change_password_use_case.dart';
import 'package:medical_app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:medical_app/features/authentication/domain/usecases/update_user_use_case.dart';
import 'package:medical_app/features/authentication/domain/usecases/verify_code_use_case.dart';
import 'package:medical_app/features/authentication/presentation/blocs/Signup%20BLoC/signup_bloc.dart';
import 'package:medical_app/features/authentication/presentation/blocs/login%20BLoC/login_bloc.dart';
import 'package:medical_app/features/messagerie/data/data_sources/message_local_datasource.dart';
import 'package:medical_app/features/messagerie/data/data_sources/message_remote_datasource.dart';
import 'package:medical_app/features/messagerie/data/repositories/message_repository_impl.dart';
import 'package:medical_app/features/messagerie/domain/repositories/message_repository.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_message.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_messages_stream_usecase.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_conversations_use_case.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/send_message_use_case.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation%20BLoC/conversations_bloc.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/messageries%20BLoC/messagerie_bloc.dart';

// New Messagerie Feature imports
import 'package:medical_app/features/messagerie/data/data_sources/conversation_api_data_source.dart';
import 'package:medical_app/features/messagerie/data/data_sources/socket_service.dart';
import 'package:medical_app/features/messagerie/data/repositories/conversation_repository_impl.dart';
import 'package:medical_app/features/messagerie/domain/repositories/conversation_repository.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/connect_to_socket.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_conversations.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_messages.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/mark_messages_as_read.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/send_message.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/message/message_bloc.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/socket/socket_bloc.dart';
import 'package:medical_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';

import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_local_data_source.dart';
import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_remote_data_source.dart';
import 'package:medical_app/features/rendez_vous/data/repositories/rendez_vous_repository_impl.dart';
import 'package:medical_app/features/rendez_vous/domain/repositories/rendez_vous_repository.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/create_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_doctors_by_specialty_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/update_rendez_vous_status_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/cancel_appointment_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/rate_doctor_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/get_doctor_appointments_for_day_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/accept_appointment_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/refuse_appointment_use_case.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/authentication/presentation/blocs/forget password bloc/forgot_password_bloc.dart';
import 'features/authentication/presentation/blocs/reset password bloc/reset_password_bloc.dart';
import 'features/authentication/presentation/blocs/verify code bloc/verify_code_bloc.dart';
import 'features/profile/presentation/pages/blocs/BLoC update profile/update_user_bloc.dart';
import 'package:medical_app/features/ratings/data/datasources/rating_remote_datasource.dart';
import 'package:medical_app/features/ratings/data/repositories/rating_repository_impl.dart';
import 'package:medical_app/features/ratings/domain/repositories/rating_repository.dart';
import 'package:medical_app/features/ratings/domain/usecases/submit_doctor_rating_use_case.dart';
import 'package:medical_app/features/ratings/domain/usecases/has_patient_rated_appointment_use_case.dart';
import 'package:medical_app/features/ratings/presentation/bloc/rating_bloc.dart';
import 'package:medical_app/features/ratings/domain/usecases/get_doctor_ratings_use_case.dart';
import 'package:medical_app/features/ratings/domain/usecases/get_doctor_average_rating_use_case.dart';
import 'package:medical_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:medical_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:medical_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:medical_app/features/dashboard/domain/usecases/get_doctor_dashboard_stats_use_case.dart';
import 'package:medical_app/features/dashboard/domain/usecases/get_upcoming_appointments_use_case.dart';
import 'package:medical_app/features/dashboard/presentation/blocs/dashboard%20BLoC/dashboard_bloc.dart';
import 'package:medical_app/features/ordonnance/data/datasources/prescription_remote_datasource.dart';
import 'package:medical_app/features/ordonnance/data/repositories/prescription_repository_impl.dart';
import 'package:medical_app/features/ordonnance/domain/repositories/prescription_repository.dart';
import 'package:medical_app/features/ordonnance/domain/usecases/create_prescription_use_case.dart';
import 'package:medical_app/features/ordonnance/domain/usecases/edit_prescription_use_case.dart';
import 'package:medical_app/features/ordonnance/domain/usecases/get_doctor_prescriptions_use_case.dart';
import 'package:medical_app/features/ordonnance/domain/usecases/get_patient_prescriptions_use_case.dart';
import 'package:medical_app/features/ordonnance/domain/usecases/get_prescription_by_appointment_id_use_case.dart';
import 'package:medical_app/features/ordonnance/domain/usecases/get_prescription_by_id_use_case.dart';
import 'package:medical_app/features/ordonnance/domain/usecases/update_prescription_status_use_case.dart';
import 'package:medical_app/features/ordonnance/presentation/bloc/prescription_bloc.dart';
import 'package:medical_app/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:medical_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:medical_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:medical_app/features/notifications/domain/usecases/delete_notification_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/get_unread_notifications_count_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/mark_all_notifications_as_read_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/send_notification_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/initialize_onesignal_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/set_external_user_id_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/get_onesignal_player_id_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/save_onesignal_player_id_use_case.dart';
import 'package:medical_app/features/notifications/domain/usecases/logout_onesignal_use_case.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:medical_app/features/notifications/utils/onesignal_service.dart';
import 'package:medical_app/features/authentication/presentation/blocs/update_password_bloc/update_password_bloc.dart';
import 'package:medical_app/features/authentication/domain/usecases/update_password_direct_use_case.dart';
import 'package:medical_app/features/dossier_medical/data/datasources/dossier_medical_remote_datasource.dart';
import 'package:medical_app/features/dossier_medical/data/repositories/dossier_medical_repository_impl.dart';
import 'package:medical_app/features/dossier_medical/domain/repositories/dossier_medical_repository.dart';
import 'package:medical_app/features/dossier_medical/domain/usecases/get_dossier_medical.dart';
import 'package:medical_app/features/dossier_medical/domain/usecases/has_dossier_medical.dart';
import 'package:medical_app/features/dossier_medical/presentation/bloc/dossier_medical_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs and Cubits
  sl.registerFactory(() => ThemeCubit());
  sl.registerFactory(() => LoginBloc(loginUseCase: sl()));
  sl.registerFactory(() => SignupBloc(createAccountUseCase: sl()));
  sl.registerFactory(() => UpdateUserBloc(updateUserUseCase: sl()));
  sl.registerFactory(() => ToggleCubit());
  sl.registerFactory(
    () => ForgotPasswordBloc(sendVerificationCodeUseCase: sl()),
  );
  sl.registerFactory(() => VerifyCodeBloc(verifyCodeUseCase: sl()));
  sl.registerFactory(() => ResetPasswordBloc(changePasswordUseCase: sl()));
  sl.registerFactory(
    () => UpdatePasswordBloc(updatePasswordDirectUseCase: sl()),
  );
  sl.registerFactory(
    () => RendezVousBloc(
      fetchRendezVousUseCase: sl(),
      updateRendezVousStatusUseCase: sl(),
      createRendezVousUseCase: sl(),
      fetchDoctorsBySpecialtyUseCase: sl(),
      cancelAppointmentUseCase: sl(),
      rateDoctorUseCase: sl(),
      getDoctorAppointmentsForDayUseCase: sl(),
      acceptAppointmentUseCase: sl(),
      refuseAppointmentUseCase: sl(),
      notificationBloc: sl<NotificationBloc>(),
    ),
  );

  // Legacy Messaging
  sl.registerFactory(() => ConversationsBloc(getConversationsUseCase: sl()));
  sl.registerFactory(
    () => MessagerieBloc(
      sendMessageUseCase: sl(),
      getMessagesUseCase: sl(),
      getMessagesStreamUseCase: sl(),
    ),
  );

  // New Messagerie Feature BLoCs
  sl.registerFactory(
    () => ConversationBloc(getConversations: sl(), getCurrentUser: sl()),
  );

  sl.registerFactory(
    () => MessageBloc(
      getMessages: sl(),
      sendMessage: sl(),
      markMessagesAsRead: sl(),
      getCurrentUser: sl(),
    ),
  );

  sl.registerFactory(
    () =>
        SocketBloc(connectToSocket: sl(), repository: sl(), messageBloc: sl()),
  );

  // Dashboard BLoC
  sl.registerFactory(
    () => DashboardBloc(
      getDoctorDashboardStatsUseCase: sl(),
      getUpcomingAppointmentsUseCase: sl(),
    ),
  );

  // Prescription BLoC
  sl.registerFactory(
    () => PrescriptionBloc(
      createPrescriptionUseCase: sl(),
      editPrescriptionUseCase: sl(),
      getPatientPrescriptionsUseCase: sl(),
      getDoctorPrescriptionsUseCase: sl(),
      getPrescriptionByIdUseCase: sl(),
      getPrescriptionByAppointmentIdUseCase: sl(),
      updatePrescriptionStatusUseCase: sl(),
      notificationBloc: sl<NotificationBloc>(),
    ),
  );

  // Notification BLoC
  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      sendNotificationUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
      markAllNotificationsAsReadUseCase: sl(),
      deleteNotificationUseCase: sl(),
      getUnreadNotificationsCountUseCase: sl(),
      initializeOneSignalUseCase: sl(),
      setExternalUserIdUseCase: sl(),
      getOneSignalPlayerIdUseCase: sl(),
      saveOneSignalPlayerIdUseCase: sl(),
      logoutOneSignalUseCase: sl(),
    ),
  );

  // Rating BLoC
  sl.registerFactory(
    () => RatingBloc(
      submitDoctorRatingUseCase: sl(),
      hasPatientRatedAppointmentUseCase: sl(),
      getDoctorRatingsUseCase: sl(),
      getDoctorAverageRatingUseCase: sl(),
    ),
  );

  // Dossier Medical BLoC
  sl.registerFactory(
    () => DossierMedicalBloc(
      repository: sl(),
      getDossierMedicalUseCase: sl(),
      hasDossierMedicalUseCase: sl(),
    ),
  );

  // Use Cases - Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CreateAccountUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCodeUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => SendVerificationCodeUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordDirectUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Use Cases - Rendez-vous
  sl.registerLazySingleton(() => FetchRendezVousUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRendezVousStatusUseCase(sl()));
  sl.registerLazySingleton(() => CreateRendezVousUseCase(sl()));
  sl.registerLazySingleton(() => FetchDoctorsBySpecialtyUseCase(sl()));
  sl.registerLazySingleton(() => CancelAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => RateDoctorUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorAppointmentsForDayUseCase(sl()));
  sl.registerLazySingleton(() => AcceptAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => RefuseAppointmentUseCase(sl()));

  // Use Cases - Legacy Messaging
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesStreamUseCase(sl()));

  // Use Cases - New Messagerie Feature
  sl.registerLazySingleton(() => GetConversations(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => MarkMessagesAsRead(sl()));
  sl.registerLazySingleton(() => ConnectToSocket(sl()));

  // Dashboard Use Cases
  sl.registerLazySingleton(() => GetDoctorDashboardStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetUpcomingAppointmentsUseCase(sl()));

  // Prescription Use Cases
  sl.registerLazySingleton(() => CreatePrescriptionUseCase(sl()));
  sl.registerLazySingleton(() => EditPrescriptionUseCase(sl()));
  sl.registerLazySingleton(() => GetPatientPrescriptionsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorPrescriptionsUseCase(sl()));
  sl.registerLazySingleton(() => GetPrescriptionByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetPrescriptionByAppointmentIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePrescriptionStatusUseCase(sl()));

  // Notification Use Cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => SendNotificationUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationsCountUseCase(sl()));
  sl.registerLazySingleton(() => InitializeOneSignalUseCase(sl()));
  sl.registerLazySingleton(() => SetExternalUserIdUseCase(sl()));
  sl.registerLazySingleton(() => GetOneSignalPlayerIdUseCase(sl()));
  sl.registerLazySingleton(() => SaveOneSignalPlayerIdUseCase(sl()));
  sl.registerLazySingleton(() => LogoutOneSignalUseCase(sl()));

  // Rating Use Cases
  sl.registerLazySingleton(() => SubmitDoctorRatingUseCase(sl()));
  sl.registerLazySingleton(() => HasPatientRatedAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorRatingsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorAverageRatingUseCase(sl()));

  // Dossier Medical Use Cases
  sl.registerLazySingleton(() => GetDossierMedical(sl()));
  sl.registerLazySingleton(() => HasDossierMedical(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<RendezVousRepository>(
    () => RendezVousRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<MessagingRepository>(
    () => MessagingRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(
      apiDataSource: sl(),
      socketService: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<PrescriptionRepository>(
    () => PrescriptionRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<RatingRepository>(
    () => RatingRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<DossierMedicalRepository>(
    () =>
        DossierMedicalRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(localDataSource: sl(), client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<RendezVousRemoteDataSource>(
    () => RendezVousRemoteDataSourceImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<RendezVousLocalDataSource>(
    () => RendezVousLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<MessagingRemoteDataSource>(
    () => MessagingRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );
  sl.registerLazySingleton<MessagingLocalDataSource>(
    () => MessagingLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ConversationApiDataSource>(
    () => ConversationApiDataSourceImpl(
      client: sl(),
      baseUrl: kBaseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${sl<SharedPreferences>().getString(kTokenKey) ?? ''}',
      },
    ),
  );
  sl.registerLazySingleton<SocketService>(
    () => SocketService(
      currentUser: UserEntity(
        id: sl<SharedPreferences>().getString(kUserIdKey),
        name: sl<SharedPreferences>().getString(kUserNameKey) ?? 'User',
        lastName: '',
        email: sl<SharedPreferences>().getString(kUserEmailKey) ?? '',
        role: sl<SharedPreferences>().getString(kUserRoleKey) ?? 'patient',
        gender: 'unknown',
        phoneNumber: '',
        token: sl<SharedPreferences>().getString(kTokenKey),
      ),
      networkInfo: sl(),
      baseUrl: kSocketUrl,
    ),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => MongoDBDashboardRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<PrescriptionRemoteDataSource>(
    () => PrescriptionRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () =>
        NotificationRemoteDataSourceImpl(client: sl(), oneSignalService: sl()),
  );
  sl.registerLazySingleton<RatingRemoteDataSource>(
    () => RatingRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<DossierMedicalRemoteDataSource>(
    () => DossierMedicalRemoteDataSourceImpl(client: sl()),
  );

  // Services
  sl.registerLazySingleton<OneSignalService>(() => OneSignalService());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.instance,
  );
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => ApiService());
}
