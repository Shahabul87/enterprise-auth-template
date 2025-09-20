import 'dart:io';
import 'package:flutter/services.dart';

/// Device security checks for root/jailbreak detection
class DeviceSecurity {
  static const MethodChannel _channel = MethodChannel('device_security');

  /// Check if device is rooted (Android) or jailbroken (iOS)
  static Future<bool> isDeviceCompromised() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidRoot();
      } else if (Platform.isIOS) {
        return await _checkIOSJailbreak();
      }
      return false;
    } catch (e) {
      // If we can't determine, assume it's compromised for safety
      return true;
    }
  }

  /// Check for Android root
  static Future<bool> _checkAndroidRoot() async {
    final List<String> rootIndicators = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/su/bin/su',
    ];

    for (final path in rootIndicators) {
      if (await File(path).exists()) {
        return true;
      }
    }

    // Check for root management apps
    final List<String> rootApps = [
      'com.koushikdutta.superuser',
      'com.topjohnwu.magisk',
      'eu.chainfire.supersu',
      'com.noshufou.android.su',
      'com.thirdparty.superuser',
      'com.yellowes.su',
    ];

    try {
      // This would require platform channel implementation
      final bool hasRootApps = await _channel.invokeMethod('checkRootApps', rootApps);
      if (hasRootApps) return true;
    } catch (e) {
      // Platform channel not implemented, continue with other checks
    }

    // Check for dangerous props
    try {
      final ProcessResult result = await Process.run('getprop', ['ro.debuggable']);
      if (result.stdout.toString().trim() == '1') {
        return true;
      }
    } catch (e) {
      // Process execution failed, device might be secured
    }

    return false;
  }

  /// Check for iOS jailbreak
  static Future<bool> _checkIOSJailbreak() async {
    final List<String> jailbreakIndicators = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
      '/private/var/lib/cydia',
      '/private/var/stash',
    ];

    for (final path in jailbreakIndicators) {
      if (await File(path).exists()) {
        return true;
      }
    }

    // Check if we can write to system directories
    try {
      final testFile = File('/private/test_jailbreak.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true; // If we can write, device is jailbroken
    } catch (e) {
      // Cannot write, device might be secure
    }

    // Check for Cydia URL scheme
    try {
      final bool canOpenCydia = await _channel.invokeMethod('canOpenURL', 'cydia://');
      if (canOpenCydia) return true;
    } catch (e) {
      // Platform channel not implemented
    }

    return false;
  }

  /// Check if developer mode is enabled
  static Future<bool> isDeveloperModeEnabled() async {
    if (Platform.isAndroid) {
      try {
        final ProcessResult result = await Process.run('getprop', ['ro.debuggable']);
        return result.stdout.toString().trim() == '1';
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// Check if app is running in emulator
  static Future<bool> isEmulator() async {
    if (Platform.isAndroid) {
      final ProcessResult result = await Process.run('getprop', ['ro.hardware']);
      final hardware = result.stdout.toString().trim();
      return hardware.contains('goldfish') || hardware.contains('ranchu');
    } else if (Platform.isIOS) {
      final ProcessResult result = await Process.run('uname', ['-m']);
      return result.stdout.toString().contains('x86');
    }
    return false;
  }

  /// Perform comprehensive security check
  static Future<DeviceSecurityStatus> performSecurityCheck() async {
    final isCompromised = await isDeviceCompromised();
    final isEmulatorDevice = await isEmulator();
    final isDeveloperMode = await isDeveloperModeEnabled();

    return DeviceSecurityStatus(
      isRootedOrJailbroken: isCompromised,
      isEmulator: isEmulatorDevice,
      isDeveloperModeEnabled: isDeveloperMode,
      isSecure: !isCompromised && !isEmulatorDevice && !isDeveloperMode,
    );
  }
}

/// Device security status
class DeviceSecurityStatus {
  final bool isRootedOrJailbroken;
  final bool isEmulator;
  final bool isDeveloperModeEnabled;
  final bool isSecure;

  const DeviceSecurityStatus({
    required this.isRootedOrJailbroken,
    required this.isEmulator,
    required this.isDeveloperModeEnabled,
    required this.isSecure,
  });

  Map<String, dynamic> toJson() => {
        'isRootedOrJailbroken': isRootedOrJailbroken,
        'isEmulator': isEmulator,
        'isDeveloperModeEnabled': isDeveloperModeEnabled,
        'isSecure': isSecure,
      };
}