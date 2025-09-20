// Mocks generated for auth flow integration test
// This file has been manually created since build_runner cannot generate it

import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/data/services/auth_service.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
// Removed google_sign_in import to avoid conflict
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/data/models/auth_response.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';

// MockAuthService
class MockAuthService extends Mock implements AuthService {
  @override
  Future<AuthResponseData> login(LoginRequest? request) =>
      super.noSuchMethod(
        Invocation.method(#login, [request]),
        returnValue: Future.value(AuthResponseData(
          user: User(
            id: '',
            email: '',
            name: '',
            isEmailVerified: false,
            isTwoFactorEnabled: false,
            roles: const [],
            permissions: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          accessToken: '',
          refreshToken: '',
        )),
        returnValueForMissingStub: Future.value(AuthResponseData(
          user: User(
            id: '',
            email: '',
            name: '',
            isEmailVerified: false,
            isTwoFactorEnabled: false,
            roles: const [],
            permissions: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          accessToken: '',
          refreshToken: '',
        )),
      );

  @override
  Future<AuthResponseData> register(RegisterRequest? request) =>
      super.noSuchMethod(
        Invocation.method(#register, [request]),
        returnValue: Future.value(AuthResponseData(
          user: User(
            id: '',
            email: '',
            name: '',
            isEmailVerified: false,
            isTwoFactorEnabled: false,
            roles: const [],
            permissions: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          accessToken: '',
          refreshToken: '',
        )),
        returnValueForMissingStub: Future.value(AuthResponseData(
          user: User(
            id: '',
            email: '',
            name: '',
            isEmailVerified: false,
            isTwoFactorEnabled: false,
            roles: const [],
            permissions: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          accessToken: '',
          refreshToken: '',
        )),
      );

  @override
  Future<void> logout() => super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<User> getCurrentUser() => super.noSuchMethod(
        Invocation.method(#getCurrentUser, []),
        returnValue: Future.value(User(
          id: '',
          email: '',
          name: '',
          isEmailVerified: false,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )),
        returnValueForMissingStub: Future.value(User(
          id: '',
          email: '',
          name: '',
          isEmailVerified: false,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )),
      );

  @override
  Future<AuthResponseData> verifyTwoFactorCode(String? code) =>
      super.noSuchMethod(
        Invocation.method(#verifyTwoFactorCode, [code]),
        returnValue: Future.value(AuthResponseData(
          user: User(
            id: '',
            email: '',
            name: '',
            isEmailVerified: false,
            isTwoFactorEnabled: false,
            roles: const [],
            permissions: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          accessToken: '',
          refreshToken: '',
        )),
        returnValueForMissingStub: Future.value(AuthResponseData(
          user: User(
            id: '',
            email: '',
            name: '',
            isEmailVerified: false,
            isTwoFactorEnabled: false,
            roles: const [],
            permissions: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          accessToken: '',
          refreshToken: '',
        )),
      );
}

// MockOAuthService
class MockOAuthService extends Mock implements OAuthService {
  @override
  Future<dynamic> signInWithGoogle() => super.noSuchMethod(
        Invocation.method(#signInWithGoogle, []),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  Future<void> signOutFromGoogle() => super.noSuchMethod(
        Invocation.method(#signOutFromGoogle, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<bool> isGoogleSignedIn() => super.noSuchMethod(
        Invocation.method(#isGoogleSignedIn, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false),
      );
}

// MockSecureStorageService
class MockSecureStorageService extends Mock implements SecureStorageService {
  @override
  Future<String?> getAccessToken() => super.noSuchMethod(
        Invocation.method(#getAccessToken, []),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  Future<String?> getRefreshToken() => super.noSuchMethod(
        Invocation.method(#getRefreshToken, []),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  Future<void> setAccessToken(String? token) => super.noSuchMethod(
        Invocation.method(#setAccessToken, [token]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> setRefreshToken(String? token) => super.noSuchMethod(
        Invocation.method(#setRefreshToken, [token]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> clearTokens() => super.noSuchMethod(
        Invocation.method(#clearTokens, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<String?> read({required String key}) => super.noSuchMethod(
        Invocation.method(#read, [], {#key: key}),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  Future<void> write({required String key, required String value}) =>
      super.noSuchMethod(
        Invocation.method(#write, [], {#key: key, #value: value}),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> delete({required String key}) => super.noSuchMethod(
        Invocation.method(#delete, [], {#key: key}),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> deleteAll() => super.noSuchMethod(
        Invocation.method(#deleteAll, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}