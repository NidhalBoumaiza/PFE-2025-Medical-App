import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/core/widgets/reusable_text_field_widget.dart';
import 'package:medical_app/injection_container.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_local_data_source.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../core/specialties.dart';
import '../blocs/rendez-vous BLoC/rendez_vous_bloc.dart';
import 'available_doctor_screen.dart';

class RendezVousPatient extends StatefulWidget {
  final String? selectedSpecialty;
  final bool showAppBar; // Whether to show the app bar (true when navigating directly, false from bottom nav)

  const RendezVousPatient({
    super.key, 
    this.selectedSpecialty, 
    this.showAppBar = true
  });

  @override
  State<RendezVousPatient> createState() => _RendezVousPatientState();
}

class _RendezVousPatientState extends State<RendezVousPatient> {
  final TextEditingController dateTimeController = TextEditingController();
  String? selectedSpecialty;
  DateTime? selectedDateTime;
  final _formKey = GlobalKey<FormState>();
  
  // Calendar variables
  bool isCalendarVisible = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    if (widget.selectedSpecialty != null &&
        specialties.contains(widget.selectedSpecialty)) {
      selectedSpecialty = widget.selectedSpecialty;
    }
  }

  @override
  void dispose() {
    dateTimeController.dispose();
    super.dispose();
  }

  void _toggleCalendar() {
    setState(() {
      isCalendarVisible = !isCalendarVisible;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    _toggleCalendar();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      // Show time picker after selecting a date
      _showTimePicker(selectedDay);
    });
  }

  void _showTimePicker(DateTime date) async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: AppColors.whiteColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateTimeController.text = DateFormat('dd/MM/yyyy à HH:mm').format(selectedDateTime!);
        isCalendarVisible = false; // Hide calendar after selection
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            "MediLink",
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 2,
          leading: widget.showAppBar ? IconButton(
            icon: const Icon(
              Icons.chevron_left,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ) : null,
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white),
              onPressed: _toggleCalendar,
              tooltip: "Sélectionner une date",
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (isCalendarVisible) {
              setState(() {
                isCalendarVisible = false;
              });
            }
          },
          child: Column(
            children: [
              // Calendar view
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: isCalendarVisible ? 350.h : 0,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCalendarVisible)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Calendar header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Sélectionner une date",
                                    style: GoogleFonts.raleway(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        isCalendarVisible = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              
                              // The Calendar
                              TableCalendar(
                                firstDay: DateTime.now(),
                                lastDay: DateTime.now().add(Duration(days: 365)),
                                focusedDay: _focusedDay,
                                calendarFormat: _calendarFormat,
                                onFormatChanged: (format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                },
                                selectedDayPredicate: (day) {
                                  return selectedDateTime != null && 
                                    day.year == selectedDateTime!.year &&
                                    day.month == selectedDateTime!.month &&
                                    day.day == selectedDateTime!.day;
                                },
                                onDaySelected: _onDaySelected,
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonTextStyle: GoogleFonts.raleway(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                  titleTextStyle: GoogleFonts.raleway(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primaryColor),
                                  rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primaryColor),
                                  formatButtonVisible: true,
                                  titleCentered: true,
                                ),
                                availableCalendarFormats: const {
                                  CalendarFormat.month: 'Mois',
                                  CalendarFormat.twoWeeks: '2 Semaines',
                                  CalendarFormat.week: 'Semaine',
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Main content
              Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    
                    // Header image
                    Center(
                      child: Image.asset(
                        'assets/images/Consultation.png',
                        height: 200.h,
                        width: 200.w,
                      ),
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Title
                    Text(
                      "Trouver votre médecin",
                      style: GoogleFonts.raleway(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    // Subtitle
                    Text(
                      "Sélectionnez une spécialité et une date pour votre consultation",
                      style: GoogleFonts.raleway(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Specialty selection
                    Text(
                      "Spécialité médicale",
                      style: GoogleFonts.raleway(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          hintText: "Choisir une spécialité",
                          hintStyle: GoogleFonts.raleway(
                            color: Colors.grey[400],
                            fontSize: 15.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.medical_services_outlined,
                            color: AppColors.primaryColor,
                            size: 22.sp,
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryColor,
                        ),
                        value: selectedSpecialty,
                        items: specialties
                            .map((specialty) => DropdownMenuItem(
                                  value: specialty,
                                  child: Text(
                                    specialty,
                                    style: GoogleFonts.raleway(
                                      fontSize: 15.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSpecialty = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez sélectionner une spécialité";
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Date and time selection
                    Text(
                      "Date et heure souhaitées",
                      style: GoogleFonts.raleway(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    GestureDetector(
                      onTap: () => _selectDateTime(context),
                      child: AbsorbPointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: dateTimeController,
                            style: GoogleFonts.raleway(
                              fontSize: 15.sp,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 16.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 1,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              hintText: "Sélectionner la date et l'heure",
                              hintStyle: GoogleFonts.raleway(
                                color: Colors.grey[400],
                                fontSize: 15.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Veuillez sélectionner une date et une heure";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Search button
                    BlocBuilder<RendezVousBloc, RendezVousState>(
                      builder: (context, state) {
                        final isLoading = state is RendezVousLoading;
                        
                        return Container(
                          width: double.infinity,
                          height: 55.h,
                          margin: EdgeInsets.only(bottom: 30.h),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 2,
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (selectedDateTime != null) {
                                        final authLocalDataSource =
                                            sl<AuthLocalDataSource>();
                                        final user =
                                            await authLocalDataSource.getUser();
                                        final patientName =
                                            '${user.name} ${user.lastName}'
                                                .trim();

                                        navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                          context,
                                          AvailableDoctorsScreen(
                                            specialty: selectedSpecialty!,
                                            startTime: selectedDateTime!,
                                            patientId: user.id!,
                                            patientName: patientName,
                                          ),
                                        );
                                      } else {
                                        showErrorSnackBar(context, 
                                          "Veuillez sélectionner une date et une heure valides"
                                        );
                                      }
                                    }
                                  },
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: 22.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        "Rechercher un médecin",
                                        style: GoogleFonts.raleway(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}