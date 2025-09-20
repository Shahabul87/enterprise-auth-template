import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';

final accountLockoutServiceProvider = Provider<AccountLockoutService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AccountLockoutService(secureStorage);
});

class AccountLockoutService {
  final SecureStorageService _secureStorage;

  // Configuration
  static const int maxFailedAttempts = 5;
  static const int lockoutDurationMinutes = 30;
  static const int warningThreshold = 3;

  // Storage keys
  static const String _failedAttemptsKey = 'failed_login_attempts';
  static const String _lockoutUntilKey = 'account_lockout_until';
  static const String _lastFailedAttemptKey = 'last_failed_attempt';

  AccountLockoutService(this._secureStorage);

  /// Check if account is currently locked
  Future<bool> isAccountLocked() async {
    final lockoutUntilStr = await _secureStorage.read(key: _lockoutUntilKey);
    if (lockoutUntilStr == null) return false;

    final lockoutUntil = DateTime.tryParse(lockoutUntilStr);
    if (lockoutUntil == null) return false;

    if (DateTime.now().isAfter(lockoutUntil)) {
      // Lockout period has expired, clear it
      await clearLockout();
      return false;
    }

    return true;
  }

  /// Get remaining lockout time in minutes
  Future<int> getRemainingLockoutMinutes() async {
    final lockoutUntilStr = await _secureStorage.read(key: _lockoutUntilKey);
    if (lockoutUntilStr == null) return 0;

    final lockoutUntil = DateTime.tryParse(lockoutUntilStr);
    if (lockoutUntil == null) return 0;

    final remaining = lockoutUntil.difference(DateTime.now());
    if (remaining.isNegative) return 0;

    return remaining.inMinutes + 1; // Round up
  }

  /// Record a failed login attempt
  Future<AccountLockoutStatus> recordFailedAttempt(String email) async {
    // Check if already locked
    if (await isAccountLocked()) {
      final remainingMinutes = await getRemainingLockoutMinutes();
      return AccountLockoutStatus(
        isLocked: true,
        remainingAttempts: 0,
        remainingLockoutMinutes: remainingMinutes,
        message: 'Account is locked. Please try again in $remainingMinutes minutes.',
      );
    }

    // Get current failed attempts
    final attemptsStr = await _secureStorage.read(key: '$_failedAttemptsKey:$email') ?? '0';
    int attempts = int.tryParse(attemptsStr) ?? 0;

    // Check if last attempt was more than 1 hour ago, reset counter
    final lastAttemptStr = await _secureStorage.read(key: '$_lastFailedAttemptKey:$email');
    if (lastAttemptStr != null) {
      final lastAttempt = DateTime.tryParse(lastAttemptStr);
      if (lastAttempt != null &&
          DateTime.now().difference(lastAttempt).inHours >= 1) {
        attempts = 0;
      }
    }

    // Increment attempts
    attempts++;
    await _secureStorage.write(
      key: '$_failedAttemptsKey:$email',
      value: attempts.toString(),
    );
    await _secureStorage.write(
      key: '$_lastFailedAttemptKey:$email',
      value: DateTime.now().toIso8601String(),
    );

    // Check if should lock account
    if (attempts >= maxFailedAttempts) {
      final lockoutUntil = DateTime.now().add(
        Duration(minutes: lockoutDurationMinutes),
      );
      await _secureStorage.write(
        key: _lockoutUntilKey,
        value: lockoutUntil.toIso8601String(),
      );

      return AccountLockoutStatus(
        isLocked: true,
        remainingAttempts: 0,
        remainingLockoutMinutes: lockoutDurationMinutes,
        message: 'Too many failed attempts. Account locked for $lockoutDurationMinutes minutes.',
      );
    }

    // Calculate remaining attempts
    final remainingAttempts = maxFailedAttempts - attempts;
    String message = 'Invalid credentials. $remainingAttempts attempts remaining.';

    if (attempts >= warningThreshold) {
      message = 'Warning: $remainingAttempts attempts remaining before account lockout.';
    }

    return AccountLockoutStatus(
      isLocked: false,
      remainingAttempts: remainingAttempts,
      remainingLockoutMinutes: 0,
      message: message,
    );
  }

  /// Clear failed attempts after successful login
  Future<void> clearFailedAttempts(String email) async {
    await _secureStorage.delete(key: '$_failedAttemptsKey:$email');
    await _secureStorage.delete(key: '$_lastFailedAttemptKey:$email');
  }

  /// Clear lockout (admin function or after timeout)
  Future<void> clearLockout() async {
    await _secureStorage.delete(key: _lockoutUntilKey);
  }

  /// Get current failed attempts count
  Future<int> getFailedAttempts(String email) async {
    final attemptsStr = await _secureStorage.read(key: '$_failedAttemptsKey:$email');
    return int.tryParse(attemptsStr ?? '0') ?? 0;
  }
}

class AccountLockoutStatus {
  final bool isLocked;
  final int remainingAttempts;
  final int remainingLockoutMinutes;
  final String message;

  AccountLockoutStatus({
    required this.isLocked,
    required this.remainingAttempts,
    required this.remainingLockoutMinutes,
    required this.message,
  });
}