
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_remote_data_source.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lottie/lottie.dart';
import 'package:medical_app/features/authentication/presentation/blocs/verify%20code%20bloc/verify_code_bloc.dart';
import 'package:medical_app/features/authentication/presentation/pages/reset_password_screen.dart';
import 'package:medical_app/features/authentication/presentation/pages/login_screen.dart';

class VerifyCodeScreen extends StatelessWidget {
  final String email;
  final bool isAccountCreation;

  const VerifyCodeScreen({
    Key? key,
    required this.email,
    this.isAccountCreation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
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
                      Lottie.asset("assets/lotties/code.json", height: 350.h),
                      SizedBox(height: 20.h),
                      ReusableTextWidget(
                        text: "Vérification du code".tr,
                        textSize: 60,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableTextWidget(
                      text: "Code de vérification :".tr,
                      textSize: 50,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 20.h),
                    BlocConsumer<VerifyCodeBloc, VerifyCodeState>(
                      listener: (context, state) {
                        if (state is VerifyCodeSuccess) {
                          showSuccessSnackBar(context, "Code vérifié avec succès".tr);
                          if (isAccountCreation) {
                            navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                              context,
                              const LoginScreen(),
                            );
                          } else {
                            navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                              context,
                              ResetPasswordScreen(
                                email: email,
                                verificationCode: state.verificationCode,
                              ),
                            );
                          }
                        } else if (state is VerifyCodeError) {
                          showErrorSnackBar(context, state.message.tr);
                        }
                      },
                      builder: (context, state) {
                        return Column(
                          children: [
                            OtpTextField(
                              numberOfFields: 4,
                              borderColor: AppColors.primaryColor,
                              focusedBorderColor: AppColors.primaryColor,
                              showFieldAsBox: true,
                              onSubmit: (String code) {
                                if (code.length == 4) {
                                  print('VerifyCodeScreen: Submitting code=$code for email=$email');
                                  context.read<VerifyCodeBloc>().add(
                                    VerifyCodeSubmitted(
                                      email: email,
                                      verificationCode: int.parse(code),
                                      codeType: isAccountCreation
                                          ? VerificationCodeType.activationDeCompte
                                          : VerificationCodeType.motDePasseOublie,
                                    ),
                                  );
                                }
                              },
                            ),
                            if (state is VerifyCodeLoading)
                              Padding(
                                padding: EdgeInsets.only(top: 20.h),
                                child: CircularProgressIndicator(color: AppColors.primaryColor),
                              ),
                          ],
                        );
                      },
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
}
