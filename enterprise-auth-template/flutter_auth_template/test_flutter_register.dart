import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
  // Configure Dio exactly like the Flutter app
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter Enterprise Auth App/1.0.0',
    },
  ));

  print('Testing Flutter app register flow...\n');

  // Test registration data
  final registerData = {
    'email': 'testuser${DateTime.now().millisecondsSinceEpoch}@example.com',
    'password': 'TestPassword123!',
    'confirm_password': 'TestPassword123!',
    'full_name': 'Test User',
  };

  try {
    print('1. Sending register request...');
    print('   URL: http://localhost:8000/api/v1/auth/register');
    print('   Email: ${registerData['email']}');
    print('   Name: ${registerData['full_name']}');

    final response = await dio.post(
      '/auth/register',
      data: registerData,
    );

    print('\n✅ Registration successful!');
    print('Status: ${response.statusCode}');

    if (response.data != null) {
      print('\nResponse: ${json.encode(response.data)}');
    }

  } on DioException catch (e) {
    print('\n❌ Registration failed with DioException');
    print('Error Type: ${e.type}');
    print('Status Code: ${e.response?.statusCode}');
    print('Error Message: ${e.message}');
    print('Response Data: ${e.response?.data}');
  } catch (e) {
    print('\n❌ Unexpected error: $e');
  }

  // Test forgot password
  print('\n\n2. Testing forgot password flow...');

  final forgotPasswordData = {
    'email': 'isham251087@gmail.com',
  };

  try {
    print('   URL: http://localhost:8000/api/v1/auth/forgot-password');
    print('   Email: ${forgotPasswordData['email']}');

    final response = await dio.post(
      '/auth/forgot-password',
      data: forgotPasswordData,
    );

    print('\n✅ Forgot password request successful!');
    print('Status: ${response.statusCode}');

    if (response.data != null) {
      print('Response: ${json.encode(response.data)}');
    }

  } on DioException catch (e) {
    print('\n❌ Forgot password failed');
    print('Status Code: ${e.response?.statusCode}');
    print('Response Data: ${e.response?.data}');
  } catch (e) {
    print('\n❌ Unexpected error: $e');
  }
}