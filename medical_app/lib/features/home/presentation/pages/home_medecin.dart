import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/cubit/theme_cubit/theme_cubit.dart';
import 'package:medical_app/features/authentication/presentation/pages/login_screen.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_medecin.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_medecin.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilMedecin.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/appointments_medecins.dart';
import 'package:medical_app/features/settings/presentation/pages/SettingsPage.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';
import 'package:medical_app/widgets/theme_cubit_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localisation/presentation/pages/pharmacie_page.dart';
import '../../../messagerie/presentation/pages/conversations_list_screen.dart';
import '../../../profile/presentation/pages/blocs/BLoC%20update%20profile/update_user_bloc.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';

class HomeMedecin extends StatefulWidget {
  const HomeMedecin({super.key});

  @override
  State<HomeMedecin> createState() => _HomeMedecinState();
}

class _HomeMedecinState extends State<HomeMedecin> {
  int selectedItem = 0;
  String userId = '';
  String doctorName = 'Dr. Unknown';
  String email = 'doctor@example.com';
  DateTime? selectedAppointmentDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      setState(() {
        userId = userMap['id'] as String? ?? '';
        doctorName = '${userMap['name'] ?? ''} ${userMap['lastName'] ?? ''}'.trim();
        email = userMap['email'] as String? ?? 'doctor@example.com';
      });
    }
  }

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: 22.sp),
      activeIcon: Icon(Icons.home_filled, size: 24.sp),
      label: 'home'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined, size: 22.sp),
      activeIcon: Icon(Icons.calendar_today, size: 24.sp),
      label: 'appointments'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline, size: 22.sp),
      activeIcon: Icon(Icons.chat_bubble, size: 24.sp),
      label: 'messages'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline, size: 22.sp),
      activeIcon: Icon(Icons.person, size: 24.sp),
      label: 'profile'.tr,
    ),
  ];

  late List<Widget> pages = [
    const DashboardMedecin(),
    AppointmentsMedecins(initialSelectedDate: selectedAppointmentDate, showAppBar: false),
    const ConversationsScreen(showAppBar: false),
    const ProfilMedecin(),
  ];

  // Function to display date picker
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedAppointmentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past year
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedAppointmentDate) {
      setState(() {
        selectedAppointmentDate = picked;
        _updatePages();
      });
    }
  }

  // Update pages with the new selected date
  void _updatePages() {
    setState(() {
      pages = [
        const DashboardMedecin(),
        AppointmentsMedecins(initialSelectedDate: selectedAppointmentDate, showAppBar: false),
        const ConversationsScreen(showAppBar: false),
        const ProfilMedecin(),
      ];
    });
  }

  // Reset the date filter
  void _resetDateFilter() {
    setState(() {
      selectedAppointmentDate = null;
      _updatePages();
    });
  }

  void _onNotificationTapped() {
    navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
      context,
      const NotificationsMedecin(),
    );
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('confirm logout'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('CACHED_USER');
                await prefs.remove('TOKEN');

                navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                  context,
                  LoginScreen(),
                );

                // Optional: show success message
                Get.snackbar(
                  'Success',
                  'Logged out successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                // Show error message if logout fails
                Get.snackbar(
                  'Error',
                  'Failed to logout: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                print("Logout error: $e");
              }
            },
            child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    int? notificationCount,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final textColor = isDarkMode ? theme.textTheme.bodyLarge?.color : Colors.white;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: textColor,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.raleway(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (notificationCount != null && notificationCount > 0)
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return SafeArea(
      child: BlocListener<UpdateUserBloc, UpdateUserState>(
        listener: (context, state) {
          if (state is UpdateUserSuccess) {
            setState(() {
              doctorName = '${state.user.name} ${state.user.lastName}'.trim();
              email = state.user.email;
              userId = state.user.id ?? '';
              pages = [
                DashboardMedecin(),
                AppointmentsMedecins(initialSelectedDate: selectedAppointmentDate, showAppBar: false),
                ConversationsScreen(),
                const ProfilMedecin(),
              ];
            });
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              selectedItem == 1 ? 'Mes rendez-vous' : 'MediLink', 
                    style: GoogleFonts.raleway(
                      fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
            ),
            backgroundColor: AppColors.primaryColor,
            actions: [
              if (selectedItem == 1) ...[
                // Calendar icon for appointment date selection
                IconButton(
                  icon: Icon(Icons.calendar_today_outlined, size: 24.sp, color: AppColors.whiteColor),
                  onPressed: () => _selectDate(context),
                  tooltip: "Filtrer par date",
                ),
                // Clear filter icon when a date is selected
                if (selectedAppointmentDate != null)
                  IconButton(
                    icon: Icon(Icons.clear, size: 24.sp, color: AppColors.whiteColor),
                    onPressed: _resetDateFilter,
                    tooltip: "Réinitialiser le filtre",
                  ),
              ],
              IconButton(
                icon: Icon(Icons.notifications_none, size: 24.sp, color: AppColors.whiteColor),
                onPressed: _onNotificationTapped,
              ),
            ],
          ),
          body: pages[selectedItem],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? theme.colorScheme.surface : AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.3) 
                      : AppColors.textSecondary.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: BottomNavigationBar(
                items: items,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: isDarkMode 
                    ? theme.textTheme.bodySmall?.color?.withOpacity(0.7) 
                    : AppColors.textSecondary,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                currentIndex: selectedItem,
                type: BottomNavigationBarType.fixed,
                backgroundColor: isDarkMode ? theme.colorScheme.surface : AppColors.whiteColor,
                elevation: 10,
                selectedLabelStyle: GoogleFonts.raleway(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: GoogleFonts.raleway(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode 
                      ? theme.textTheme.bodySmall?.color?.withOpacity(0.7) 
                      : Colors.black87,
                ),
                onTap: (index) {
                  setState(() {
                    selectedItem = index;
                    // Refresh the pages in case of data updates (like date selection)
                    if (index == 1) {
                      // Ensure appointments tab has the latest date selection
                      _updatePages();
                    }
                  });
                },
              ),
            ),
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.tealAccent, AppColors.primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: FloatingActionButton(
              onPressed: () {
                navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                  context,
                  ConversationsScreen(),
                );
              },
              child: Icon(Icons.smart_toy_outlined, size: 24.sp),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),

          //menu
          drawer: Drawer(
            width: 0.8.sw,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
            ),
            backgroundColor: isDarkMode ? theme.colorScheme.surface : const Color(0xFF2fa7bb),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 24.h, left: 16.w, right: 16.w, bottom: 16.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32.r,
                        backgroundColor: isDarkMode ? theme.colorScheme.primary.withOpacity(0.2) : AppColors.whiteColor,
                        child: Icon(
                          Icons.person,
                          size: 28.sp,
                          color: isDarkMode ? theme.colorScheme.primary : const Color(0xFF2fa7bb),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: GoogleFonts.raleway(
                                fontSize: 18.sp,
                                color: isDarkMode ? theme.textTheme.bodyLarge?.color : AppColors.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              email,
                              style: GoogleFonts.raleway(
                                fontSize: 14.sp,
                                color: isDarkMode 
                                    ? theme.textTheme.bodySmall?.color 
                                    : AppColors.whiteColor.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    children: [
                      _buildDrawerItem(
                        icon: FontAwesomeIcons.filePrescription,
                        title: 'prescriptions'.tr,
                        notificationCount: 2,
                        onTap: () {
                          Navigator.pop(context);
                          navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                            context,
                            const OrdonnancesPage(),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: FontAwesomeIcons.hospital,
                        title: 'hospitals'.tr,
                        onTap: () {
                          Navigator.pop(context);
                          navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                            context,
                            const PharmaciePage(),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: FontAwesomeIcons.gear,
                        title: 'settings'.tr,
                        onTap: () {
                          Navigator.pop(context);
                          navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                            context,
                            const SettingsPage(),
                          );
                        },
                      ),
                      // Theme toggle
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: BlocBuilder<ThemeCubit, ThemeState>(
                          builder: (context, state) {
                            final isDarkModeState = state is ThemeLoaded ? state.themeMode == ThemeMode.dark : false;
                            return Row(
                              children: [
                                Icon(
                                  isDarkModeState
                                      ? FontAwesomeIcons.moon
                                      : FontAwesomeIcons.sun,
                                  color: isDarkMode ? theme.textTheme.bodyLarge?.color : Colors.white,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 16.w),
                                Text(
                                  isDarkModeState
                                      ? 'dark_mode'.tr
                                      : 'light_mode'.tr,
                                  style: GoogleFonts.raleway(
                                    color: isDarkMode ? theme.textTheme.bodyLarge?.color : Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Transform.scale(
                                  scale: 0.8,
                                  child: const ThemeCubitSwitch(compact: true),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 1,
                  height: 1,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                  child: _buildDrawerItem(
                    icon: FontAwesomeIcons.rightFromBracket,
                    title: 'Logout'.tr,
                    onTap: _logout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}