import 'package:get/get_navigation/src/root/internacionalization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// Language service to manage language preferences
class LanguageService {
  static const String LANGUAGE_KEY = 'app_language';

  // Save language preference
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_KEY, languageCode);
  }

  // Get saved language preference
  static Future<Locale?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(LANGUAGE_KEY);

    if (languageCode == null) return null;

    switch (languageCode) {
      case 'fr':
        return const Locale('fr', 'FR');
      case 'en':
        return const Locale('en', 'US');
      case 'ar':
        return const Locale('ar', 'AR');
      default:
        return null;
    }
  }

  // Get language name from language code
  static String getLanguageName(String localeCode) {
    switch (localeCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'Français';
    }
  }

  // Get language code from language name
  static String? getLanguageCode(String languageName) {
    switch (languageName) {
      case 'Français':
        return 'fr';
      case 'English':
        return 'en';
      case 'العربية':
        return 'ar';
      default:
        return null;
    }
  }
}

// ignore_for_file: constant_identifier_names

class AppTranslations extends Translations {
  // Define constants (French as base language)
  static const String ServerFailureMessage =
      "Une erreur est survenue, veuillez réessayer plus tard";
  static const String OfflineFailureMessage =
      "Vous n'êtes pas connecté à internet";
  static const String UnauthorizedFailureMessage =
      "Email ou mot de passe incorrect";
  static const String SignUpSuccessMessage = "Inscription réussie 😊";
  static const String InvalidEmailMessage = "L'adresse email est invalide";
  static const String PasswordMismatchMessage =
      "Les mots de passe ne correspondent pas";

  @override
  Map<String, Map<String, String>> get keys => {
    'fr_FR': {
      'title': 'Application Médicale',
      'server_failure_message': ServerFailureMessage,
      'offline_failure_message': OfflineFailureMessage,
      'unauthorized_failure_message': UnauthorizedFailureMessage,
      'sign_up_success_message': SignUpSuccessMessage,
      'invalid_email_message': InvalidEmailMessage,
      'password_mismatch_message': PasswordMismatchMessage,
      'unexpected_error_message': "Une erreur inattendue s'est produite",
      // Login and Sign-Up page strings
      'sign_in': 'Connexion',
      'email': 'Email',
      'email_hint': 'Entrez votre email',
      'password': 'Mot de passe',
      'password_hint': 'Entrez votre mot de passe',
      'forgot_password': 'Mot de passe oublié ?',
      'connect_button_text': 'Se connecter',
      'no_account': 'Pas encore de compte ?',
      'sign_up': 'S\'inscrire',
      'continue_with_google': 'Continuer avec Google',
      'email_required': 'L\'email est obligatoire',
      'password_required': 'Le mot de passe est obligatoire',
      'signup_title': 'Inscription',
      'next_button': 'Suivant',
      'name_label': 'Nom',
      'name_hint': 'Entrez votre nom',
      'first_name_label': 'Prénom',
      'first_name_hint': 'Entrez votre prénom',
      'date_of_birth_label': 'Date de naissance',
      'date_of_birth_hint': 'Sélectionnez votre date de naissance',
      'phone_number_label': 'Numéro de téléphone',
      'phone_number_hint': 'Entrez votre numéro de téléphone',
      'medical_history_label': 'Antécédents médicaux',
      'medical_history_hint': 'Décrivez vos antécédents médicaux',
      'specialty_label': 'Spécialité',
      'specialty_hint': 'Entrez votre spécialité',
      'license_number_label': 'Numéro de licence',
      'license_number_hint': 'Entrez votre numéro de licence',
      'confirm_password_label': 'Confirmer le mot de passe',
      'confirm_password_hint': 'Confirmez votre mot de passe',
      'register_button': 'S\'inscrire',
      'name_required': 'Le nom est obligatoire',
      'first_name_required': 'Le prénom est obligatoire',
      'date_of_birth_required': 'La date de naissance est obligatoire',
      'phone_number_required': 'Le numéro de téléphone est obligatoire',
      'specialty_required': 'La spécialité est obligatoire',
      'license_number_required': 'Le numéro de licence est obligatoire',
      'confirm_password_required':
          'La confirmation du mot de passe est obligatoire',
      // Consultation page strings
      'request_consultation': 'Demander une consultation',
      'select_specialty': 'Sélectionner une spécialité',
      'please_select_specialty': 'Veuillez sélectionner une spécialité',
      'select_date_time': 'Sélectionner la date et l\'heure',
      'please_select_date_time': 'Veuillez sélectionner une date et une heure',
      'search_doctors': 'Rechercher des médecins',
      'fill_all_fields': 'Veuillez remplir tous les champs',
      'consultation_request_success': 'Consultation demandée avec succès',
      'manage_consultations': 'Gérer les consultations',
      'no_consultations': 'Aucune consultation disponible',
      'patient': 'Patient',
      'start_time': 'Heure de début',
      'status': 'Statut',
      'pending': 'En attente',
      'accepted': 'Acceptée',
      'refused': 'Refusée',
      'accept': 'Accepter',
      'refuse': 'Refuser',
      // Specialty options
      'Cardiology': 'Cardiologie',
      'Dermatology': 'Dermatologie',
      'Neurology': 'Neurologie',
      'Pediatrics': 'Pédiatrie',
      'Orthopedics': 'Orthopédie',
      // Available Doctors page strings
      'available_doctors': 'Médecins disponibles',
      'no_doctors_available': 'Aucun médecin disponible',
      'doctor_name': 'Nom du médecin',
      // Settings page strings
      'settings': 'Paramètres',
      'appearance': 'Apparence',
      'language': 'Langue',
      'notifications': 'Notifications',
      'dark_mode': 'Mode sombre',
      'light_mode': 'Mode clair',
      'account': 'Compte',
      'about': 'À propos',
      'edit_profile': 'Modifier le profil',
      'change_password': 'Changer le mot de passe',
      'logout': 'Se déconnecter',
      'logout_success': 'Déconnexion réussie',
      'appointments': 'Rendez-vous',
      'medications': 'Médicaments',
      'messages': 'Messages',
      'prescriptions': 'Ordonnances',
      'copyright': '© 2023 Medical App. Tous droits réservés.',
      'appointment_duration': 'Durée de consultation (min)',
      'appointment_duration_required':
          'La durée de consultation est obligatoire',
      // Notification translations
      'no_notifications': 'Pas de notifications',
      'all_notifications_marked_as_read':
          'Toutes les notifications ont été marquées comme lues',
      'accept': 'Accepter',
      'reject': 'Refuser',
      'view_details': 'Voir les détails',
      'appointment_accepted': 'Rendez-vous accepté',
      'appointment_rejected': 'Rendez-vous refusé',
      'appointment_accepted_message':
          'Votre rendez-vous a été accepté par le médecin',
      'appointment_rejected_message':
          'Votre rendez-vous a été refusé par le médecin',
      'new_appointment': 'Nouveau rendez-vous',
      'new_prescription': 'Nouvelle ordonnance',
      'new_rating': 'Nouvelle évaluation',
      // Additional notification translations
      'mark_all_read': 'Marquer tout comme lu',
      'refresh': 'Actualiser',
      'loading_notifications': 'Chargement des notifications...',
      'you_have_no_notifications_yet':
          'Vous n\'avez pas encore de notifications',
      'no_notifications_found': 'Aucune notification trouvée',
      'try_refreshing_the_page': 'Essayez d\'actualiser la page',
      'delete_notification': 'Supprimer la notification',
      'confirm_delete_notification':
          'Êtes-vous sûr de vouloir supprimer cette notification ?',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'notification_deleted': 'Notification supprimée',
      'new': 'Nouveau',
      'appointment': 'Rendez-vous',
      'prescription': 'Ordonnance',
      'rating': 'Évaluation',
      'rejected': 'Refusé',
      // Home screen translations
      'filter_by_date': 'Filtrer par date',
      'reset_filter': 'Réinitialiser le filtre',
      'confirm_logout': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'success': 'Succès',
      'error': 'Erreur',
      'logout_error': 'Erreur lors de la déconnexion',
      'hospitals': 'Hôpitaux',
      'first_aid': 'Premiers secours',
      'payments': 'Paiements',
      'failed_to_load_profile': 'Impossible de charger le profil',
      // Payment page translations
      'payment_methods': 'Méthodes de Paiement',
      'credit_card': 'Carte de Crédit',
      'electronic_wallet': 'Portefeuille Électronique',
      // First aid screen translations
      'first_aid_title': 'Premiers Secours',
      'search_condition': 'Rechercher une condition...',
      'all': 'All',
      'emergency': 'Emergency',
      'common': 'Common',
      'children': 'Children',
      'elderly': 'Elderly',
      'description': 'Description',
      'recommended_first_aid': 'Premiers soins recommandés',
      'assess_situation': 'Évaluez la situation',
      'assess_situation_desc':
          'Assurez-vous que la zone est sécurisée et évaluez l\'état de la personne avant de procéder.',
      'call_for_help': 'Appelez à l\'aide si nécessaire',
      'call_for_help_desc':
          'En cas d\'urgence, appelez immédiatement le 15 (SAMU), 18 (Pompiers) ou 112 (numéro d\'urgence européen).',
      'administer_first_aid': 'Administrez les premiers soins',
      'administer_first_aid_desc':
          'Suivez les procédures spécifiques pour cette condition médicale.',
      'monitor_condition': 'Surveillez l\'état',
      'monitor_condition_desc':
          'Restez avec la personne et surveillez son état jusqu\'à l\'arrivée des secours.',
      'emergency_call': 'Appel d\'urgence',
      // Quiz screen translations
      'quiz': 'Quiz',
      'question': 'Question',
      'next': 'Suivant',
      'finish': 'Terminer',
      // Secours screen translations
      'no_results_found': 'Aucun résultat trouvé',
      'try_another_search': 'Essayez une autre recherche',
      // Messagerie translations
      'your_conversations':
          'Vos conversations avec les patients et les médecins apparaîtront ici',
      'yesterday': 'Hier',
      'today': 'Aujourd\'hui',
      'retry': 'Réessayer',
      'type_a_message': 'Tapez un message...',
      'no_messages_yet': 'Pas encore de messages',
      'start_conversation': 'Commencez la conversation !',
      'loading_conversations': 'Chargement des conversations...',
      'no_message': 'Aucun message',
      // First aid items
      'cpr_title': 'RCP (Support vital de base)',
      'cpr_desc':
          'Apprenez les techniques essentielles de réanimation cardio-pulmonaire dans les situations d\'urgence.',
      'bleeding_title': 'Saignements & Blessures',
      'bleeding_desc':
          'Comment traiter et gérer correctement différents types de blessures et de saignements.',
      'burns_title': 'Traitement des brûlures',
      'burns_desc':
          'Premiers soins pour différents degrés de brûlures, y compris thermiques, chimiques et électriques.',
      'choking_title': 'Étouffement',
      'choking_desc':
          'Apprenez la manœuvre de Heimlich et quoi faire quand quelqu\'un s\'étouffe.',
      'fractures_title': 'Fractures & Entorses',
      'fractures_desc':
          'Comment identifier et fournir les premiers soins pour les os cassés et les entorses.',
      // Quiz questions and answers
      'cpr_frequency_question':
          'Quelle est la fréquence recommandée des compressions thoraciques lors d\'une RCP pour un adulte ?',
      'cpr_frequency_answer1': '60-80 par minute',
      'cpr_frequency_answer2': '100-120 par minute',
      'bleeding_question':
          'Quelle est la première étape pour gérer une hémorragie externe ?',
      'bleeding_answer1': 'Appeler les secours',
      'bleeding_answer2': 'Appliquer une pression directe',
      'choking_question':
          'Que faut-il faire si une personne s\'étouffe et ne peut pas parler ?',
      'choking_answer1': 'Effectuer la manœuvre de Heimlich',
      'choking_answer2': 'Donner de l\'eau à boire',
      // Dashboard translations
      'what_are_you_looking_for': 'Que cherchez-vous ?',
      'doctors': 'Médecins',
      'pharmacies': 'Pharmacies',
      'hospitals': 'Hopitaux',
      'specialties': 'Spécialités',
      'see_all': 'Voir tout',
      'educational_first_aid_videos': 'Vidéos éducatives de premiers secours',
      'resuscitation': 'Réanimation',
      'choking': 'Étouffement',
      'bleeding': 'Saignement',
      'burns': 'Brûlures',
      'consultation_duration': 'Durée de consultation',
      'set_consultation_duration':
          'Veuillez définir la durée de vos consultations. Cette durée sera appliquée à tous vos rendez-vous.',
      'duration': 'Durée',
      'minutes': 'minutes',
      'consultation_duration_set':
          'Durée de consultation définie à {0} minutes',
      'error_loading_user_data':
          'Erreur lors du chargement des données utilisateur',
    },
    'en_US': {
      'title': 'Medical App',
      'server_failure_message': 'An error occurred, please try again later',
      'offline_failure_message': 'You are not connected to the internet',
      'unauthorized_failure_message': 'Incorrect email or password',
      'sign_up_success_message': 'Registration successful 😊',
      'invalid_email_message': 'The email address is invalid',
      'password_mismatch_message': 'Passwords do not match',
      'unexpected_error_message': 'An unexpected error occurred',
      // Login and Sign-Up page strings
      'sign_in': 'Sign In',
      'email': 'Email',
      'email_hint': 'Enter your email',
      'password': 'Password',
      'password_hint': 'Enter your password',
      'forgot_password': 'Forgot Password?',
      'connect_button_text': 'Connect',
      'no_account': 'Don\'t have an account?',
      'sign_up': 'Sign Up',
      'continue_with_google': 'Continue with Google',
      'email_required': 'Email is required',
      'password_required': 'Password is required',
      'signup_title': 'Sign Up',
      'next_button': 'Next',
      'name_label': 'Name',
      'name_hint': 'Enter your name',
      'first_name_label': 'First Name',
      'first_name_hint': 'Enter your first name',
      'date_of_birth_label': 'Date of Birth',
      'date_of_birth_hint': 'Select your date of birth',
      'phone_number_label': 'Phone Number',
      'phone_number_hint': 'Enter your phone number',
      'medical_history_label': 'Medical History',
      'medical_history_hint': 'Describe your medical history',
      'specialty_label': 'Specialty',
      'specialty_hint': 'Enter your specialty',
      'license_number_label': 'License Number',
      'license_number_hint': 'Enter your license number',
      'confirm_password_label': 'Confirm Password',
      'confirm_password_hint': 'Confirm your password',
      'register_button': 'Register',
      'name_required': 'Name is required',
      'first_name_required': 'First name is required',
      'date_of_birth_required': 'Date of birth is required',
      'phone_number_required': 'Phone number is required',
      'specialty_required': 'Specialty is required',
      'license_number_required': 'License number is required',
      'confirm_password_required': 'Password confirmation is required',
      // Consultation page strings
      'request_consultation': 'Request a Consultation',
      'select_specialty': 'Select Specialty',
      'please_select_specialty': 'Please select a specialty',
      'select_date_time': 'Select Date and Time',
      'please_select_date_time': 'Please select a date and time',
      'search_doctors': 'Search Doctors',
      'fill_all_fields': 'Please fill all fields',
      'consultation_request_success': 'Consultation requested successfully',
      'manage_consultations': 'Manage Consultations',
      'no_consultations': 'No consultations available',
      'patient': 'Patient',
      'start_time': 'Start Time',
      'status': 'Status',
      'pending': 'Pending',
      'accepted': 'Accepted',
      'refused': 'Refused',
      'accept': 'Accept',
      'refuse': 'Refuse',
      // Specialty options
      'Cardiology': 'Cardiology',
      'Dermatology': 'Dermatology',
      'Neurology': 'Neurology',
      'Pediatrics': 'Pediatrics',
      'Orthopedics': 'Orthopedics',
      // Available Doctors page strings
      'available_doctors': 'Available Doctors',
      'no_doctors_available': 'No doctors available',
      'doctor_name': 'Doctor Name',
      // Settings page strings
      'settings': 'Settings',
      'appearance': 'Appearance',
      'language': 'Language',
      'notifications': 'Notifications',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'account': 'Account',
      'about': 'About',
      'edit_profile': 'Edit Profile',
      'change_password': 'Change Password',
      'logout': 'Logout',
      'logout_success': 'Logout successful',
      'appointments': 'Appointments',
      'medications': 'Medications',
      'messages': 'Messages',
      'prescriptions': 'Prescriptions',
      'copyright': '© 2023 Medical App. All rights reserved.',
      'appointment_duration': 'Appointment Duration (min)',
      'appointment_duration_required': 'Appointment duration is required',
      // Notification translations
      'no_notifications': 'No notifications',
      'all_notifications_marked_as_read': 'All notifications marked as read',
      'accept': 'Accept',
      'reject': 'Reject',
      'view_details': 'View Details',
      'appointment_accepted': 'Appointment accepted',
      'appointment_rejected': 'Appointment rejected',
      'appointment_accepted_message':
          'Your appointment has been accepted by the doctor',
      'appointment_rejected_message':
          'Your appointment has been rejected by the doctor',
      'new_appointment': 'New appointment',
      'new_prescription': 'New prescription',
      'new_rating': 'New rating',
      // Additional notification translations
      'mark_all_read': 'Mark all as read',
      'refresh': 'Refresh',
      'loading_notifications': 'Loading notifications...',
      'you_have_no_notifications_yet': 'You have no notifications yet',
      'no_notifications_found': 'No notifications found',
      'try_refreshing_the_page': 'Try refreshing the page',
      'delete_notification': 'Delete notification',
      'confirm_delete_notification':
          'Are you sure you want to delete this notification?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'notification_deleted': 'Notification deleted',
      'new': 'New',
      'appointment': 'Appointment',
      'prescription': 'Prescription',
      'rating': 'Rating',
      'rejected': 'Rejected',
      // Home screen translations
      'filter_by_date': 'Filter by date',
      'reset_filter': 'Reset filter',
      'confirm_logout': 'Are you sure you want to log out?',
      'success': 'Success',
      'error': 'Error',
      'logout_error': 'Logout error',
      'hospitals': 'Hospitals',
      'first_aid': 'First aid',
      'payments': 'Payments',
      'failed_to_load_profile': 'Failed to load profile',
      // Payment page translations
      'payment_methods': 'Payment Methods',
      'credit_card': 'Credit Card',
      'electronic_wallet': 'Electronic Wallet',
      // First aid screen translations
      'first_aid_title': 'First Aid',
      'search_condition': 'Search for a condition...',
      'all': 'All',
      'emergency': 'Emergency',
      'common': 'Common',
      'children': 'Children',
      'elderly': 'Elderly',
      'description': 'Description',
      'recommended_first_aid': 'Recommended First Aid',
      'assess_situation': 'Assess the situation',
      'assess_situation_desc':
          'Make sure the area is safe and assess the person\'s condition before proceeding.',
      'call_for_help': 'Call for help if needed',
      'call_for_help_desc':
          'In case of emergency, immediately call emergency services (911 in the US, 112 in Europe).',
      'administer_first_aid': 'Administer first aid',
      'administer_first_aid_desc':
          'Follow specific procedures for this medical condition.',
      'monitor_condition': 'Monitor the condition',
      'monitor_condition_desc':
          'Stay with the person and monitor their condition until help arrives.',
      'emergency_call': 'Emergency Call',
      // Quiz screen translations
      'quiz': 'Quiz',
      'question': 'Question',
      'next': 'Next',
      'finish': 'Finish',
      // Secours screen translations
      'no_results_found': 'No results found',
      'try_another_search': 'Try another search',
      // Messagerie translations
      'your_conversations':
          'Your conversations with patients and doctors will appear here',
      'yesterday': 'Yesterday',
      'today': 'Today',
      'retry': 'Retry',
      'type_a_message': 'Type a message...',
      'no_messages_yet': 'No messages yet',
      'start_conversation': 'Start the conversation!',
      'loading_conversations': 'Loading conversations...',
      'no_message': 'No message',
      // First aid items
      'cpr_title': 'CPR (Basic Life Support)',
      'cpr_desc':
          'Learn essential techniques for cardiopulmonary resuscitation in emergency situations.',
      'bleeding_title': 'Bleeding & Wounds',
      'bleeding_desc':
          'How to properly treat and manage different types of wounds and bleeding.',
      'burns_title': 'Burns Treatment',
      'burns_desc':
          'First aid for different degrees of burns including thermal, chemical, and electrical burns.',
      'choking_title': 'Choking',
      'choking_desc':
          'Learn the Heimlich maneuver and what to do when someone is choking.',
      'fractures_title': 'Fractures & Sprains',
      'fractures_desc':
          'How to identify and provide initial care for broken bones and sprains.',
      // Quiz questions and answers
      'cpr_frequency_question':
          'What is the recommended frequency of chest compressions during CPR for an adult?',
      'cpr_frequency_answer1': '60-80 per minute',
      'cpr_frequency_answer2': '100-120 per minute',
      'bleeding_question':
          'What is the first step to manage external bleeding?',
      'bleeding_answer1': 'Call for help',
      'bleeding_answer2': 'Apply direct pressure',
      'choking_question':
          'What should you do if someone is choking and cannot speak?',
      'choking_answer1': 'Perform the Heimlich maneuver',
      'choking_answer2': 'Give them water to drink',
      // Dashboard translations
      'what_are_you_looking_for': 'What are you looking for?',
      'doctors': 'Doctors',
      'pharmacies': 'Pharmacies',
      'hospitals': 'Hospitals',
      'specialties': 'Specialties',
      'see_all': 'See all',
      'educational_first_aid_videos': 'Educational First Aid Videos',
      'resuscitation': 'Resuscitation',
      'choking': 'Choking',
      'bleeding': 'Bleeding',
      'burns': 'Burns',
      'consultation_duration': 'Consultation Duration',
      'set_consultation_duration':
          'Please set the duration of your consultations. This duration will be applied to all your appointments.',
      'duration': 'Duration',
      'minutes': 'minutes',
      'consultation_duration_set': 'Consultation duration set to {0} minutes',
      'error_loading_user_data': 'Error loading user data',
    },
    'ar_AR': {
      'title': 'تطبيق طبي',
      'server_failure_message': 'حدث خطأ، يرجى المحاولة مرة أخرى لاحقًا',
      'offline_failure_message': 'أنت غير متصل بالإنترنت',
      'unauthorized_failure_message':
          'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      'sign_up_success_message': 'التسجيل ناجح 😊',
      'invalid_email_message': 'عنوان البريد الإلكتروني غير صالح',
      'password_mismatch_message': 'كلمتا المرور غير متطابقتين',
      'unexpected_error_message': 'حدث خطأ غير متوقع',
      // Login and Sign-Up page strings
      'sign_in': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'email_hint': 'أدخل بريدك الإلكتروني',
      'password': 'كلمة المرور',
      'password_hint': 'أدخل كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'connect_button_text': 'الاتصال',
      'no_account': 'ليس لديك حساب؟',
      'sign_up': 'اشترك',
      'continue_with_google': 'المتابعة مع جوجل',
      'email_required': 'البريد الإلكتروني مطلوب',
      'password_required': 'كلمة المرور مطلوبة',
      'signup_title': 'التسجيل',
      'next_button': 'التالي',
      'name_label': 'الاسم',
      'name_hint': 'أدخل اسمك',
      'first_name_label': 'الاسم الأول',
      'first_name_hint': 'أدخل اسمك الأول',
      'date_of_birth_label': 'تاريخ الميلاد',
      'date_of_birth_hint': 'حدد تاريخ ميلادك',
      'phone_number_label': 'رقم الهاتف',
      'phone_number_hint': 'أدخل رقم هاتفك',
      'medical_history_label': 'التاريخ الطبي',
      'medical_history_hint': 'صف تاريخك الطبي',
      'specialty_label': 'التخصص',
      'specialty_hint': 'أدخل تخصصك',
      'license_number_label': 'رقم الرخصة',
      'license_number_hint': 'أدخل رقم رخصتك',
      'confirm_password_label': 'تأكيد كلمة المرور',
      'confirm_password_hint': 'تأكيد كلمة المرور الخاصة بك',
      'register_button': 'تسجيل',
      'name_required': 'الاسم مطلوب',
      'first_name_required': 'الاسم الأول مطلوب',
      'date_of_birth_required': 'تاريخ الميلاد مطلوب',
      'phone_number_required': 'رقم الهاتف مطلوب',
      'specialty_required': 'التخصص مطلوب',
      'license_number_required': 'رقم الرخصة مطلوب',
      'confirm_password_required': 'تأكيد كلمة المرور مطلوب',
      // Consultation page strings
      'request_consultation': 'طلب استشارة',
      'select_specialty': 'اختر التخصص',
      'please_select_specialty': 'يرجى اختيار تخصص',
      'select_date_time': 'اختر التاريخ والوقت',
      'please_select_date_time': 'يرجى اختيار تاريخ ووقت',
      'search_doctors': 'البحث عن أطباء',
      'fill_all_fields': 'يرجى ملء جميع الحقول',
      'consultation_request_success': 'تم طلب الاستشارة بنجاح',
      'manage_consultations': 'إدارة الاستشارات',
      'no_consultations': 'لا توجد استشارات متاحة',
      'patient': 'المريض',
      'start_time': 'وقت البدء',
      'status': 'الحالة',
      'pending': 'قيد الانتظار',
      'accepted': 'مقبول',
      'refused': 'مرفوض',
      'accept': 'قبول',
      'refuse': 'رفض',
      // Specialty options
      'Cardiology': 'طب القلب',
      'Dermatology': 'طب الجلد',
      'Neurology': 'طب الأعصاب',
      'Pediatrics': 'طب الأطفال',
      'Orthopedics': 'جراحة العظام',
      // Available Doctors page strings
      'available_doctors': 'الأطباء المتاحون',
      'no_doctors_available': 'لا يوجد أطباء متاحون',
      'doctor_name': 'اسم الطبيب',
      // Settings page strings
      'settings': 'الإعدادات',
      'appearance': 'المظهر',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'dark_mode': 'الوضع المظلم',
      'light_mode': 'الوضع الفاتح',
      'account': 'الحساب',
      'about': 'حول',
      'edit_profile': 'تعديل الملف الشخصي',
      'change_password': 'تغيير كلمة المرور',
      'logout': 'تسجيل الخروج',
      'logout_success': 'تم تسجيل الخروج بنجاح',
      'appointments': 'المواعيد',
      'medications': 'الأدوية',
      'messages': 'الرسائل',
      'prescriptions': 'الوصفات الطبية',
      'copyright': '© 2023 تطبيق طبي. جميع الحقوق محفوظة.',
      'appointment_duration': 'مدة الموعد (دقيقة)',
      'appointment_duration_required': 'مدة الموعد مطلوبة',
      // Notification translations
      'no_notifications': 'لا توجد إشعارات',
      'all_notifications_marked_as_read':
          'تم وضع علامة على جميع الإشعارات كمقروءة',
      'accept': 'قبول',
      'reject': 'رفض',
      'view_details': 'عرض التفاصيل',
      'appointment_accepted': 'تم قبول الموعد',
      'appointment_rejected': 'تم رفض الموعد',
      'appointment_accepted_message': 'تم قبول الموعد بواسطة الطبيب',
      'appointment_rejected_message': 'تم رفض الموعد بواسطة الطبيب',
      'new_appointment': 'موعد جديد',
      'new_prescription': 'وصفة طبية جديدة',
      'new_rating': 'تقييم جديد',
      // Additional notification translations
      'mark_all_read': 'وضع علامة على الكل كمقروء',
      'refresh': 'تحديث',
      'loading_notifications': 'جاري تحميل الإشعارات...',
      'you_have_no_notifications_yet': 'ليس لديك إشعارات حتى الآن',
      'no_notifications_found': 'لم يتم العثور على إشعارات',
      'try_refreshing_the_page': 'حاول تحديث الصفحة',
      'delete_notification': 'حذف الإشعار',
      'confirm_delete_notification': 'هل أنت متأكد أنك تريد حذف هذا الإشعار؟',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'notification_deleted': 'تم حذف الإشعار',
      'new': 'جديد',
      'appointment': 'موعد',
      'prescription': 'وصفة طبية',
      'rating': 'تقييم',
      'rejected': 'مرفوض',
      // Home screen translations
      'filter_by_date': 'تصفية بالتاريخ',
      'reset_filter': 'إعادة تعيين التصفية',
      'confirm_logout': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'success': 'نجاح',
      'error': 'خطأ',
      'logout_error': 'خطأ عند تسجيل الخروج',
      'hospitals': 'مستشفيات',
      'first_aid': 'المساعدة الأولية',
      'payments': 'الدفعات',
      'failed_to_load_profile': 'فشل في تحميل الملف الشخصي',
      // Payment page translations
      'payment_methods': 'طرق الدفع',
      'credit_card': 'بطاقة ائتمان',
      'electronic_wallet': 'محفظة إلكترونية',
      // First aid screen translations
      'first_aid_title': 'الإسعافات الأولية',
      'search_condition': 'البحث عن حالة...',
      'all': 'الكل',
      'emergency': 'طوارئ',
      'common': 'شائع',
      'children': 'أطفال',
      'elderly': 'كبار السن',
      'description': 'الوصف',
      'recommended_first_aid': 'الإسعافات الأولية الموصى بها',
      'assess_situation': 'تقييم الوضع',
      'assess_situation_desc':
          'تأكد من أن المنطقة آمنة وقيّم حالة الشخص قبل المتابعة.',
      'call_for_help': 'اطلب المساعدة إذا لزم الأمر',
      'call_for_help_desc': 'في حالة الطوارئ، اتصل فوراً بخدمات الطوارئ.',
      'administer_first_aid': 'تقديم الإسعافات الأولية',
      'administer_first_aid_desc': 'اتبع الإجراءات المحددة لهذه الحالة الطبية.',
      'monitor_condition': 'مراقبة الحالة',
      'monitor_condition_desc': 'ابق مع الشخص وراقب حالته حتى وصول المساعدة.',
      'emergency_call': 'مكالمة طوارئ',
      // Quiz screen translations
      'quiz': 'اختبار',
      'question': 'سؤال',
      'next': 'التالي',
      'finish': 'إنهاء',
      // Secours screen translations
      'no_results_found': 'لم يتم العثور على نتائج',
      'try_another_search': 'حاول البحث مرة أخرى',
      // Messagerie translations
      'your_conversations': 'ستظهر محادثاتك مع المرضى والأطباء هنا',
      'yesterday': 'أمس',
      'today': 'اليوم',
      'retry': 'إعادة المحاولة',
      'type_a_message': 'اكتب رسالة...',
      'no_messages_yet': 'لا توجد رسائل حتى الآن',
      'start_conversation': 'ابدأ المحادثة!',
      'loading_conversations': 'جاري تحميل المحادثات...',
      'no_message': 'لا توجد رسالة',
      // First aid items
      'cpr_title': 'الإنعاش القلبي الرئوي (دعم الحياة الأساسي)',
      'cpr_desc':
          'تعلم التقنيات الأساسية للإنعاش القلبي الرئوي في حالات الطوارئ.',
      'bleeding_title': 'النزيف والجروح',
      'bleeding_desc':
          'كيفية علاج وإدارة أنواع مختلفة من الجروح والنزيف بشكل صحيح.',
      'burns_title': 'علاج الحروق',
      'burns_desc':
          'الإسعافات الأولية لدرجات مختلفة من الحروق بما في ذلك الحرارية والكيميائية والكهربائية.',
      'choking_title': 'الاختناق',
      'choking_desc': 'تعلم مناورة هايمليش وما يجب فعله عندما يختنق شخص ما.',
      'fractures_title': 'الكسور والالتواءات',
      'fractures_desc':
          'كيفية تحديد وتقديم الرعاية الأولية للعظام المكسورة والالتواءات.',
      // Quiz questions and answers
      'cpr_frequency_question':
          'ما هي الوتيرة الموصى بها لضغطات الصدر أثناء الإنعاش القلبي الرئوي للبالغين؟',
      'cpr_frequency_answer1': '60-80 في الدقيقة',
      'cpr_frequency_answer2': '100-120 في الدقيقة',
      'bleeding_question': 'ما هي الخطوة الأولى للتعامل مع النزيف الخارجي؟',
      'bleeding_answer1': 'طلب المساعدة',
      'bleeding_answer2': 'تطبيق الضغط المباشر',
      'choking_question':
          'ماذا يجب أن تفعل إذا كان شخص ما يختنق ولا يستطيع التحدث؟',
      'choking_answer1': 'تنفيذ مناورة هايمليش',
      'choking_answer2': 'إعطاؤهم الماء للشرب',
      // Dashboard translations
      'what_are_you_looking_for': 'عن ماذا تبحث؟',
      'doctors': 'أطباء',
      'pharmacies': 'صيدليات',
      'hospitals': 'مستشفيات',
      'specialties': 'تخصصات',
      'see_all': 'عرض الكل',
      'educational_first_aid_videos': 'فيديوهات تعليمية للإسعافات الأولية',
      'resuscitation': 'الإنعاش',
      'choking': 'الاختناق',
      'bleeding': 'النزيف',
      'burns': 'الحروق',
      'consultation_duration': 'مدة الاستشارة',
      'set_consultation_duration':
          'يرجى تحديد مدة استشاراتك. سيتم تطبيق هذه المدة على جميع مواعيدك.',
      'duration': 'المدة',
      'minutes': 'دقائق',
      'consultation_duration_set': 'تم تحديد مدة الاستشارة إلى {0} دقيقة',
      'error_loading_user_data': 'خطأ في تحميل بيانات المستخدم',
    },
  };
}
