import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/ratings/presentation/bloc/rating_bloc.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/doctor_profile_page.dart';
import 'package:intl/intl.dart';

class AvailableDoctorsScreen extends StatefulWidget {
  final String specialty;
  final DateTime startTime;
  final String patientId;
  final String patientName;

  const AvailableDoctorsScreen({
    Key? key,
    required this.specialty,
    required this.startTime,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<AvailableDoctorsScreen> createState() => _AvailableDoctorsScreenState();
}

class _AvailableDoctorsScreenState extends State<AvailableDoctorsScreen> {
  final Map<String, double> _doctorRatings = {};

  @override
  void initState() {
    super.initState();
    context.read<RendezVousBloc>().add(
      FetchDoctorsBySpecialty(widget.specialty, widget.startTime),
    );
  }
  
  void _loadDoctorRating(String doctorId) {
    // Load doctor's average rating
    context.read<RatingBloc>().add(GetDoctorAverageRating(doctorId));
  }

  void _navigateToDoctorProfile(MedecinEntity doctor) {
    navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
      context,
      DoctorProfilePage(
        doctor: doctor,
        canBookAppointment: true,
        onBookAppointment: () {
          Navigator.pop(context);
          _confirmRendezVous(context, doctor);
        },
      ),
    );
  }

  Future<void> _confirmRendezVous(
      BuildContext context, MedecinEntity doctor) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la consultation',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Voulez-vous confirmer la consultation avec Dr. ${doctor.name} ${doctor.lastName} pour le ${DateFormat('dd/MM/yyyy à HH:mm').format(widget.startTime)} ?',
          style: GoogleFonts.raleway(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.raleway(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirmer',
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final rendezVous = RendezVousEntity(
        patientId: widget.patientId,
        patientName: widget.patientName,
        doctorId: doctor.id,
        doctorName: '${doctor.name} ${doctor.lastName}',
        speciality: widget.specialty,
        startTime: widget.startTime,
        status: 'pending',
      );
      context.read<RendezVousBloc>().add(CreateRendezVous(rendezVous));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Médecins disponibles',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.specialty,
                  style: GoogleFonts.raleway(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Rendez-vous le ${DateFormat('dd/MM/yyyy à HH:mm').format(widget.startTime)}',
                  style: GoogleFonts.raleway(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: BlocConsumer<RendezVousBloc, RendezVousState>(
              listener: (context, state) {
                if (state is RendezVousError) {
                  showErrorSnackBar(context, state.message);
                } else if (state is RendezVousCreated) {
                  showSuccessSnackBar(context, 'Consultation confirmée, en attente d\'approbation');
                  Navigator.pop(context);
                } else if (state is DoctorsLoaded) {
                  // Load ratings for all doctors
                  for (var doctor in state.doctors) {
                    if (doctor.id != null) {
                      _loadDoctorRating(doctor.id!);
                    }
                  }
                }
              },
              builder: (context, state) {
                if (state is RendezVousLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                } else if (state is DoctorsLoaded) {
                  final doctors = state.doctors;
                  if (doctors.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Aucun médecin disponible pour cette spécialité à cette date',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return _buildDoctorCard(doctor);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDoctorCard(MedecinEntity doctor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDoctorProfile(doctor),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 60.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dr. ${doctor.name} ${doctor.lastName}",
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          doctor.speciality ?? "",
                          style: GoogleFonts.raleway(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        BlocListener<RatingBloc, RatingState>(
                          listener: (context, state) {
                            if (state is DoctorRatingState && 
                                doctor.id != null) {
                              setState(() {
                                _doctorRatings[doctor.id!] = state.averageRating;
                              });
                            } else if (state is DoctorAverageRatingLoaded && 
                                doctor.id != null) {
                              setState(() {
                                _doctorRatings[doctor.id!] = state.averageRating;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _doctorRatings.containsKey(doctor.id) 
                                  ? _doctorRatings[doctor.id]!.toStringAsFixed(1)
                                  : "N/A",
                                style: GoogleFonts.raleway(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(
                      Icons.info_outline,
                      size: 18.sp,
                    ),
                    label: Text(
                      "Voir profil",
                      style: GoogleFonts.raleway(
                        fontSize: 14.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: () => _navigateToDoctorProfile(doctor),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.calendar_today,
                        size: 18.sp,
                      ),
                      label: Text(
                        "Sélectionner",
                        style: GoogleFonts.raleway(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _confirmRendezVous(context, doctor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}