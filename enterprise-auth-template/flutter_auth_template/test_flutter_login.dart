import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
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

  // Your credentials
  final credentials = {
    'email': 'sham251087@gmail.com',
    'password': 'ShaM2510*##&*',
  };

  print('Testing Flutter login with your credentials...');
  print('Email: ${credentials['email']}');
  print('Password: ${credentials['password']}');
  print('URL: http://localhost:8000/api/v1/auth/login\n');

  try {
    final response = await dio.post(
      '/auth/login',
      data: credentials,
    );

    print('✅ Login successful!');
    print('Response: ${json.encode(response.data)}');

    if (response.data['data'] != null && response.data['data']['user'] != null) {
      final user = response.data['data']['user'];
      print('\nUser details:');
      print('- Email: ${user['email']}');
      print('- Name: ${user['full_name']}');
      print('- ID: ${user['id']}');
    }
  } on DioException catch (e) {
    print('❌ Login failed');
    print('Status Code: ${e.response?.statusCode}');
    print('Error Response: ${e.response?.data}');

    if (e.response?.statusCode == 401) {
      print('\n⚠️ Invalid credentials. The password might be different than what you provided.');
      print('Please check if the user exists in the database with the correct password.');
    } else if (e.response?.statusCode == 404) {
      print('\n⚠️ API endpoint not found. Check the API path configuration.');
    } else if (e.response?.statusCode == 422) {
      print('\n⚠️ Validation error. Check the request format.');
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}