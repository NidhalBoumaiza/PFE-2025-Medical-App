import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/authentication/data/models/medecin_model.dart';
import 'package:medical_app/features/authentication/data/models/patient_model.dart';
import 'package:medical_app/features/authentication/data/models/user_model.dart';
import 'package:medical_app/constants.dart';
import 'auth_local_data_source.dart';

enum VerificationCodeType {
  compteActive,
  activationDeCompte,
  motDePasseOublie,
  changerMotDePasse,
}

abstract class AuthRemoteDataSource {
  Future<void> signInWithGoogle();
  Future<Unit> createAccount(UserModel user, String password);
  Future<UserModel> login(String email, String password);
  Future<Unit> updateUser(UserModel user);
  Future<Unit> sendVerificationCode({
    required String email,
    required VerificationCodeType codeType,
  });
  Future<Unit> verifyCode({
    required String email,
    required int verificationCode,
    required VerificationCodeType codeType,
  });
  Future<Unit> changePassword({
    required String email,
    required String newPassword,
    required int verificationCode,
  });
  Future<Unit> updatePasswordDirect({
    required String email,
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthLocalDataSource localDataSource;
  final http.Client client; // Added client for HTTP requests

  AuthRemoteDataSourceImpl({required this.localDataSource, required this.client});

  // Helper method to handle HTTP errors
  void _handleHttpError(http.Response response) {
    if (response.statusCode == 401) {
      throw UnauthorizedException('Email ou mot de passe incorrect');
    } else if (response.statusCode == 404) {
      throw AuthException(message: 'Utilisateur non trouvé');
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      throw AuthException(
        message: responseBody['message'] ?? 'Bad request error',
      );
    } else {
      throw ServerException(message: 'Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In not implemented for Express backend');
  }

  @override
  Future<Unit> createAccount(UserModel user, String password) async {
    try {
      print('createAccount: Starting for email=${user.email}');
      final Map<String, dynamic> body = {
        'name': user.name,
        'lastName': user.lastName,
        'email': user.email.toLowerCase().trim(),
        'password': password,
        'passwordConfirm': password,
        'role': user.role,
        'gender': user.gender,
        'phoneNumber': user.phoneNumber,
      };

      if (user.dateOfBirth != null) {
        body['dateOfBirth'] = user.dateOfBirth!.toIso8601String();
      }

      if (user is PatientModel) {
        body['antecedent'] = user.antecedent;
      } else if (user is MedecinModel) {
        body['speciality'] = user.speciality;
        body['numLicence'] = user.numLicence;
        body['appointmentDuration'] = user.appointmentDuration;
      }

      print('createAccount: Sending request to ${AppConstants.signupEndpoint}');
      final response = await client.post(
        Uri.parse(AppConstants.signupEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('createAccount: Response status code: ${response.statusCode}');
      if (response.statusCode == 201) {
        print('createAccount: Account created successfully');
        return unit;
      } else {
        print('createAccount: Error response: ${response.body}');
        _handleHttpError(response);
        throw ServerException(message: 'Failed to create account');
      }
    } catch (e) {
      print('createAccount: Exception: $e');
      if (e is UnauthorizedException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      print('login: Starting for email=$email');
      final response = await client.post(
        Uri.parse(AppConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.toLowerCase().trim(),
          'password': password,
        }),
      );

      print('login: Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Save token for future authenticated requests
        await localDataSource.saveToken(responseData['token']);
        print('login: Token saved: ${responseData['token'].substring(0, 10)}...');

        // Save refresh token if available
        if (responseData['refreshToken'] != null) {
          await localDataSource.saveRefreshToken(responseData['refreshToken']);
          print('login: Refresh token saved');
        }

        // Parse user data
        final userData = responseData['data']['user'];
        print('login: User data received: ${userData['role']}');

        UserModel user;
        if (userData['role'] == 'patient') {
          user = PatientModel.fromJson(userData);
        } else if (userData['role'] == 'medecin') {
          user = MedecinModel.fromJson(userData);
        } else {
          user = UserModel.fromJson(userData);
        }

        // Cache user data locally
        await localDataSource.cacheUser(user);
        print('login: User data cached locally');

        return user;
      } else {
        print('login: Error response: ${response.body}');
        _handleHttpError(response);
        throw ServerException(message: 'Login failed');
      }
    } catch (e) {
      print('login: Exception: $e');
      if (e is UnauthorizedException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error during login: $e');
    }
  }

  @override
  Future<Unit> updateUser(UserModel user) async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final response = await client.patch(
        Uri.parse(AppConstants.updateProfileEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final updatedUserData = responseData['data']['user'];

        UserModel updatedUser;
        if (updatedUserData['role'] == 'patient') {
          updatedUser = PatientModel.fromJson(updatedUserData);
        } else if (updatedUserData['role'] == 'medecin') {
          updatedUser = MedecinModel.fromJson(updatedUserData);
        } else {
          updatedUser = UserModel.fromJson(updatedUserData);
        }

        await localDataSource.cacheUser(updatedUser);
        return unit;
      } else {
        _handleHttpError(response);
        throw ServerException(message: 'Failed to update user');
      }
    } catch (e) {
      if (e is UnauthorizedException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<Unit> sendVerificationCode({
    required String email,
    required VerificationCodeType codeType,
  }) async {
    try {
      final endpoint = codeType == VerificationCodeType.motDePasseOublie
          ? AppConstants.forgotPasswordEndpoint
          : AppConstants.verifyAccountEndpoint; // Use verifyAccount for activation

      print('sendVerificationCode: Sending to $endpoint for $email');
      final response = await client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.toLowerCase().trim()}),
      );

      print('sendVerificationCode: Response status code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return unit;
      } else {
        print('sendVerificationCode: Error response: ${response.body}');
        _handleHttpError(response);
        throw ServerException(message: 'Failed to send verification code');
      }
    } catch (e) {
      print('sendVerificationCode: Exception: $e');
      if (e is UnauthorizedException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<Unit> verifyCode({
    required String email,
    required int verificationCode,
    required VerificationCodeType codeType,
  }) async {
    try {
      final endpoint = codeType == VerificationCodeType.motDePasseOublie
          ? AppConstants.verifyResetCodeEndpoint
          : AppConstants.verifyAccountEndpoint;

      print('verifyCode: Sending to $endpoint for $email');
      final response = await client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.toLowerCase().trim(),
          'resetCode': verificationCode.toString(),
          'verificationCode': verificationCode,
        }),
      );

      print('verifyCode: Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        if (codeType == VerificationCodeType.activationDeCompte) {
          final responseData = jsonDecode(response.body);
          if (responseData['token'] != null) {
            await localDataSource.saveToken(responseData['token']);
            print('verifyCode: Token saved');
          }
          if (responseData['refreshToken'] != null) {
            await localDataSource.saveRefreshToken(responseData['refreshToken']);
            print('verifyCode: Refresh token saved');
          }
          if (responseData['data'] != null && responseData['data']['user'] != null) {
            final userData = responseData['data']['user'];
            UserModel user;
            if (userData['role'] == 'patient') {
              user = PatientModel.fromJson(userData);
            } else if (userData['role'] == 'medecin') {
              user = MedecinModel.fromJson(userData);
            } else {
              user = UserModel.fromJson(userData);
            }
            await localDataSource.cacheUser(user);
            print('verifyCode: User data cached');
          }
        }
        return unit;
      } else {
        print('verifyCode: Error response: ${response.body}');
        _handleHttpError(response);
        throw ServerException(message: 'Failed to verify code');
      }
    } catch (e) {
      print('verifyCode: Exception: $e');
      if (e is UnauthorizedException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<Unit> changePassword({
    required String email,
    required String newPassword,
    required int verificationCode,
  }) async {
    try {
      print('changePassword: Sending to ${AppConstants.resetPasswordEndpoint}');
      final response = await client.patch(
        Uri.parse(AppConstants.resetPasswordEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.toLowerCase().trim(),
          'resetCode': verificationCode.toString(),
          'password': newPassword,
          'passwordConfirm': newPassword,
        }),
      );

      print('changePassword: Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['token'] != null) {
          await localDataSource.saveToken(responseData['token']);
          print('changePassword: Token saved');
        }
        if (responseData['refreshToken'] != null) {
          await localDataSource.saveRefreshToken(responseData['refreshToken']);
          print('changePassword: Refresh token saved');
        }
        if (responseData['data'] != null && responseData['data']['user'] != null) {
          final userData = responseData['data']['user'];
          UserModel user;
          if (userData['role'] == 'patient') {
            user = PatientModel.fromJson(userData);
          } else if (userData['role'] == 'medecin') {
            user = MedecinModel.fromJson(userData);
          } else {
            user = UserModel.fromJson(userData);
          }
          await localDataSource.cacheUser(user);
          print('changePassword: User data cached');
        }
        return unit;
      } else {
        print('changePassword: Error response: ${response.body}');
        _handleHttpError(response);
        throw ServerException(message: 'Failed to change password');
      }
    } catch (e) {
      print('changePassword: Exception: $e');
      if (e is UnauthorizedException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<Unit> updatePasswordDirect({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        throw AuthException(message: 'User not authenticated');
      }

      print('updatePasswordDirect: Sending to ${AppConstants.updatePasswordEndpoint}');
      final response = await client.patch(
        Uri.parse(AppConstants.updatePasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'password': newPassword,
          'passwordConfirm': newPassword,
        }),
      );

      print('updatePasswordDirect: Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['token'] != null) {
          await localDataSource.saveToken(responseData['token']);
          print('updatePasswordDirect: Token saved');
        }
        if (responseData['refreshToken'] != null) {
          await localDataSource.saveRefreshToken(responseData['refreshToken']);
          print('updatePasswordDirect: Refresh token saved');
        }
        return unit;
      } else {
        print('updatePasswordDirect: Error response: ${response.body}');
        _handleHttpError(response);
        throw ServerException(message: 'Failed to update password');
      }
    } catch (e) {
      print('updatePasswordDirect: Exception: $e');
      if (e is UnauthorizedException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}