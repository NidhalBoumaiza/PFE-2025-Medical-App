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
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/appointment_details_page.dart';
import 'package:medical_app/injection_container.dart' as di;

import '../../../messagerie/presentation/pages/conversations_list_screen.dart';
import '../../../ordonnance/presentation/pages/OrdonnancesPage.dart';

class NotificationsMedecin extends StatefulWidget {
  const NotificationsMedecin({super.key});

  @override
  State<NotificationsMedecin> createState() => _NotificationsMedecinState();
}

class _NotificationsMedecinState extends State<NotificationsMedecin> {
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

      // Set up notifications stream first to ensure we're listening for updates
      if (user.id != null) {
        print('Setting up notifications stream for doctor: ${user.id}');
        context.read<NotificationBloc>().add(
          GetNotificationsStreamEvent(userId: user.id!),
        );

        // Load notifications for the current user
        print('Loading notifications for doctor: ${user.id}');
        context.read<NotificationBloc>().add(
          GetNotificationsEvent(userId: user.id!),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading user data: $e")));
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
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () {
              if (_currentUser.id != null) {
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
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : BlocConsumer<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state is NotificationError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is NotificationLoading && _isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                } else if (state is NotificationsLoaded) {
                  final notifications = state.notifications;
                  print(
                    'Loaded ${notifications.length} notifications for doctor',
                  );

                  if (notifications.isEmpty) {
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
                      Expanded(child: _buildNotificationList(notifications)),
                    ],
                  );
                }

                // Default view when no notifications are loaded yet
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80.sp,
                        color: isDarkMode 
                          ? theme.iconTheme.color?.withOpacity(0.4)
                          : Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'no_notifications_found'.tr,
                        style: GoogleFonts.raleway(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_currentUser.id != null) {
                            context.read<NotificationBloc>().add(
                              GetNotificationsEvent(userId: _currentUser.id!),
                            );
                          }
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('refresh'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
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
          _buildFilterChip('message', 'messages'.tr),
          SizedBox(width: 10.w),
          _buildFilterChip('prescription', 'prescriptions'.tr),
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
          fontSize: 12.sp,
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
        : Colors.grey.shade100,
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
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
            case 'message':
              // Puisque newMessage n'est pas défini, nous pouvons temporairement le supprimer ou utiliser un autre type
              return false; // À réactiver lorsque ce type sera disponible
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
              size: 48.sp, 
              color: isDarkMode 
                ? theme.iconTheme.color?.withOpacity(0.4)
                : Colors.grey[400]
            ),
            SizedBox(height: 16.h),
            Text(
              'no_notifications_found'.tr,
              style: GoogleFonts.raleway(
                fontSize: 14.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_currentUser.id != null) {
          context.read<NotificationBloc>().add(
            GetNotificationsEvent(userId: _currentUser.id!),
          );
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return _buildDismissibleNotification(notification);
        },
      ),
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
          builder:
              (context) => AlertDialog(
                title: Text('delete_notification'.tr),
                content: Text('confirm_delete_notification'.tr),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('cancel'.tr),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'delete'.tr,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        context.read<NotificationBloc>().add(
          DeleteNotificationEvent(notificationId: notification.id),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('notification_deleted'.tr)));
      },
      child: _buildNotificationCard(notification),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Extract sender name from data if available
    String senderName = '';
    String patientName = '';
    if (notification.data != null) {
      senderName = notification.data!['senderName'] ?? '';
      patientName = notification.data!['patientName'] ?? '';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
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
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          notification.body,
                          style: GoogleFonts.raleway(
                            fontSize: 14.sp,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            if (patientName.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'Patient: $patientName',
                                    style: GoogleFonts.raleway(
                                      fontSize: 12.sp,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            Icon(
                              Icons.access_time,
                              size: 12.sp,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(notification.createdAt),
                              style: GoogleFonts.raleway(
                                fontSize: 12.sp,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (notification.type == NotificationType.newAppointment &&
                  !notification.isRead)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptAppointment(notification),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          child: Text(
                            'accept'.tr,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _rejectAppointment(notification),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          child: Text(
                            'reject'.tr,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
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
        color = Colors.green;
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

  void _acceptAppointment(NotificationEntity notification) {
    if (notification.appointmentId != null) {
      print('Accepting appointment ${notification.appointmentId}');

      // Get patient information from notification data
      String patientId = notification.senderId;
      String patientName = '';
      if (notification.data != null &&
          notification.data!['patientName'] != null) {
        patientName = notification.data!['patientName'];
      }

      context.read<RendezVousBloc>().add(
        UpdateRendezVousStatus(
          rendezVousId: notification.appointmentId!,
          status: 'accepted',
          patientId: patientId,
          doctorId: _currentUser.id!,
          patientName: patientName,
          doctorName: _currentUser.name + ' ' + _currentUser.lastName,
        ),
      );

      // Mark notification as read
      context.read<NotificationBloc>().add(
        MarkNotificationAsReadEvent(notificationId: notification.id),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('appointment_accepted'.tr)));
    }
  }

  void _rejectAppointment(NotificationEntity notification) {
    if (notification.appointmentId != null) {
      print('Rejecting appointment ${notification.appointmentId}');

      // Get patient information from notification data
      String patientId = notification.senderId;
      String patientName = '';
      if (notification.data != null &&
          notification.data!['patientName'] != null) {
        patientName = notification.data!['patientName'];
      }

      context.read<RendezVousBloc>().add(
        UpdateRendezVousStatus(
          rendezVousId: notification.appointmentId!,
          status: 'cancelled',
          patientId: patientId,
          doctorId: _currentUser.id!,
          patientName: patientName,
          doctorName: _currentUser.name + ' ' + _currentUser.lastName,
        ),
      );

      // Mark notification as read
      context.read<NotificationBloc>().add(
        MarkNotificationAsReadEvent(notificationId: notification.id),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('appointment_rejected'.tr)));
    }
  }

  void _navigateToDetails(NotificationEntity notification) {
    if (notification.appointmentId != null) {
      // First fetch the appointment details
      context.read<RendezVousBloc>().add(
        FetchRendezVous(appointmentId: notification.appointmentId),
      );

      // Listen for the result and navigate when available
      final blocListener = BlocListener<RendezVousBloc, RendezVousState>(
        listener: (context, state) {
          if (state is RendezVousLoaded && state.rendezVous.isNotEmpty) {
            final appointment = state.rendezVous.first;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AppointmentDetailsPage(
                      appointment: appointment,
                      isDoctor: true,
                    ),
              ),
            );
          }
        },
        child: Container(), // This won't be rendered
      );

      // Add the listener temporarily
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(
                  title: Text('Loading...'),
                  backgroundColor: AppColors.primaryColor,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryColor),
                      SizedBox(height: 16),
                      Text('Loading appointment details...'),
                      blocListener,
                    ],
                  ),
                ),
              ),
        ),
      );
    } else if (notification.prescriptionId != null) {
      // Navigate to prescription details
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrdonnancesPage()),
      );
    }
  }
}
