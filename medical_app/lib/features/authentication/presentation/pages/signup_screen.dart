import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:medical_app/cubit/toggle%20cubit/toggle_cubit.dart';
import 'package:medical_app/features/authentication/presentation/pages/signup_medecin_screen.dart';
import 'package:medical_app/features/authentication/presentation/pages/signup_patient_screen.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';
import '../../domain/entities/medecin_entity.dart';
import '../../domain/entities/patient_entity.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numTel = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  String gender = 'Homme';

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    numTel.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      "Inscription",
                      style: GoogleFonts.raleway(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Header image
                  Center(
                    child: Image.asset(
                      'assets/images/signup.png',
                      height: 200.h,
                      width: 200.w,
                    ),
                  ),
                  
                  SizedBox(height: 30.h),
                  
                  // User type toggle
                  Center(
                    child: BlocBuilder<ToggleCubit, ToggleState>(
                      builder: (context, state) {
                        return AnimatedToggleSwitch<bool>.dual(
                          current: state is PatientState,
                          first: true,
                          second: false,
                          spacing: 45.0,
                          animationDuration: const Duration(milliseconds: 600),
                          style: ToggleStyle(
                            borderColor: Colors.transparent,
                            indicatorColor: AppColors.primaryColor,
                            backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                          ),
                          customIconBuilder: (context, local, global) {
                            return Center(
                              child: Text(
                                state is PatientState ? "Patient" : "Médecin",
                                style: GoogleFonts.raleway(
                                  color: state is PatientState ? Colors.white : AppColors.whiteColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                          onChanged: (bool value) {
                            context.read<ToggleCubit>().toggle();
                          },
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 30.h),
                  
                  // Form fields
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom label
                        Text(
                          "Nom",
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        
                        SizedBox(height: 10.h),
                        
                        // Nom field
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
                          child: TextFormField(
                            controller: nomController,
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
                              hintText: "Entrez votre nom",
                              hintStyle: GoogleFonts.raleway(
                                color: Colors.grey[400],
                                fontSize: 15.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Le nom est obligatoire";
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Prénom label
                        Text(
                          "Prénom",
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        
                        SizedBox(height: 10.h),
                        
                        // Prénom field
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
                          child: TextFormField(
                            controller: prenomController,
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
                              hintText: "Entrez votre prénom",
                              hintStyle: GoogleFonts.raleway(
                                color: Colors.grey[400],
                                fontSize: 15.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Le prénom est obligatoire";
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Email label
                        Text(
                          "Email",
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        
                        SizedBox(height: 10.h),
                        
                        // Email field
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
                          child: TextFormField(
                            controller: emailController,
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
                              hintText: "Entrez votre email",
                              hintStyle: GoogleFonts.raleway(
                                color: Colors.grey[400],
                                fontSize: 15.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "L'email est obligatoire";
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return "Veuillez entrer un email valide";
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Téléphone label
                        Text(
                          "Téléphone",
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        
                        SizedBox(height: 10.h),
                        
                        // Téléphone field
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
                          child: TextFormField(
                            controller: numTel,
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
                              hintText: "Entrez votre numéro de téléphone",
                              hintStyle: GoogleFonts.raleway(
                                color: Colors.grey[400],
                                fontSize: 15.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Le numéro de téléphone est obligatoire";
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Date de naissance label
                        Text(
                          "Date de naissance",
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        
                        SizedBox(height: 10.h),
                        
                        // Date de naissance field
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
                          child: TextFormField(
                            controller: birthdayController,
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
                              hintText: "YYYY-MM-DD",
                              hintStyle: GoogleFonts.raleway(
                                color: Colors.grey[400],
                                fontSize: 15.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "La date de naissance est obligatoire";
                              }
                              if (_parseDate(value) == null) {
                                return "Format de date invalide (YYYY-MM-DD)";
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Genre label
                        Text(
                          "Genre",
                          style: GoogleFonts.raleway(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        
                        SizedBox(height: 10.h),
                        
                        // Genre selection
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
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(
                                    "Homme",
                                    style: GoogleFonts.raleway(
                                      fontSize: 15.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  value: "Homme",
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(
                                    "Femme",
                                    style: GoogleFonts.raleway(
                                      fontSize: 15.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  value: "Femme",
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30.h),
                  
                  // Submit button
                  Container(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final dateOfBirth = _parseDate(birthdayController.text);
                          if (dateOfBirth == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Date de naissance invalide")),
                            );
                            return;
                          }
                          if (context.read<ToggleCubit>().state is PatientState) {
                            final patientEntity = PatientEntity(
                              name: nomController.text,
                              lastName: prenomController.text,
                              email: emailController.text,
                              role: 'patient',
                              gender: gender,
                              phoneNumber: numTel.text,
                              dateOfBirth: dateOfBirth,
                              antecedent: '',
                            );
                            Get.to(() => SignupPatientScreen(patientEntity: patientEntity));
                          } else {
                            final medecinEntity = MedecinEntity(
                              name: nomController.text,
                              lastName: prenomController.text,
                              email: emailController.text,
                              role: 'medecin',
                              gender: gender,
                              phoneNumber: numTel.text,
                              dateOfBirth: dateOfBirth,
                              speciality: '',
                              numLicence: '',
                            );
                            Get.to(() => SignupMedecinScreen(medecinEntity: medecinEntity));
                          }
                        }
                      },
                      child: Text(
                        "Suivant",
                        style: GoogleFonts.raleway(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Back to login
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Retour à la connexion",
                        style: GoogleFonts.raleway(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
