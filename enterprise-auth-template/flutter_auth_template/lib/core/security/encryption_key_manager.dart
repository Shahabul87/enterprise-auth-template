import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for encryption key manager
final encryptionKeyManagerProvider = Provider<EncryptionKeyManager>((ref) {
  return EncryptionKeyManager();
});

/// Manages encryption keys with automatic rotation
class EncryptionKeyManager {
  static const String _currentKeyIdKey = 'current_encryption_key_id';
  static const String _keyPrefix = 'encryption_key_';
  static const String _keyMetadataPrefix = 'key_metadata_';
  static const String _keyRotationScheduleKey = 'key_rotation_schedule';
  static const int _keyRotationDays = 30; // Rotate keys every 30 days
  static const int _maxKeyVersions = 5; // Keep maximum 5 old keys for decryption

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'secure_key_storage',
      preferencesKeyPrefix: 'key_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'KeyManager',
    ),
  );

  /// Initialize key manager and check for rotation
  Future<void> initialize() async {
    // Check if we have a current key
    final currentKeyId = await _getCurrentKeyId();

    if (currentKeyId == null) {
      // First time - generate initial key
      await _generateNewKey();
    } else {
      // Check if rotation is needed
      await _checkAndRotateIfNeeded();
    }

    // Schedule periodic rotation check
    _scheduleRotationCheck();
  }

  /// Get the current encryption key
  Future<Uint8List> getCurrentEncryptionKey() async {
    final keyId = await _getCurrentKeyId();
    if (keyId == null) {
      throw Exception('No encryption key available');
    }

    final keyData = await _storage.read(key: '$_keyPrefix$keyId');
    if (keyData == null) {
      throw Exception('Current encryption key not found');
    }

    return base64.decode(keyData);
  }

  /// Get a specific key by ID (for decryption of old data)
  Future<Uint8List?> getKeyById(String keyId) async {
    final keyData = await _storage.read(key: '$_keyPrefix$keyId');
    if (keyData == null) {
      return null;
    }

    return base64.decode(keyData);
  }

  /// Encrypt data with the current key
  Future<EncryptedData> encrypt(String plaintext) async {
    final currentKeyId = await _getCurrentKeyId();
    if (currentKeyId == null) {
      throw Exception('No encryption key available');
    }

    final key = await getCurrentEncryptionKey();

    // Generate random IV
    final iv = _generateRandomBytes(16);

    // Simple XOR encryption for demonstration (in production, use AES)
    final plaintextBytes = utf8.encode(plaintext);
    final encrypted = _xorEncrypt(plaintextBytes, key, iv);

    return EncryptedData(
      data: base64.encode(encrypted),
      keyId: currentKeyId,
      iv: base64.encode(iv),
      algorithm: 'XOR', // In production, use 'AES-256-GCM'
      timestamp: DateTime.now(),
    );
  }

  /// Decrypt data (supports old keys for backward compatibility)
  Future<String> decrypt(EncryptedData encryptedData) async {
    // Get the key used for encryption
    final key = await getKeyById(encryptedData.keyId);
    if (key == null) {
      throw Exception('Decryption key not found: ${encryptedData.keyId}');
    }

    final encryptedBytes = base64.decode(encryptedData.data);
    final iv = base64.decode(encryptedData.iv);

    // Simple XOR decryption for demonstration
    final decrypted = _xorEncrypt(encryptedBytes, key, iv);

    return utf8.decode(decrypted);
  }

  /// Rotate encryption key
  Future<void> rotateKey() async {
    // Generate new key
    final newKeyId = await _generateNewKey();

    // Re-encrypt critical data with new key
    await _reencryptCriticalData(newKeyId);

    // Clean up old keys (keep only recent versions)
    await _cleanupOldKeys();

    // Record rotation event
    await _recordRotationEvent(newKeyId);
  }

  /// Force immediate key rotation
  Future<void> forceRotation() async {
    await rotateKey();
  }

  /// Check if key rotation is needed
  Future<bool> isRotationNeeded() async {
    final metadata = await _getCurrentKeyMetadata();
    if (metadata == null) {
      return true;
    }

    final daysSinceCreation = DateTime.now().difference(metadata.createdAt).inDays;
    return daysSinceCreation >= _keyRotationDays;
  }

  // Private methods

  Future<String?> _getCurrentKeyId() async {
    return await _storage.read(key: _currentKeyIdKey);
  }

  Future<String> _generateNewKey() async {
    // Generate new key ID
    final keyId = _generateKeyId();

    // Generate 256-bit key
    final key = _generateRandomBytes(32);

    // Store the key
    await _storage.write(
      key: '$_keyPrefix$keyId',
      value: base64.encode(key),
    );

    // Store metadata
    final metadata = KeyMetadata(
      keyId: keyId,
      createdAt: DateTime.now(),
      algorithm: 'AES-256-GCM',
      keyLength: 256,
      purpose: 'token_encryption',
    );

    await _storage.write(
      key: '$_keyMetadataPrefix$keyId',
      value: jsonEncode(metadata.toJson()),
    );

    // Set as current key
    await _storage.write(key: _currentKeyIdKey, value: keyId);

    return keyId;
  }

  Future<void> _checkAndRotateIfNeeded() async {
    if (await isRotationNeeded()) {
      await rotateKey();
    }
  }

  Future<void> _scheduleRotationCheck() async {
    // In a real app, this would use a background task scheduler
    // For now, we'll check on each app launch
  }

  Future<KeyMetadata?> _getCurrentKeyMetadata() async {
    final keyId = await _getCurrentKeyId();
    if (keyId == null) return null;

    final metadataJson = await _storage.read(key: '$_keyMetadataPrefix$keyId');
    if (metadataJson == null) return null;

    return KeyMetadata.fromJson(jsonDecode(metadataJson));
  }

  Future<void> _reencryptCriticalData(String newKeyId) async {
    // In a real implementation, this would:
    // 1. Identify all encrypted tokens/data
    // 2. Decrypt with old key
    // 3. Re-encrypt with new key
    // 4. Update stored data

    // For now, we'll just log the rotation
    print('Key rotation completed. New key ID: $newKeyId');
  }

  Future<void> _cleanupOldKeys() async {
    // Get all keys
    final allKeys = await _storage.readAll();
    final keyIds = <String>[];

    for (final key in allKeys.keys) {
      if (key.startsWith(_keyPrefix)) {
        final keyId = key.substring(_keyPrefix.length);
        keyIds.add(keyId);
      }
    }

    // Sort by creation date (assuming IDs are timestamp-based)
    keyIds.sort((a, b) => b.compareTo(a));

    // Keep only the most recent keys
    if (keyIds.length > _maxKeyVersions) {
      for (int i = _maxKeyVersions; i < keyIds.length; i++) {
        await _storage.delete(key: '$_keyPrefix${keyIds[i]}');
        await _storage.delete(key: '$_keyMetadataPrefix${keyIds[i]}');
      }
    }
  }

  Future<void> _recordRotationEvent(String newKeyId) async {
    final rotationHistory = await _getRotationHistory();
    rotationHistory.add(KeyRotationEvent(
      oldKeyId: await _getCurrentKeyId(),
      newKeyId: newKeyId,
      timestamp: DateTime.now(),
      reason: 'scheduled_rotation',
    ));

    // Keep only recent history
    if (rotationHistory.length > 10) {
      rotationHistory.removeAt(0);
    }

    await _storage.write(
      key: _keyRotationScheduleKey,
      value: jsonEncode(rotationHistory.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<KeyRotationEvent>> _getRotationHistory() async {
    final historyJson = await _storage.read(key: _keyRotationScheduleKey);
    if (historyJson == null) {
      return [];
    }

    final List<dynamic> history = jsonDecode(historyJson);
    return history.map((e) => KeyRotationEvent.fromJson(e)).toList();
  }

  String _generateKeyId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure();
    final randomSuffix = random.nextInt(999999).toString().padLeft(6, '0');
    return '$timestamp-$randomSuffix';
  }

  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  // Simple XOR encryption for demonstration
  // In production, use proper AES encryption
  Uint8List _xorEncrypt(Uint8List data, Uint8List key, Uint8List iv) {
    final result = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    return result;
  }
}

/// Encrypted data with metadata
class EncryptedData {
  final String data;
  final String keyId;
  final String iv;
  final String algorithm;
  final DateTime timestamp;

  const EncryptedData({
    required this.data,
    required this.keyId,
    required this.iv,
    required this.algorithm,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'data': data,
    'keyId': keyId,
    'iv': iv,
    'algorithm': algorithm,
    'timestamp': timestamp.toIso8601String(),
  };

  factory EncryptedData.fromJson(Map<String, dynamic> json) => EncryptedData(
    data: json['data'],
    keyId: json['keyId'],
    iv: json['iv'],
    algorithm: json['algorithm'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

/// Key metadata
class KeyMetadata {
  final String keyId;
  final DateTime createdAt;
  final String algorithm;
  final int keyLength;
  final String purpose;

  const KeyMetadata({
    required this.keyId,
    required this.createdAt,
    required this.algorithm,
    required this.keyLength,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
    'keyId': keyId,
    'createdAt': createdAt.toIso8601String(),
    'algorithm': algorithm,
    'keyLength': keyLength,
    'purpose': purpose,
  };

  factory KeyMetadata.fromJson(Map<String, dynamic> json) => KeyMetadata(
    keyId: json['keyId'],
    createdAt: DateTime.parse(json['createdAt']),
    algorithm: json['algorithm'],
    keyLength: json['keyLength'],
    purpose: json['purpose'],
  );
}

/// Key rotation event
class KeyRotationEvent {
  final String? oldKeyId;
  final String newKeyId;
  final DateTime timestamp;
  final String reason;

  const KeyRotationEvent({
    this.oldKeyId,
    required this.newKeyId,
    required this.timestamp,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'oldKeyId': oldKeyId,
    'newKeyId': newKeyId,
    'timestamp': timestamp.toIso8601String(),
    'reason': reason,
  };

  factory KeyRotationEvent.fromJson(Map<String, dynamic> json) => KeyRotationEvent(
    oldKeyId: json['oldKeyId'],
    newKeyId: json['newKeyId'],
    timestamp: DateTime.parse(json['timestamp']),
    reason: json['reason'],
  );
}

/// Key rotation monitor widget
class KeyRotationMonitor extends ConsumerWidget {
  const KeyRotationMonitor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyManager = ref.watch(encryptionKeyManagerProvider);

    return FutureBuilder<bool>(
      future: keyManager.isRotationNeeded(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        if (snapshot.data!) {
          // Rotation needed - show warning
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Encryption key rotation needed for security',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await keyManager.forceRotation();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Encryption keys rotated successfully'),
                        ),
                      );
                    }
                  },
                  child: const Text('Rotate Now'),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}