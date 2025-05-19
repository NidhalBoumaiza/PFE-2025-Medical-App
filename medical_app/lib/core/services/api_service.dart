import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for the API
  static const String baseUrl = 'http://localhost:3000/api';

  // Constructor to allow dependency injection
  ApiService();

  // Headers for API requests
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle API response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'An error occurred');
    }
  }

  // Generic request methods
  static Future<dynamic> getRequest(String url) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    return _handleResponse(response);
  }

  static Future<dynamic> postRequest(
    String url,
    Map<String, dynamic> data,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> putRequest(
    String url,
    Map<String, dynamic> data,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patchRequest(
    String url,
    Map<String, dynamic> data,
  ) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> deleteRequest(String url) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);
    return _handleResponse(response);
  }

  // Authentication methods
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final data = _handleResponse(response);

    // Save token to shared preferences
    if (data != null && data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      await prefs.setString('user_id', data['user']['_id']);
      await prefs.setString('user_role', data['user']['role']);
    }

    return data;
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    return _handleResponse(response);
  }

  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    return true;
  }

  static Future<Map<String, dynamic>> verifyAccount(
    String email,
    String code,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'verificationCode': code}),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'passwordResetCode': code,
        'newPassword': newPassword,
      }),
    );

    return _handleResponse(response);
  }

  // User methods
  static Future<Map<String, dynamic>> getUserProfile() async {
    final headers = await _getHeaders();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> userData,
  ) async {
    final headers = await _getHeaders();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: headers,
      body: json.encode(userData),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final headers = await _getHeaders();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/change-password'),
      headers: headers,
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    return _handleResponse(response);
  }

  // Doctor methods
  static Future<List<dynamic>> getDoctorsBySpecialty(String specialty) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/doctors?specialty=$specialty'),
      headers: headers,
    );

    final data = _handleResponse(response);
    return data['doctors'] ?? [];
  }

  static Future<Map<String, dynamic>> getDoctorProfile(String doctorId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/doctors/$doctorId'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // Appointment methods
  static Future<List<dynamic>> getAppointments({
    String? patientId,
    String? doctorId,
  }) async {
    final headers = await _getHeaders();
    String url = '$baseUrl/appointments?';

    if (patientId != null) url += 'patientId=$patientId&';
    if (doctorId != null) url += 'doctorId=$doctorId&';

    final response = await http.get(Uri.parse(url), headers: headers);

    final data = _handleResponse(response);
    return data['appointments'] ?? [];
  }

  static Future<Map<String, dynamic>> createAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: headers,
      body: json.encode(appointmentData),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    final headers = await _getHeaders();

    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/status'),
      headers: headers,
      body: json.encode({'status': status}),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getAppointmentDetails(
    String appointmentId,
  ) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/appointments/$appointmentId'),
      headers: headers,
    );

    return _handleResponse(response);
  }
}
