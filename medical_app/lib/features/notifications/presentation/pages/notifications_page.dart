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
import 'package:medical_app/features/rendez_vous/presentation/pages/appointment_details.dart';
import 'package:medical_app/injection_container.dart' as di;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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
        print('Setting up notifications stream for user: ${user.id}');
        context.read<NotificationBloc>().add(
          GetNotificationsStreamEvent(userId: user.id!),
        );

        // Load notifications for the current user
        print('Loading notifications for user: ${user.id}');
        context.read<NotificationBloc>().add(
          GetNotificationsEvent(userId: user.id!),
        );

        // Mark all as read when the page is opened
        context.read<NotificationBloc>().add(
          MarkAllNotificationsAsReadEvent(userId: user.id!),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'notifications'.tr,
          style: GoogleFonts.raleway(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (_currentUser.id != null) {
                context.read<NotificationBloc>().add(
                  GetNotificationsEvent(userId: _currentUser.id!),
                );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading && _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsLoaded) {
            final notifications = state.notifications;
            print('Loaded ${notifications.length} notifications');

            if (notifications.isEmpty) {
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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
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
                padding: EdgeInsets.all(16.r),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(notifications[index]);
                },
              ),
            );
          }

          // If we're not loading and don't have notifications loaded yet,
          // show a message to encourage refreshing
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'no_notifications_found'.tr,
                  style: GoogleFonts.raleway(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
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

  Widget _buildNotificationCard(NotificationEntity notification) {
    // Extract sender name from data if available
    String senderName = '';
    if (notification.data != null) {
      senderName =
          notification.data!['senderName'] ??
          notification.data!['doctorName'] ??
          notification.data!['patientName'] ??
          '';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side:
            notification.isRead
                ? BorderSide.none
                : BorderSide(
                  color: AppColors.primaryColor.withOpacity(0.5),
                  width: 1,
                ),
      ),
      child: InkWell(
        onTap: () {
          // Mark as read when tapped
          context.read<NotificationBloc>().add(
            MarkNotificationAsReadEvent(notificationId: notification.id),
          );

          // Navigate to details if applicable
          _navigateToDetails(notification);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getNotificationIcon(notification.type),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          notification.body,
                          style: GoogleFonts.raleway(
                            fontSize: 14.sp,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            if (senderName.isNotEmpty)
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
                                    senderName,
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
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat(
                                'MMM d, yyyy • h:mm a',
                              ).format(notification.createdAt),
                              style: GoogleFonts.raleway(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Show action buttons for appointment notifications
              if (notification.type == NotificationType.newAppointment &&
                  _currentUser.role == 'medecin' &&
                  !notification.isRead)
                _buildActionButtons(notification),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
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

  Widget _buildActionButtons(NotificationEntity notification) {
    // Only show action buttons for appointment notifications to doctors
    if (notification.type == NotificationType.newAppointment &&
        _currentUser.role == 'medecin') {
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (notification.appointmentId != null) {
                    _acceptAppointment(notification.appointmentId!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'accept'.tr,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (notification.appointmentId != null) {
                    _rejectAppointment(notification.appointmentId!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'reject'.tr,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _navigateToDetails(notification);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'view_details'.tr,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _acceptAppointment(String appointmentId) {
    context.read<RendezVousBloc>().add(
      UpdateRendezVousStatus(
        rendezVousId: appointmentId,
        status: 'accepted',
        patientId: '', // This would need to be fetched
        doctorId: _currentUser.id!,
        patientName: '', // This would need to be fetched
        doctorName: _currentUser.name + ' ' + _currentUser.lastName,
      ),
    );

    // Send notification to patient
    final notification = context.read<NotificationBloc>();
    notification.add(
      SendNotificationEvent(
        title: 'Appointment Accepted',
        body: 'Your appointment has been accepted by the doctor',
        senderId: _currentUser.id!,
        recipientId: '', // You need to get the patient ID from the appointment
        type: NotificationType.appointmentAccepted,
        appointmentId: appointmentId,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('appointment_accepted'.tr)));
  }

  void _rejectAppointment(String appointmentId) {
    context.read<RendezVousBloc>().add(
      UpdateRendezVousStatus(
        rendezVousId: appointmentId,
        status: 'rejected',
        patientId: '', // This would need to be fetched
        doctorId: _currentUser.id!,
        patientName: '', // This would need to be fetched
        doctorName: _currentUser.name + ' ' + _currentUser.lastName,
      ),
    );

    // Send notification to patient
    final notification = context.read<NotificationBloc>();
    notification.add(
      SendNotificationEvent(
        title: 'Appointment Rejected',
        body: 'Your appointment has been rejected by the doctor',
        senderId: _currentUser.id!,
        recipientId: '', // You need to get the patient ID from the appointment
        type: NotificationType.appointmentRejected,
        appointmentId: appointmentId,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('appointment_rejected'.tr)));
  }

  void _navigateToDetails(NotificationEntity notification) {
    if (notification.appointmentId != null) {
      // Navigate to appointment details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  AppointmentDetailsPage(id: notification.appointmentId!),
        ),
      );
    } else if (notification.prescriptionId != null) {
      // Navigate to prescription details
      // TODO: Implement prescription details navigation
    } else if (notification.ratingId != null) {
      // Navigate to rating details
      // TODO: Implement rating details navigation
    }
  }
}
