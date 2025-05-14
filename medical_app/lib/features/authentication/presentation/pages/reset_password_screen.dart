import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/core/widgets/reusable_text_field_widget.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';
import 'package:lottie/lottie.dart';
import '../blocs/reset password bloc/reset_password_bloc.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final int verificationCode;

  const ResetPasswordScreen({
    Key? key,
    required this.email,
    required this.verificationCode,
  }) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    print('ResetPasswordScreen: email=${widget.email}, verificationCode=${widget.verificationCode}');
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Ensure layout adjusts for keyboard
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 600.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(300.r),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/lotties/reset.json", height: 350.h),
                        SizedBox(height: 20.h),
                        ReusableTextWidget(
                          text: "Réinitialiser le mot de passe".tr,
                          textSize: 60,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                // Champ pour le nouveau mot de passe
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextWidget(
                        text: "Nouveau mot de passe :".tr,
                        textSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 10.h),
                      ReusableTextFieldWidget(
                        controller: newPasswordController,
                        hintText: "Nouveau mot de passe".tr,
                        obsecureText: _isObscureNewPassword,
                        onPressedSuffixIcon: () {
                          setState(() {
                            _isObscureNewPassword = !_isObscureNewPassword;
                          });
                        },
                        validatorFunction: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le mot de passe est obligatoire".tr;
                          }
                          if (value.length < 8) {
                            return "Le mot de passe doit contenir au moins 8 caractères".tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                // Champ pour confirmer le mot de passe
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextWidget(
                        text: "Confirmer le mot de passe :".tr,
                        textSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 10.h),
                      ReusableTextFieldWidget(
                        controller: confirmPasswordController,
                        hintText: "Confirmer le mot de passe".tr,
                        obsecureText: _isObscureConfirmPassword,
                        onPressedSuffixIcon: () {
                          setState(() {
                            _isObscureConfirmPassword = !_isObscureConfirmPassword;
                          });
                        },
                        validatorFunction: (value) {
                          if (value == null || value.isEmpty) {
                            return "La confirmation est obligatoire".tr;
                          }
                          if (value != newPasswordController.text) {
                            return "Les mots de passe ne correspondent pas".tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                // Bouton "Réinitialiser"
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
                    listener: (context, state) {
                      if (state is ResetPasswordSuccess) {
                        showSuccessSnackBar(context, "password_reset_success".tr);
                        navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                          context,
                          const LoginScreen(),
                        );
                      } else if (state is ResetPasswordError) {
                        showErrorSnackBar(context, state.message.tr);
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 200.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          onPressed: state is ResetPasswordLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              print('Submitting reset password: email=${widget.email}, code=${widget.verificationCode}');
                              context.read<ResetPasswordBloc>().add(
                                ResetPasswordSubmitted(
                                  email: widget.email,

                                  newPassword: newPasswordController.text,
                                  verificationCode: widget.verificationCode,
                                ),
                              );
                            }
                          },
                          child: state is ResetPasswordLoading
                              ? CircularProgressIndicator(color: AppColors.whiteColor)
                              : ReusableTextWidget(
                            text: "Réinitialiser".tr,
                            textSize: 60,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}