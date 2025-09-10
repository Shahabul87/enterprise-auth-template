import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:flutter_auth_template/services/auth_service.dart';
import 'package:flutter_auth_template/services/api/api_client.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([ApiClient, SecureStorageService])
void main() {
  group('AuthService', () {
    late MockApiClient mockApiClient;
    late MockSecureStorageService mockSecureStorage;
    late AuthService authService;

    setUp(() {
      mockApiClient = MockApiClient();
      mockSecureStorage = MockSecureStorageService();
      authService = AuthService(mockApiClient, mockSecureStorage);
    });

    group('login', () {
      test('should return success response when login is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const request = LoginRequest(email: email, password: password);
        
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'success': true,
            'data': {
              'user': {
                'id': '123',
                'email': email,
                'name': 'Test User',
                'isEmailVerified': true,
                'isTwoFactorEnabled': false,
                'roles': <String>[],
                'permissions': <String>[],
                'createdAt': '2024-01-01T00:00:00Z',
                'updatedAt': '2024-01-01T00:00:00Z',
              },
              'access_token': 'access_token',
              'refresh_token': 'refresh_token',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/login'),
        );

        when(mockApiClient.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await authService.login(request);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull?.email, email);
        expect(result.dataOrNull?.name, 'Test User');
        
        verify(mockApiClient.post('/api/v1/auth/login', data: request.toJson()));
        verify(mockSecureStorage.storeAccessToken('access_token'));
        verify(mockSecureStorage.storeRefreshToken('refresh_token'));
      });

      test('should return error response when login fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';
        const request = LoginRequest(email: email, password: password);
        
        when(mockApiClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/auth/login'),
              response: Response<Map<String, dynamic>>(
                data: {
                  'success': false,
                  'error': {
                    'code': 'INVALID_CREDENTIALS',
                    'message': 'Invalid email or password',
                  },
                },
                statusCode: 401,
                requestOptions: RequestOptions(path: '/auth/login'),
              ),
            ));

        // Act
        final result = await authService.login(request);

        // Assert
        expect(result.isError, true);
        expect(result.errorMessage?.contains('Invalid email or password'), true);
      });
    });

    group('register', () {
      test('should return success response when registration is successful', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const name = 'New User';
        const request = RegisterRequest(
          email: email,
          password: password,
          name: name,
        );
        
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'success': true,
            'data': {
              'user': {
                'id': '124',
                'email': email,
                'name': name,
                'isEmailVerified': false,
                'isTwoFactorEnabled': false,
                'roles': <String>[],
                'permissions': <String>[],
                'createdAt': '2024-01-01T00:00:00Z',
                'updatedAt': '2024-01-01T00:00:00Z',
              },
              'access_token': 'new_access_token',
              'refresh_token': 'new_refresh_token',
            },
          },
          statusCode: 201,
          requestOptions: RequestOptions(path: '/auth/register'),
        );

        when(mockApiClient.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await authService.register(request);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull?.email, email);
        expect(result.dataOrNull?.name, name);
        expect(result.dataOrNull?.isEmailVerified, false);
        
        verify(mockApiClient.post('/api/v1/auth/register', data: request.toJson()));
      });
    });

    group('logout', () {
      test('should clear all tokens and return success', () async {
        // Arrange
        when(mockApiClient.post(any)).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: '/auth/logout'),
          statusCode: 200,
        ));

        // Act
        final result = await authService.logout();

        // Assert
        expect(result.isSuccess, true);
        verify(mockApiClient.post('/api/v1/auth/logout'));
        verify(mockSecureStorage.clearAll());
      });

      test('should clear tokens even if API call fails', () async {
        // Arrange
        when(mockApiClient.post(any)).thenThrow(
          DioException(requestOptions: RequestOptions(path: '/auth/logout')),
        );

        // Act
        final result = await authService.logout();

        // Assert
        expect(result.isSuccess, true);
        verify(mockSecureStorage.clearAll());
      });
    });

    group('getCurrentUser', () {
      test('should return user data when request is successful', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'success': true,
            'data': {
              'id': '123',
              'email': 'test@example.com',
              'name': 'Test User',
              'isEmailVerified': true,
              'isTwoFactorEnabled': false,
              'roles': <String>[],
              'permissions': <String>[],
              'createdAt': '2024-01-01T00:00:00Z',
              'updatedAt': '2024-01-01T00:00:00Z',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/me'),
        );

        when(mockApiClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull?.id, '123');
        expect(result.dataOrNull?.email, 'test@example.com');
        
        verify(mockApiClient.get('/api/v1/auth/me'));
      });
    });

    group('refreshToken', () {
      test('should return true when token refresh is successful', () async {
        // Arrange
        const refreshToken = 'valid_refresh_token';
        when(mockSecureStorage.getRefreshToken())
            .thenAnswer((_) async => refreshToken);
        
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'success': true,
            'data': {
              'access_token': 'new_access_token',
              'refresh_token': 'new_refresh_token',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/refresh'),
        );

        when(mockApiClient.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await authService.refreshToken();

        // Assert
        expect(result, true);
        verify(mockSecureStorage.storeAccessToken('new_access_token'));
        verify(mockSecureStorage.storeRefreshToken('new_refresh_token'));
      });

      test('should return false when no refresh token exists', () async {
        // Arrange
        when(mockSecureStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        // Act
        final result = await authService.refreshToken();

        // Assert
        expect(result, false);
        verifyNever(mockApiClient.post(any, data: anyNamed('data')));
      });
    });
  });
}