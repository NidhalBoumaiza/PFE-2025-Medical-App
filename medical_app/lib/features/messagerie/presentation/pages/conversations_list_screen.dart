import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation%20BLoC/conversations_bloc.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation%20BLoC/conversations_event.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation%20BLoC/conversations_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final bool showAppBar;
  
  const ConversationsScreen({
    super.key,
    this.showAppBar = true
  });

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  String _userId = '';
  bool _isDoctor = false;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final userJson = sharedPreferences.getString('CACHED_USER');
      if (userJson == null) {
        throw Exception('No cached user data found');
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final userId = userMap['id'] as String? ?? '';
      final isDoctor = userMap.containsKey('speciality') && userMap.containsKey('numLicence');

      setState(() {
        _userId = userId;
        _isDoctor = isDoctor;
        _isLoading = false;
      });

      print('ConversationsScreen loaded userId: $_userId, isDoctor: $_isDoctor');
      if (_userId.isNotEmpty) {
        context.read<ConversationsBloc>().add(SubscribeToConversationsEvent(
          userId: _userId,
          isDoctor: _isDoctor,
        ));
      } else {
        setState(() {
          _errorMessage = _t('error_user_id_missing');
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = _t('error_no_user_data');
      });
    }
  }

  String _t(String key) {
    const translations = {
      'en': {
        'messages': 'Messages',
        'error_user_id_missing': 'User ID is missing',
        'error_no_user_data': 'No user data found. Please log in.',
        'no_conversations': 'No conversations found',
        'error': 'Error: ',
        'retry': 'Retry',
        'go_to_login': 'Go to Login',
      },
      'fr': {
        'messages': 'Messages',
        'error_user_id_missing': 'L\'ID utilisateur est manquant',
        'error_no_user_data': 'Aucune donnée utilisateur trouvée. Veuillez vous connecter.',
        'no_conversations': 'Aucune conversation trouvée',
        'error': 'Erreur : ',
        'retry': 'Réessayer',
        'go_to_login': 'Aller à la connexion',
      },
    };

    final locale = Localizations.localeOf(context).languageCode;
    final lang = translations.containsKey(locale) ? locale : 'en';
    return translations[lang]![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: widget.showAppBar ? AppBar(
          title: Text(
            _t('messages'),
            style: GoogleFonts.raleway(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 2,
        ) : null,
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                Icons.error_outline,
                size: 72.sp,
                color: Colors.red.withOpacity(0.7),
              ),
                SizedBox(height: 16.h),
                Text(
                _t('error') + _errorMessage,
                  textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  fontSize: 16.sp,
                  color: Colors.red.shade700,
                ),
              ),
              SizedBox(height: 24.h),
                ElevatedButton(
                onPressed: _loadUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  ),
                  child: Text(
                  _t('retry'),
                  style: GoogleFonts.raleway(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                ),
              ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(
          _t('messages'),
          style: GoogleFonts.raleway(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ConversationsBloc, ConversationsState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                  } else if (state is ConversationsLoaded) {
                    if (state.conversations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64.sp,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              _t('no_conversations'),
                              style: GoogleFonts.raleway(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.w),
                              child: Text(
                                "Your conversations with patients and doctors will appear here",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.raleway(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        final displayName = _isDoctor ? conversation.patientName : conversation.doctorName;
                        final recipientId = _isDoctor ? conversation.patientId : conversation.doctorId;
                        
                        // Format timestamp
                        String formattedTime = '';
                        if (conversation.lastMessageTime != null) {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final yesterday = DateTime(now.year, now.month, now.day - 1);
                          final messageDate = DateTime(
                            conversation.lastMessageTime!.year,
                            conversation.lastMessageTime!.month,
                            conversation.lastMessageTime!.day,
                          );
                          
                          if (messageDate == today) {
                            formattedTime = DateFormat('HH:mm').format(conversation.lastMessageTime!);
                          } else if (messageDate == yesterday) {
                            formattedTime = 'Yesterday';
                          } else {
                            formattedTime = DateFormat('dd/MM').format(conversation.lastMessageTime!);
                          }
                        }
                        
                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () {
                              print('Navigating to ChatScreen with chatId: ${conversation.id}, userName: $displayName, recipientId: $recipientId');
                              navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                context, 
                                ChatScreen(
                                  chatId: conversation.id!, 
                                  userName: displayName, 
                                  recipientId: recipientId,
                                )
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                              child: Row(
                                children: [
                                  // Avatar
                                  Stack(
                                    children: [
                                      Container(
                                        width: 60.w,
                                        height: 60.h,
                                        margin: EdgeInsets.only(right: 12.w),
                                        decoration: BoxDecoration(
                                          color: _getAvatarColor(displayName),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                              style: GoogleFonts.raleway(
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                              ),
                            ),
                          ),
                                      // Unread indicator
                                      if (!conversation.lastMessageRead && !_isDoctor)
                                        Positioned(
                                          right: 8.w,
                                          top: 0,
                                          child: Container(
                                            width: 14.w,
                                            height: 14.h,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                                        ),
                                    ],
                                  ),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                                displayName.isNotEmpty 
                                                  ? _isDoctor ? displayName : 'Dr. $displayName' 
                                                  : 'Unknown',
                                                style: GoogleFonts.raleway(
                                                  fontSize: 16.sp,
                                                  fontWeight: !conversation.lastMessageRead && !_isDoctor 
                                                    ? FontWeight.bold 
                                                    : FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                                            if (formattedTime.isNotEmpty)
                                              Text(
                                                formattedTime,
                                                style: GoogleFonts.raleway(
                                                  fontSize: 12.sp,
                                                  fontWeight: !conversation.lastMessageRead && !_isDoctor 
                                                    ? FontWeight.w600 
                                                    : FontWeight.normal,
                                                  color: !conversation.lastMessageRead && !_isDoctor 
                                                    ? AppColors.primaryColor 
                                                    : Colors.grey.shade500,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                Text(
                                          conversation.lastMessage.isNotEmpty 
                                              ? conversation.lastMessage 
                                              : 'No message',
                                          style: GoogleFonts.raleway(
                                            fontSize: 14.sp,
                                            color: !conversation.lastMessageRead && !_isDoctor 
                                                ? Colors.black87
                                                : Colors.grey.shade600,
                                            fontWeight: !conversation.lastMessageRead && !_isDoctor
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is ConversationsError) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: Colors.red.withOpacity(0.7),
                          ),
                            SizedBox(height: 16.h),
                            Text(
                            state.message,
                              textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              fontSize: 16.sp,
                              color: Colors.red.shade700,
                            ),
                          ),
                          SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: () {
                              if (_userId.isNotEmpty) {
                                context.read<ConversationsBloc>().add(FetchConversationsEvent(
                                  userId: _userId,
                                  isDoctor: _isDoctor,
                                ));
                              }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              ),
                              child: Text(
                                _t('retry'),
                              style: GoogleFonts.raleway(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              ),
                            ),
                          ],
                        ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryColor),
                          SizedBox(height: 16.h),
                          Text(
                            'Loading conversations...',
                            style: GoogleFonts.raleway(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to generate a consistent color for avatars
  Color _getAvatarColor(String name) {
    if (name.isEmpty) return AppColors.primaryColor;
    
    // Generate a consistent color based on the name
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    
    final int index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}