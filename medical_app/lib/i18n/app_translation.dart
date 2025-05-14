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
  static const String SignUpSuccessMessage =
      "Inscription réussie 😊";
  static const String InvalidEmailMessage =
      "L'adresse email est invalide";
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
      'confirm_password_required': 'La confirmation du mot de passe est obligatoire',
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
      'appointment_duration_required': 'La durée de consultation est obligatoire',
      // Notification translations
      'no_notifications': 'Pas de notifications',
      'all_notifications_marked_as_read': 'Toutes les notifications ont été marquées comme lues',
      'accept': 'Accepter',
      'reject': 'Refuser',
      'view_details': 'Voir les détails',
      'appointment_accepted': 'Rendez-vous accepté',
      'appointment_rejected': 'Rendez-vous refusé',
      'new_appointment': 'Nouveau rendez-vous',
      'new_prescription': 'Nouvelle ordonnance',
      'new_rating': 'Nouvelle évaluation',
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
      'new_appointment': 'New appointment',
      'new_prescription': 'New prescription',
      'new_rating': 'New rating',
    },
    'ar_AR': {
      'title': 'تطبيق طبي',
      'server_failure_message': 'حدث خطأ، يرجى المحاولة مرة أخرى لاحقًا',
      'offline_failure_message': 'أنت غير متصل بالإنترنت',
      'unauthorized_failure_message': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
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
      'all_notifications_marked_as_read': 'تم وضع علامة على جميع الإشعارات كمقروءة',
      'accept': 'قبول',
      'reject': 'رفض',
      'view_details': 'عرض التفاصيل',
      'appointment_accepted': 'تم قبول الموعد',
      'appointment_rejected': 'تم رفض الموعد',
      'new_appointment': 'موعد جديد',
      'new_prescription': 'وصفة طبية جديدة',
      'new_rating': 'تقييم جديد',
    },
  };
}