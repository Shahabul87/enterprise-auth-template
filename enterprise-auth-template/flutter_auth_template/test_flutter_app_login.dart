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

  print('Testing Flutter app login flow...\n');

  // Test credentials
  final credentials = {
    'email': 'isham251087@gmail.com',
    'password': 'ShaM2510*##&*',
  };

  try {
    print('1. Sending login request...');
    print('   URL: http://localhost:8000/api/v1/auth/login');
    print('   Email: ${credentials['email']}');
    print('   Password: ${credentials['password']}');

    final response = await dio.post(
      '/auth/login',
      data: credentials,
    );

    print('\n✅ Login successful!');
    print('Status: ${response.statusCode}');

    // Check response structure
    if (response.data != null) {
      print('\nResponse structure:');
      print('- success: ${response.data['success']}');
      print('- data exists: ${response.data['data'] != null}');

      if (response.data['data'] != null) {
        final data = response.data['data'];
        print('- user exists: ${data['user'] != null}');
        print('- accessToken exists: ${data['accessToken'] != null}');
        print('- refreshToken exists: ${data['refreshToken'] != null}');

        if (data['user'] != null) {
          print('\nUser data:');
          print('- Email: ${data['user']['email']}');
          print('- Name: ${data['user']['full_name']}');
          print('- Active: ${data['user']['is_active']}');
          print('- Verified: ${data['user']['isEmailVerified']}');
        }

        // Check token
        final token = data['accessToken'];
        if (token != null && token.toString().isNotEmpty) {
          print('\n✅ Access token received: ${token.toString().substring(0, 20)}...');
        } else {
          print('\n⚠️ WARNING: Access token is empty or null!');
          print('This might cause "Exception: An error occurred" in the app');
        }
      }
    }

  } on DioException catch (e) {
    print('\n❌ Login failed with DioException');
    print('Error Type: ${e.type}');
    print('Status Code: ${e.response?.statusCode}');
    print('Error Message: ${e.message}');
    print('Response Data: ${e.response?.data}');

    if (e.response?.data != null) {
      final errorData = e.response!.data;
      if (errorData['detail'] != null) {
        print('\nError details:');
        print('- ${errorData['detail']}');
      }
    }
  } catch (e) {
    print('\n❌ Unexpected error: $e');
    print('This is likely what causes "Exception: An error occurred" in the app');
  }
}