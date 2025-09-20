import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider for consent manager
final consentManagerProvider = Provider<ConsentManager>((ref) {
  return ConsentManager();
});

/// GDPR Consent Management System
///
/// Manages user consent for data processing in compliance with GDPR.
/// Tracks consent history, preferences, and provides audit trail.
class ConsentManager {
  static const String _storageKey = 'gdpr_consent_preferences';
  static const String _historyKey = 'gdpr_consent_history';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ConsentPreferences? _currentPreferences;
  final List<ConsentRecord> _consentHistory = [];

  /// Initialize consent manager
  Future<void> initialize() async {
    await _loadPreferences();
    await _loadHistory();
  }

  /// Load saved consent preferences
  Future<void> _loadPreferences() async {
    try {
      final stored = await _storage.read(key: _storageKey);
      if (stored != null) {
        final json = jsonDecode(stored);
        _currentPreferences = ConsentPreferences.fromJson(json);
      }
    } catch (e) {
      debugPrint('Failed to load consent preferences: $e');
    }
  }

  /// Load consent history
  Future<void> _loadHistory() async {
    try {
      final stored = await _storage.read(key: _historyKey);
      if (stored != null) {
        final List<dynamic> jsonList = jsonDecode(stored);
        _consentHistory.clear();
        _consentHistory.addAll(
          jsonList.map((json) => ConsentRecord.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to load consent history: $e');
    }
  }

  /// Save consent preferences
  Future<void> _savePreferences() async {
    if (_currentPreferences != null) {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(_currentPreferences!.toJson()),
      );
    }
  }

  /// Save consent history
  Future<void> _saveHistory() async {
    // Keep only last 100 records to prevent excessive storage
    final historyToSave = _consentHistory.take(100).toList();
    await _storage.write(
      key: _historyKey,
      value: jsonEncode(historyToSave.map((r) => r.toJson()).toList()),
    );
  }

  /// Get current consent preferences
  ConsentPreferences? get currentPreferences => _currentPreferences;

  /// Check if user has given initial consent
  bool get hasGivenConsent => _currentPreferences != null;

  /// Check if specific consent type is granted
  bool isConsentGranted(ConsentType type) {
    return _currentPreferences?.consents[type] ?? false;
  }

  /// Update consent preferences
  Future<void> updateConsent({
    required Map<ConsentType, bool> consents,
    String? userId,
    ConsentMethod method = ConsentMethod.explicit,
  }) async {
    final oldPreferences = _currentPreferences;

    _currentPreferences = ConsentPreferences(
      userId: userId ?? _currentPreferences?.userId,
      consents: consents,
      timestamp: DateTime.now(),
      version: ConsentVersion.current,
      ipAddress: await _getIpAddress(),
      method: method,
    );

    // Record the consent change in history
    _consentHistory.insert(0, ConsentRecord(
      timestamp: DateTime.now(),
      userId: _currentPreferences!.userId,
      previousConsents: oldPreferences?.consents ?? {},
      newConsents: consents,
      changeReason: 'User updated preferences',
      method: method,
    ));

    await _savePreferences();
    await _saveHistory();
  }

  /// Withdraw all consents
  Future<void> withdrawAllConsents({String? userId}) async {
    final withdrawnConsents = Map.fromEntries(
      ConsentType.values.map((type) => MapEntry(type, false)),
    );

    // Keep essential consent that cannot be withdrawn
    withdrawnConsents[ConsentType.essential] = true;

    await updateConsent(
      consents: withdrawnConsents,
      userId: userId,
      method: ConsentMethod.withdrawal,
    );
  }

  /// Get consent history for audit
  List<ConsentRecord> getConsentHistory({String? userId}) {
    if (userId != null) {
      return _consentHistory.where((r) => r.userId == userId).toList();
    }
    return List.from(_consentHistory);
  }

  /// Export consent data for GDPR compliance
  Map<String, dynamic> exportConsentData() {
    return {
      'currentPreferences': _currentPreferences?.toJson(),
      'consentHistory': _consentHistory.map((r) => r.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Clear all consent data (for account deletion)
  Future<void> clearAllConsentData() async {
    _currentPreferences = null;
    _consentHistory.clear();
    await _storage.delete(key: _storageKey);
    await _storage.delete(key: _historyKey);
  }

  /// Get IP address for consent tracking
  Future<String?> _getIpAddress() async {
    // In production, this would get the actual IP
    // For now, return a placeholder
    return 'client-ip';
  }

  /// Check if re-consent is needed (e.g., after policy update)
  bool needsReconsent(ConsentVersion requiredVersion) {
    if (_currentPreferences == null) return true;
    return _currentPreferences!.version.index < requiredVersion.index;
  }

  /// Get consent text for display
  static String getConsentText(ConsentType type) {
    switch (type) {
      case ConsentType.essential:
        return 'Essential cookies and data processing necessary for the app to function';
      case ConsentType.analytics:
        return 'Analytics cookies to help us understand how you use our app';
      case ConsentType.marketing:
        return 'Marketing cookies to show you relevant ads and measure their effectiveness';
      case ConsentType.preferences:
        return 'Preference cookies to remember your settings and choices';
      case ConsentType.thirdParty:
        return 'Third-party services integration for enhanced functionality';
      case ConsentType.dataSharing:
        return 'Sharing anonymized data with partners for service improvement';
      case ConsentType.biometric:
        return 'Using biometric authentication for secure access';
      case ConsentType.location:
        return 'Accessing location data for location-based services';
      case ConsentType.pushNotifications:
        return 'Sending push notifications for important updates';
    }
  }

  /// Get legal basis for processing
  static LegalBasis getLegalBasis(ConsentType type) {
    switch (type) {
      case ConsentType.essential:
        return LegalBasis.legitimateInterest;
      case ConsentType.analytics:
      case ConsentType.marketing:
      case ConsentType.preferences:
      case ConsentType.thirdParty:
      case ConsentType.dataSharing:
      case ConsentType.biometric:
      case ConsentType.location:
      case ConsentType.pushNotifications:
        return LegalBasis.consent;
    }
  }
}

/// Consent types as per GDPR
enum ConsentType {
  essential,          // Cannot be disabled
  analytics,
  marketing,
  preferences,
  thirdParty,
  dataSharing,
  biometric,
  location,
  pushNotifications,
}

/// Legal basis for data processing
enum LegalBasis {
  consent,
  contract,
  legalObligation,
  vitalInterests,
  publicTask,
  legitimateInterest,
}

/// Consent method
enum ConsentMethod {
  explicit,    // User actively consented
  implicit,    // Implied consent (not recommended)
  withdrawal,  // User withdrew consent
  parentalConsent, // For minors
}

/// Consent version for tracking policy updates
enum ConsentVersion {
  v1_0,
  v1_1,
  v2_0,
  current,
}

/// User consent preferences
class ConsentPreferences {
  final String? userId;
  final Map<ConsentType, bool> consents;
  final DateTime timestamp;
  final ConsentVersion version;
  final String? ipAddress;
  final ConsentMethod method;

  const ConsentPreferences({
    this.userId,
    required this.consents,
    required this.timestamp,
    required this.version,
    this.ipAddress,
    required this.method,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'consents': consents.map((k, v) => MapEntry(k.toString(), v)),
    'timestamp': timestamp.toIso8601String(),
    'version': version.toString(),
    'ipAddress': ipAddress,
    'method': method.toString(),
  };

  factory ConsentPreferences.fromJson(Map<String, dynamic> json) {
    final consentsMap = <ConsentType, bool>{};
    final jsonConsents = json['consents'] as Map<String, dynamic>;

    for (final entry in jsonConsents.entries) {
      final type = ConsentType.values.firstWhere(
        (t) => t.toString() == entry.key,
        orElse: () => ConsentType.essential,
      );
      consentsMap[type] = entry.value as bool;
    }

    return ConsentPreferences(
      userId: json['userId'],
      consents: consentsMap,
      timestamp: DateTime.parse(json['timestamp']),
      version: ConsentVersion.values.firstWhere(
        (v) => v.toString() == json['version'],
        orElse: () => ConsentVersion.v1_0,
      ),
      ipAddress: json['ipAddress'],
      method: ConsentMethod.values.firstWhere(
        (m) => m.toString() == json['method'],
        orElse: () => ConsentMethod.explicit,
      ),
    );
  }
}

/// Consent change record for audit trail
class ConsentRecord {
  final DateTime timestamp;
  final String? userId;
  final Map<ConsentType, bool> previousConsents;
  final Map<ConsentType, bool> newConsents;
  final String changeReason;
  final ConsentMethod method;

  const ConsentRecord({
    required this.timestamp,
    this.userId,
    required this.previousConsents,
    required this.newConsents,
    required this.changeReason,
    required this.method,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'previousConsents': previousConsents.map((k, v) => MapEntry(k.toString(), v)),
    'newConsents': newConsents.map((k, v) => MapEntry(k.toString(), v)),
    'changeReason': changeReason,
    'method': method.toString(),
  };

  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    final prevMap = <ConsentType, bool>{};
    final prevJson = json['previousConsents'] as Map<String, dynamic>;
    for (final entry in prevJson.entries) {
      final type = ConsentType.values.firstWhere(
        (t) => t.toString() == entry.key,
        orElse: () => ConsentType.essential,
      );
      prevMap[type] = entry.value as bool;
    }

    final newMap = <ConsentType, bool>{};
    final newJson = json['newConsents'] as Map<String, dynamic>;
    for (final entry in newJson.entries) {
      final type = ConsentType.values.firstWhere(
        (t) => t.toString() == entry.key,
        orElse: () => ConsentType.essential,
      );
      newMap[type] = entry.value as bool;
    }

    return ConsentRecord(
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      previousConsents: prevMap,
      newConsents: newMap,
      changeReason: json['changeReason'],
      method: ConsentMethod.values.firstWhere(
        (m) => m.toString() == json['method'],
        orElse: () => ConsentMethod.explicit,
      ),
    );
  }
}