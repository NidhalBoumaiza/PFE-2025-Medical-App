/// Global application constants
class AppConstants {
  // API Base URL (use 10.0.2.2 for emulator, or your server IP for physical devices)
  static const String baseUrl = 'http://192.168.1.18:3001/api/v1';

  // API Endpoints
  // User and Authentication endpoints
  static String get usersEndpoint => '$baseUrl/users';
  static String get loginEndpoint => '$baseUrl/users/login';
  static String get signupEndpoint => '$baseUrl/users/signup';
  static String get verifyAccountEndpoint => '$baseUrl/users/verifyAccount';
  static String get forgotPasswordEndpoint => '$baseUrl/users/forgotPassword';
  static String get verifyResetCodeEndpoint => '$baseUrl/users/verifyResetCode';
  static String get resetPasswordEndpoint => '$baseUrl/users/resetPassword';
  static String get updatePasswordEndpoint => '$baseUrl/users/updateMyPassword';
  static String get updateProfileEndpoint => '$baseUrl/users/updateMe';
  static String get getUserProfileEndpoint => '$baseUrl/users/me';
  static String get updateOneSignalPlayerIdEndpoint =>
      '$baseUrl/users/updateOneSignalPlayerId';
  static String get getAllDoctorsEndpoint => '$baseUrl/users/doctors';
  static String get getDoctorEndpoint =>
      '$baseUrl/users/doctors'; // Add ID when calling

  // Appointment endpoints
  static String get appointmentsEndpoint => '$baseUrl/appointments';

  // Conversation and messaging endpoints
  static String get conversationsEndpoint => '$baseUrl/conversations';

  // Notification endpoints
  static String get notificationsEndpoint => '$baseUrl/notifications';
  static String get myNotificationsEndpoint =>
      '$baseUrl/notifications/my-notifications';
  static String get markNotificationReadEndpoint =>
      '$baseUrl/notifications/mark-read'; // Add ID when calling
  static String get markAllNotificationsReadEndpoint =>
      '$baseUrl/notifications/mark-all-read';
  static String get unreadNotificationsCountEndpoint =>
      '$baseUrl/notifications/unread-count';

  // Dashboard endpoints
  static String get dashboardEndpoint => '$baseUrl/dashboard';

  // Prescription endpoints
  static String get prescriptionsEndpoint => '$baseUrl/prescriptions';

  // Rating endpoints
  static String get ratingsEndpoint => '$baseUrl/ratings';

  // Speciality endpoints
  static String get specialitiesEndpoint => '$baseUrl/specialities';

  // Medical records endpoints
  static String get medicalRecordsEndpoint => '$baseUrl/medical-records';

  // Dossier Medical endpoints
  static String get dossierMedicalEndpoint => '$baseUrl/dossier-medical';

  // Other endpoints
  static String get refreshTokenEndpoint => '$baseUrl/users/refreshToken';

  // OneSignal Configuration
  static String get oneSignalAppId =>
      'YOUR-ONESIGNAL-APP-ID'; // Replace with your actual OneSignal App ID
}
