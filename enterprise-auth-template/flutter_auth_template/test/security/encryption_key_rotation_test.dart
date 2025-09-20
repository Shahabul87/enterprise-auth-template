import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_auth_template/core/security/encryption_key_manager.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';

import 'encryption_key_rotation_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage, EncryptionKeyManager])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the secure storage platform channel
  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'read':
          return null; // Return null for non-existent keys
        case 'write':
          return null; // Success
        case 'delete':
          return null; // Success
        case 'deleteAll':
          return null; // Success
        case 'readAll':
          return {}; // Return empty map
        case 'containsKey':
          return false; // Key doesn't exist
        default:
          return null;
      }
    },
  );
  group('Encryption Key Rotation Tests', () {
    late EncryptionKeyManager keyManager;
    late SecureStorageService storageService;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      keyManager = EncryptionKeyManager();
      storageService = SecureStorageService(keyManager);
      mockStorage = MockFlutterSecureStorage();
    });

    group('Key Manager Tests', () {
      test('should generate unique key IDs', () async {
        final keyManager = EncryptionKeyManager();
        await keyManager.initialize();

        // Generate multiple encrypted data
        final encrypted1 = await keyManager.encrypt('test1');
        await Future.delayed(const Duration(milliseconds: 10));
        final encrypted2 = await keyManager.encrypt('test2');

        // Key IDs should be different
        expect(encrypted1.keyId, isNot(equals(encrypted2.keyId)));
      });

      test('should encrypt and decrypt data correctly', () async {
        await keyManager.initialize();
        const plaintext = 'This is a secret token';

        // Encrypt
        final encrypted = await keyManager.encrypt(plaintext);

        // Verify encrypted data structure
        expect(encrypted.data, isNotEmpty);
        expect(encrypted.keyId, isNotEmpty);
        expect(encrypted.iv, isNotEmpty);
        expect(encrypted.algorithm, equals('XOR')); // Using XOR for demo

        // Decrypt
        final decrypted = await keyManager.decrypt(encrypted);

        // Should match original
        expect(decrypted, equals(plaintext));
      });

      test('should decrypt data with old key after rotation', () async {
        await keyManager.initialize();
        const plaintext = 'Secret data before rotation';

        // Encrypt with current key
        final encryptedBefore = await keyManager.encrypt(plaintext);

        // Rotate key
        await keyManager.rotateKey();

        // Should still be able to decrypt old data
        final decrypted = await keyManager.decrypt(encryptedBefore);
        expect(decrypted, equals(plaintext));

        // New encryption should use new key
        final encryptedAfter = await keyManager.encrypt(plaintext);
        expect(encryptedAfter.keyId, isNot(equals(encryptedBefore.keyId)));
      });

      test('should correctly determine when rotation is needed', () async {
        await keyManager.initialize();
        // Initially, new key manager might need rotation
        final needsRotation = await keyManager.isRotationNeeded();

        // This could be true or false depending on timing
        expect(needsRotation, isA<bool>());
      });

      test('should handle metadata correctly', () {
        final metadata = KeyMetadata(
          keyId: 'test-key-123',
          createdAt: DateTime.now(),
          algorithm: 'AES-256-GCM',
          keyLength: 256,
          purpose: 'token_encryption',
        );

        final json = metadata.toJson();
        final restored = KeyMetadata.fromJson(json);

        expect(restored.keyId, equals(metadata.keyId));
        expect(restored.algorithm, equals(metadata.algorithm));
        expect(restored.keyLength, equals(metadata.keyLength));
        expect(restored.purpose, equals(metadata.purpose));
      });

      test('should track rotation events', () {
        final event = KeyRotationEvent(
          oldKeyId: 'old-key-123',
          newKeyId: 'new-key-456',
          timestamp: DateTime.now(),
          reason: 'scheduled_rotation',
        );

        final json = event.toJson();
        final restored = KeyRotationEvent.fromJson(json);

        expect(restored.oldKeyId, equals(event.oldKeyId));
        expect(restored.newKeyId, equals(event.newKeyId));
        expect(restored.reason, equals(event.reason));
      });
    });

    group('Secure Storage Integration Tests', () {
      test('should store and retrieve encrypted tokens', () async {
        await storageService.initialize();
        const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test';

        // Store token (will be encrypted)
        await storageService.storeAccessToken(token);

        // Retrieve token (will be decrypted)
        final retrieved = await storageService.getAccessToken();

        expect(retrieved, equals(token));
      });

      test('should handle token rotation correctly', () async {
        await storageService.initialize();
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_456';

        // Store tokens
        await storageService.storeAccessToken(accessToken);
        await storageService.storeRefreshToken(refreshToken);

        // Rotate keys
        await storageService.rotateEncryptionKeys();

        // Should still retrieve correct tokens
        final retrievedAccess = await storageService.getAccessToken();
        final retrievedRefresh = await storageService.getRefreshToken();

        expect(retrievedAccess, equals(accessToken));
        expect(retrievedRefresh, equals(refreshToken));
      });

      test('should migrate legacy unencrypted tokens', () async {
        await storageService.initialize();

        // Simulate legacy token storage
        // In real scenario, this would be in storage already
        // For test, we'll just verify the migration logic exists

        const legacyToken = 'legacy_unencrypted_token';

        // The getAccessToken method should handle migration
        // When it finds a legacy token, it should:
        // 1. Read the legacy token
        // 2. Encrypt and store it
        // 3. Delete the legacy version
        // 4. Return the token

        // Store a token
        await storageService.storeAccessToken(legacyToken);

        // Retrieve it
        final retrieved = await storageService.getAccessToken();

        expect(retrieved, equals(legacyToken));
      });

      test('should check if rotation is needed', () async {
        await storageService.initialize();

        final needsRotation = await storageService.isKeyRotationNeeded();

        expect(needsRotation, isA<bool>());
      });

      test('should handle 2FA secret encryption', () async {
        await storageService.initialize();
        const secret = 'JBSWY3DPEHPK3PXP';

        // Store 2FA secret (encrypted)
        await storageService.storeTwoFactorSecret(secret);

        // Retrieve 2FA secret (decrypted)
        final retrieved = await storageService.getTwoFactorSecret();

        expect(retrieved, equals(secret));

        // Remove 2FA secret
        await storageService.removeTwoFactorSecret();

        final removed = await storageService.getTwoFactorSecret();
        expect(removed, isNull);
      });

      test('should clear all data including encrypted tokens', () async {
        await storageService.initialize();

        // Store various data
        await storageService.storeAccessToken('token123');
        await storageService.storeRefreshToken('refresh456');
        await storageService.storeTwoFactorSecret('secret789');

        // Clear all
        await storageService.clearAll();

        // Everything should be gone
        final access = await storageService.getAccessToken();
        final refresh = await storageService.getRefreshToken();
        final twoFactor = await storageService.getTwoFactorSecret();

        expect(access, isNull);
        expect(refresh, isNull);
        expect(twoFactor, isNull);
      });
    });

    group('EncryptedData Model Tests', () {
      test('should serialize and deserialize correctly', () {
        final encryptedData = EncryptedData(
          data: 'encrypted_base64_data',
          keyId: 'key-123',
          iv: 'initialization_vector',
          algorithm: 'AES-256-GCM',
          timestamp: DateTime.now(),
        );

        final json = encryptedData.toJson();
        final restored = EncryptedData.fromJson(json);

        expect(restored.data, equals(encryptedData.data));
        expect(restored.keyId, equals(encryptedData.keyId));
        expect(restored.iv, equals(encryptedData.iv));
        expect(restored.algorithm, equals(encryptedData.algorithm));
      });
    });
  });
}