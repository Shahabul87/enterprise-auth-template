import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_auth_template/data/services/auth_service.dart';
import 'package:flutter_auth_template/core/network/api_client.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      authService = AuthService(mockApiClient);
    });

    test('should be created', () {
      expect(authService, isA<AuthService>());
    });

    test('should handle login request', () async {
      // Arrange
      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final responseData = Response<Map<String, dynamic>>(
        data: {
          'success': true,
          'data': {
            'accessToken': 'mock_token',
            'user': {
              'id': '1',
              'email': 'test@example.com',
              'name': 'Test User',
              'isEmailVerified': true,
              'isTwoFactorEnabled': false,
              'roles': ['user'],
              'permissions': [],
              'createdAt': '2023-01-01T00:00:00Z',
              'updatedAt': '2023-01-01T00:00:00Z',
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/login'),
      );

      when(mockApiClient.post<Map<String, dynamic>>(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => responseData);

      // Act
      final result = await authService.login(loginRequest);

      // Assert
      expect(result, isNotNull);
      verify(mockApiClient.post<Map<String, dynamic>>(
        any,
        data: anyNamed('data'),
      )).called(1);
    });

    test('should handle logout request', () async {
      // Arrange
      final responseData = Response<Map<String, dynamic>>(
        data: {
          'success': true,
          'message': 'Logged out successfully'
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/logout'),
      );

      when(mockApiClient.post<Map<String, dynamic>>(any))
          .thenAnswer((_) async => responseData);

      // Act
      await authService.logout();

      // Assert
      verify(mockApiClient.post<Map<String, dynamic>>(any)).called(1);
    });
  });
}