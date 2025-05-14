import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_local_data_source.dart';
import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';
import 'package:medical_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_state.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/appointment_details.dart';
import 'package:medical_app/injection_container.dart' as di;

class NotificationsPatient extends StatefulWidget {
  const NotificationsPatient({super.key});

  @override
  State<NotificationsPatient> createState() => _NotificationsPatientState();
}

class _NotificationsPatientState extends State<NotificationsPatient> {
  String _selectedFilter = 'all';
  late UserEntity _currentUser;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authLocalDataSource = di.sl<AuthLocalDataSource>();
      final user = await authLocalDataSource.getUser();
      
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
      
      // Load notifications for the current user
      context.read<NotificationBloc>().add(GetNotificationsEvent(userId: user.id!));
      
      // Mark all as read when the page is opened
      context.read<NotificationBloc>().add(MarkAllNotificationsAsReadEvent(userId: user.id!));
      
      // Set up notifications stream
      context.read<NotificationBloc>().add(GetNotificationsStreamEvent(userId: user.id!));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading user data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'notifications'.tr,
          style: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: Colors.white),
            onPressed: () {
              if (!_isLoading && _currentUser.id != null) {
                context.read<NotificationBloc>().add(
                  MarkAllNotificationsAsReadEvent(userId: _currentUser.id!),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('all_notifications_marked_as_read'.tr)),
                );
              }
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  );
                } else if (state is NotificationsLoaded) {
                  if (state.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 80.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'no_notifications'.tr,
                            style: GoogleFonts.raleway(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      _buildFilterChips(),
                      Expanded(
                        child: _buildNotificationList(state.notifications),
                      ),
                    ],
                  );
                } else if (state is NotificationError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.raleway(
                        fontSize: 16.sp,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'no_notifications'.tr,
                        style: GoogleFonts.raleway(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _buildFilterChip('all', 'all'.tr),
          SizedBox(width: 10.w),
          _buildFilterChip('appointment', 'appointments'.tr),
          SizedBox(width: 10.w),
          _buildFilterChip('prescription', 'prescriptions'.tr),
          SizedBox(width: 10.w),
          _buildFilterChip('rating', 'ratings'.tr),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
      selectedColor: AppColors.primaryColor,
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  Widget _buildNotificationList(List<NotificationEntity> notifications) {
    final filteredNotifications = _selectedFilter == 'all'
        ? notifications
        : notifications.where((n) {
            // Filter by notification type based on the selected filter
            switch (_selectedFilter) {
              case 'appointment':
                return n.type == NotificationType.newAppointment ||
                      n.type == NotificationType.appointmentAccepted ||
                      n.type == NotificationType.appointmentRejected;
              case 'prescription':
                return n.type == NotificationType.newPrescription;
              case 'rating':
                return n.type == NotificationType.newRating;
              default:
                return true;
            }
          }).toList();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'no_notifications'.tr,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildDismissibleNotification(notification);
      },
    );
  }

  Widget _buildDismissibleNotification(NotificationEntity notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('delete_notification'.tr),
            content: Text('confirm_delete_notification'.tr),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<NotificationBloc>().add(
          DeleteNotificationEvent(notificationId: notification.id),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('notification_deleted'.tr),
          ),
        );
      },
      child: _buildNotificationCard(notification),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: AppColors.primaryColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () {
          // Mark as read when tapped
          if (!notification.isRead) {
            context.read<NotificationBloc>().add(
              MarkNotificationAsReadEvent(notificationId: notification.id),
            );
          }
          _navigateToDetails(notification);
        },
        borderRadius: BorderRadius.circular(15.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification.type),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          notification.body,
                          style: GoogleFonts.raleway(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(notification.createdAt),
                          style: GoogleFonts.raleway(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () => _navigateToDetails(notification),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  minimumSize: Size(double.infinity, 36.h),
                ),
                child: Text('view_details'.tr, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.newAppointment:
        icon = Icons.calendar_today;
        color = Colors.orange;
        break;
      case NotificationType.appointmentAccepted:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.appointmentRejected:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case NotificationType.newRating:
        icon = Icons.star;
        color = Colors.amber;
        break;
      case NotificationType.newPrescription:
        icon = Icons.medical_services;
        color = AppColors.primaryColor;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: 24.sp),
    );
  }
  
  void _navigateToDetails(NotificationEntity notification) {
    if (notification.appointmentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDetailsPage(id: notification.appointmentId!),
        ),
      );
    } else if (notification.prescriptionId != null) {
      // Navigate to prescription details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrdonnancesPage(),
        ),
      );
    }
  }
}