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
import '../../../messagerie/presentation/blocs/conversation BLoC/conversations_bloc.dart';
import '../../../messagerie/presentation/blocs/conversation BLoC/conversations_state.dart';
import '../../../messagerie/presentation/blocs/conversation BLoC/conversations_event.dart';

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
    _printFCMToken(); // Print FCM token for testing
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      setState(() {
        userId = userMap['id'] as String? ?? '';
        doctorName =
            '${userMap['name'] ?? ''} ${userMap['lastName'] ?? ''}'.trim();
        email = userMap['email'] as String? ?? 'doctor@example.com';
      });
    }
  }

  // Print FCM token for testing
  Future<void> _printFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('FCM_TOKEN');
      print('==========================');
      print('FCM TOKEN for testing: $token');
      print('==========================');
    } catch (e) {
      print('Error getting FCM token: $e');
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
    AppointmentsMedecins(
      initialSelectedDate: selectedAppointmentDate,
      showAppBar: false,
    ),
    const ConversationsScreen(showAppBar: false),
    const ProfilMedecin(),
  ];

  // Function to display date picker
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedAppointmentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Allow past year
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
        AppointmentsMedecins(
          initialSelectedDate: selectedAppointmentDate,
          showAppBar: false,
        ),
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
        content: Text('confirm_logout'.tr),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
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
                  'success'.tr,
                  'logout_success'.tr,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                // Show error message if logout fails
                Get.snackbar(
                  'error'.tr,
                  'logout_error'.tr,
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

    final textColor =
        isDarkMode ? theme.textTheme.bodyLarge?.color : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: textColor),
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

    return BlocListener<UpdateUserBloc, UpdateUserState>(
      listener: (_, state) {
        if (state is UpdateUserSuccess) {
          setState(() {
            doctorName = '${state.user.name} ${state.user.lastName}'.trim();
            email = state.user.email;
            userId = state.user.id ?? '';
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:
              selectedItem == 0
                  ? Text(
                    'MediLink',
                    style: GoogleFonts.raleway(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : selectedItem == 1
                  ? Text(
                    'appointments'.tr,
                    style: GoogleFonts.raleway(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : selectedItem == 2
                  ? Text(
                    'messages'.tr,
                    style: GoogleFonts.raleway(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : Text(
                    'profile'.tr,
                    style: GoogleFonts.raleway(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          actions: [
            if (selectedItem == 1) ...[
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
                tooltip: 'filter_by_date'.tr,
              ),
              if (selectedAppointmentDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _resetDateFilter,
                  tooltip: 'reset_filter'.tr,
                ),
            ],
            // Add the notification badge
            const NotificationBadge(
              iconColor: AppColors.whiteColor,
              iconSize: 24,
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.whiteColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ],
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: pages[selectedItem],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color:
                isDarkMode ? theme.colorScheme.surface : AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BottomNavigationBar(
              items: [
                items[0], // Home
                items[1], // Appointments
                // Modified message item with badge
                BottomNavigationBarItem(
                  icon: _buildMessageIcon(false),
                  activeIcon: _buildMessageIcon(true),
                  label: 'messages'.tr,
                ),
                items[3], // Profile
              ],
              currentIndex: selectedItem,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor:
                  isDarkMode ? Colors.grey.shade400 : const Color(0xFF757575),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor:
                  isDarkMode ? theme.colorScheme.surface : AppColors.whiteColor,
              selectedLabelStyle: GoogleFonts.raleway(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.raleway(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              onTap: (index) {
                setState(() {
                  selectedItem = index;
                });
              },
            ),
          ),
        ),
        drawer: _buildDrawer(isDarkMode, theme),
      ),
    );
  }

  // Widget to display message icon with badge for unread messages
  Widget _buildMessageIcon(bool isActive) {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
      buildWhen: (previous, current) {
        // Only rebuild when unread count changes
        return current is ConversationsLoaded;
      },
      builder: (context, state) {
        int unreadCount = 0;

        if (state is ConversationsLoaded) {
          unreadCount =
              state.conversations
                  .where(
                    (conv) =>
                        !conv.lastMessageRead && conv.lastMessage.isNotEmpty,
                  )
                  .length;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isActive ? Icons.chat_bubble : Icons.chat_bubble_outline,
              size: isActive ? 24.sp : 22.sp,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                  constraints: BoxConstraints(minWidth: 14.r, minHeight: 14.r),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer(bool isDarkMode, ThemeData theme) {
    return Drawer(
      width: 0.8.sw,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      backgroundColor:
          isDarkMode ? theme.colorScheme.surface : const Color(0xFF2fa7bb),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 24.h,
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor:
                      isDarkMode
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : AppColors.whiteColor,
                  child: Icon(
                    Icons.person,
                    size: 28.sp,
                    color:
                        isDarkMode
                            ? theme.colorScheme.primary
                            : const Color(0xFF2fa7bb),
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
                          color:
                              isDarkMode
                                  ? theme.textTheme.bodyLarge?.color
                                  : AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        email,
                        style: GoogleFonts.raleway(
                          fontSize: 14.sp,
                          color:
                              isDarkMode
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  child: BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      final isDarkModeState =
                          state is ThemeLoaded
                              ? state.themeMode == ThemeMode.dark
                              : false;
                      return Row(
                        children: [
                          Icon(
                            isDarkModeState
                                ? FontAwesomeIcons.moon
                                : FontAwesomeIcons.sun,
                            color:
                                isDarkMode
                                    ? theme.textTheme.bodyLarge?.color
                                    : Colors.white,
                            size: 18.sp,
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            isDarkModeState ? 'dark_mode'.tr : 'light_mode'.tr,
                            style: GoogleFonts.raleway(
                              color:
                                  isDarkMode
                                      ? theme.textTheme.bodyLarge?.color
                                      : Colors.white,
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
                    },
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
              title: 'logout'.tr,
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }
}
