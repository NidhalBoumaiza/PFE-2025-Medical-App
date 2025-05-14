import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_local_data_source.dart';
import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:medical_app/features/notifications/presentation/bloc/notification_state.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_medecin.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_patient.dart';
import 'package:medical_app/injection_container.dart' as di;

class NotificationBadge extends StatefulWidget {
  const NotificationBadge({Key? key}) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  String? userId;
  String? userRole;
  bool _isInitialized = false;
  
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
        userId = user.id;
        userRole = user.role;
        _isInitialized = true;
      });
      
      if (userId != null) {
        // Initialize FCM
        context.read<NotificationBloc>().add(SetupFCMEvent());
        
        // Load unread count
        context.read<NotificationBloc>().add(GetUnreadNotificationsCountEvent(userId: userId!));
        
        // Setup stream
        context.read<NotificationBloc>().add(GetNotificationsStreamEvent(userId: userId!));
      }
    } catch (e) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _navigateToNotificationsPage() {
    if (userRole == 'medecin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsMedecin()),
      );
    } else {
      // Default to patient notifications
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsPatient()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isInitialized || userId == null
        ? IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _navigateToNotificationsPage,
          )
        : BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int count = 0;
              
              if (state is UnreadNotificationsCountLoaded) {
                count = state.count;
              }
              
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: _navigateToNotificationsPage,
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.r,
                          minHeight: 16.r,
                        ),
                        child: Center(
                          child: Text(
                            count > 9 ? '9+' : count.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
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
} 