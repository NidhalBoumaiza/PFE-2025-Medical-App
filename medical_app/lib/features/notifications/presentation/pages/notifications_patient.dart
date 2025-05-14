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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            icon: const Icon(Icons.done_all, color: Colors.white),
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
          icon: const Icon(
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
                            color: isDarkMode 
                              ? theme.iconTheme.color?.withOpacity(0.4)
                              : Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'no_notifications'.tr,
                            style: GoogleFonts.raleway(
                              fontSize: 16.sp,
                              color: theme.textTheme.bodyMedium?.color,
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
                        color: isDarkMode 
                          ? theme.iconTheme.color?.withOpacity(0.4)
                          : Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'no_notifications'.tr,
                        style: GoogleFonts.raleway(
                          fontSize: 16.sp,
                          color: theme.textTheme.bodyMedium?.color,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
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
      backgroundColor: isDarkMode 
          ? theme.cardColor.withOpacity(0.3) 
          : Colors.grey[100],
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  Widget _buildNotificationList(List<NotificationEntity> notifications) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
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
            Icon(
              Icons.notifications_off, 
              size: 48, 
              color: isDarkMode 
                ? theme.iconTheme.color?.withOpacity(0.4)
                : Colors.grey[400]
            ),
            const SizedBox(height: 16),
            Text(
              'no_notifications'.tr,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: theme.cardColor,
              title: Text(
                'confirmation'.tr,
                style: TextStyle(color: theme.textTheme.titleLarge?.color),
              ),
              content: Text(
                'delete_notification_confirm'.tr,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'cancel'.tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'delete'.tr,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<NotificationBloc>().add(
          DeleteNotificationEvent(
            notificationId: notification.id,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('notification_deleted'.tr)),
        );
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationBloc>().add(
              MarkNotificationAsReadEvent(
                notificationId: notification.id,
              ),
            );
          }
          
          _handleNotificationTap(notification);
        },
        child: Card(
          margin: EdgeInsets.only(bottom: 12.h),
          elevation: 1,
          color: notification.isRead 
            ? theme.cardColor
            : isDarkMode
              ? AppColors.primaryColor.withOpacity(0.15) 
              : AppColors.primaryColor.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(
              color: notification.isRead 
                ? isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300
                : AppColors.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getNotificationTypeIcon(notification.type),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.raleway(
                                fontSize: 14.sp,
                                fontWeight: notification.isRead 
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryColor,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.body,
                        style: GoogleFonts.raleway(
                          fontSize: 12.sp,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatNotificationTime(notification.createdAt),
                            style: GoogleFonts.raleway(
                              fontSize: 10.sp,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18.sp,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNotificationTypeIcon(NotificationType type) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    IconData iconData;
    Color iconColor;
    Color backgroundColor;
    
    switch (type) {
      case NotificationType.newAppointment:
      case NotificationType.appointmentAccepted:
      case NotificationType.appointmentRejected:
        iconData = Icons.calendar_today;
        iconColor = AppColors.primaryColor;
        backgroundColor = isDarkMode 
          ? AppColors.primaryColor.withOpacity(0.2)
          : AppColors.primaryColor.withOpacity(0.1);
        break;
      case NotificationType.newPrescription:
        iconData = Icons.medical_services;
        iconColor = Colors.green;
        backgroundColor = isDarkMode 
          ? Colors.green.withOpacity(0.2)
          : Colors.green.withOpacity(0.1);
        break;
      case NotificationType.newRating:
        iconData = Icons.star;
        iconColor = Colors.amber;
        backgroundColor = isDarkMode 
          ? Colors.amber.withOpacity(0.2)
          : Colors.amber.withOpacity(0.1);
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        backgroundColor = isDarkMode 
          ? Colors.grey.withOpacity(0.2)
          : Colors.grey.withOpacity(0.1);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(10.r),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20.sp,
      ),
    );
  }

  void _handleNotificationTap(NotificationEntity notification) {
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

  String _formatNotificationTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}