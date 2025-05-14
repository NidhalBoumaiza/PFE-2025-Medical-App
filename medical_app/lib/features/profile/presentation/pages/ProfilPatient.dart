import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/cubit/theme_cubit/theme_cubit.dart';
import 'package:medical_app/features/authentication/domain/entities/patient_entity.dart';
import 'package:medical_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../authentication/presentation/pages/login_screen.dart';
import 'blocs/BLoC update profile/update_user_bloc.dart';

class ProfilePatient extends StatefulWidget {
  const ProfilePatient({Key? key}) : super(key: key);

  @override
  State<ProfilePatient> createState() => _ProfilePatientState();
}

class _ProfilePatientState extends State<ProfilePatient> {
  PatientEntity? _patient;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Français';
  final List<String> _languages = ['Français', 'English', 'العربية'];
  final Map<String, String> _languageCodes = {
    'Français': 'fr',
    'English': 'en',
    'العربية': 'ar'
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _getLanguageFromLocale(Get.locale?.languageCode ?? 'fr');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      setState(() {
        _patient = PatientEntity(
          id: userMap['id'] as String?,
          name: userMap['name'] as String,
          lastName: userMap['lastName'] as String,
          email: userMap['email'] as String,
          role: userMap['role'] as String,
          gender: userMap['gender'] as String,
          phoneNumber: userMap['phoneNumber'] as String,
          dateOfBirth: userMap['dateOfBirth'] != null
              ? DateTime.parse(userMap['dateOfBirth'] as String)
              : null,
          antecedent: userMap['antecedent'] as String,
        );
      });
    }
  }

  String _getLanguageFromLocale(String localeCode) {
    switch (localeCode) {
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'ar': return 'العربية';
      default: return 'Français';
    }
  }

  void _changeLanguage(String? newValue) {
    if (newValue != null) {
      setState(() => _selectedLanguage = newValue);
      final localeCode = _languageCodes[newValue];
      if (localeCode != null) Get.updateLocale(Locale(localeCode));
    }
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr, style: GoogleFonts.raleway(fontSize: 22.sp)),
        content: Text('confirm_logout'.tr, style: GoogleFonts.raleway(fontSize: 18.sp)),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr, style: GoogleFonts.raleway(fontSize: 16.sp)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('CACHED_USER');
                await prefs.remove('TOKEN');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Déconnexion réussie", style: GoogleFonts.raleway(fontSize: 16.sp))),
                );
                
                navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                  context,
                  const LoginScreen(),
                );
              } catch (e) {
                showErrorSnackBar(context, 'Failed to logout: $e');
              }
            },
            child: Text('logout'.tr, style: GoogleFonts.raleway(fontSize: 16.sp, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _changeProfilePicture() {
    Get.snackbar('info'.tr, 'change_profile_picture_message'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<UpdateUserBloc, UpdateUserState>(
          listener: (context, state) {
            if (state is UpdateUserSuccess) {
              setState(() {
                _patient = state.user as PatientEntity;
              });
              showSuccessSnackBar(context, 'profile_saved_successfully'.tr);
            } else if (state is UpdateUserFailure) {
              showErrorSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is UpdateUserLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
            }
            return _patient == null
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : SingleChildScrollView(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.h, bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 50.r,
                                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                                      child: Icon(
                                        Icons.person,
                                        size: 60.sp,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 32.w,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2fa7bb),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(Icons.camera_alt, color: AppColors.whiteColor, size: 18.sp),
                                        onPressed: _changeProfilePicture,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                '${_patient!.name} ${_patient!.lastName}',
                                style: GoogleFonts.raleway(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _patient!.email,
                                style: GoogleFonts.raleway(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'personal_information'.tr,
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildInfoTile('phone_number_label'.tr, _patient!.phoneNumber),
                        _buildInfoTile('gender'.tr, _patient!.gender),
                        _buildInfoTile('date_of_birth_label'.tr,
                            _patient!.dateOfBirth?.toIso8601String().split('T').first ?? 'Non spécifiée'),
                        _buildInfoTile('antecedent'.tr, _patient!.antecedent),
                        SizedBox(height: 20.h),
                        

                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.raleway(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.raleway(
                fontSize: 14.sp,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}