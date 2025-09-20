import 'package:flutter_auth_template/core/config/environment.dart';

class ApiConstants {
  // Base URLs - Now dynamic based on environment
  static String get baseUrl => Environment.apiBaseUrl;
  static const String apiVersion = 'v1';
  static const String apiPath = '/api/$apiVersion';  // API version path

  // Full API URL
  static String get apiUrl => '$baseUrl$apiPath';

  // Authentication endpoints
  static const String authBasePath = '/auth';
  static const String loginPath = '$authBasePath/login';
  static const String registerPath = '$authBasePath/register';
  static const String refreshPath = '$authBasePath/refresh';
  static const String refreshTokenPath = '$authBasePath/refresh'; // Alias for refreshPath
  static const String logoutPath = '$authBasePath/logout';
  static const String forgotPasswordPath = '$authBasePath/forgot-password';
  static const String resetPasswordPath = '$authBasePath/reset-password';
  static const String verifyEmailPath = '$authBasePath/verify-email';
  static const String resendVerificationPath =
      '$authBasePath/resend-verification';
  static const String permissionsPath = '$authBasePath/permissions';

  // User endpoints
  static const String userBasePath = '/users';
  static const String userMePath = '$userBasePath/me';
  static const String usersListPath = userBasePath;

  // Profile endpoints
  static const String profileBasePath = '/profile';
  static const String profileMePath = '$profileBasePath/me';
  static const String profileChangePasswordPath =
      '$profileBasePath/change-password';
  static const String profileChangeEmailPath = '$profileBasePath/change-email';
  static const String profileEmailPath = '$profileBasePath/email';
  static const String profileVerifyEmailPath = '$profileBasePath/verify-email';
  static const String profileSecurityPath = '$profileBasePath/security';
  static const String profileNotificationsPath =
      '$profileBasePath/notifications';
  static const String profileAvatarPath = '$profileBasePath/avatar';
  static const String profileCompletionPath = '$profileBasePath/completion';
  static const String profilePrivacyPath = '$profileBasePath/privacy';
  static const String profileAccountSettingsPath =
      '$profileBasePath/account-settings';
  static const String profileStatisticsPath = '$profileBasePath/statistics';
  static const String profileExportPath = '$profileBasePath/export';
  static const String profileActivitiesPath = '$profileBasePath/activities';
  static const String profileSessionsPath = '$profileBasePath/sessions';
  static const String profileRevokeAllSessionsPath = '$profileBasePath/sessions/revoke-all';
  static const String profileConnectedAccountsPath = '$profileBasePath/connected-accounts';
  static const String profilePreferencesPath = '$profileBasePath/preferences';
  static const String profileExportDataPath = '$profileBasePath/export-data';
  static const String profileExportStatusPath = '$profileBasePath/export-status';

  // OAuth endpoints
  static const String oauthBasePath = '/oauth';
  static const String oauthInitPath = '$oauthBasePath/{provider}/init';
  static const String oauthCallbackPath = '$oauthBasePath/{provider}/callback';
  static const String oauthProvidersPath = '$oauthBasePath/providers';

  // WebAuthn endpoints
  static const String webauthnBasePath = '/webauthn';
  static const String webauthnRegisterBeginPath =
      '$webauthnBasePath/register/begin';
  static const String webauthnRegisterCompletePath =
      '$webauthnBasePath/register/complete';
  static const String webauthnAuthenticateBeginPath =
      '$webauthnBasePath/authenticate/begin';
  static const String webauthnAuthenticateCompletePath =
      '$webauthnBasePath/authenticate/complete';

  // WebAuthn aliases for compatibility
  static const String webauthnRegisterStartPath = webauthnRegisterBeginPath;
  static const String webauthnAuthStartPath = webauthnAuthenticateBeginPath;
  static const String webauthnAuthCompletePath = webauthnAuthenticateCompletePath;
  static const String webauthnCredentialsPath = '$webauthnBasePath/credentials/{id}';

  // Magic Links endpoints
  static const String magicLinksBasePath = '/magic-links';
  static const String magicLinkRequestPath = '$magicLinksBasePath/request';
  static const String magicLinkVerifyPath =
      '$magicLinksBasePath/verify/{token}';
  static const String magicLinkStatusPath = '$magicLinksBasePath/status';
  static const String magicLinkCancelPath = '$magicLinksBasePath/cancel';

  // Two-Factor Authentication endpoints
  static const String twoFactorBasePath = '/2fa';
  static const String twoFactorStatusPath = '$twoFactorBasePath/status';
  static const String twoFactorSetupPath = '$twoFactorBasePath/setup';
  static const String twoFactorEnablePath = '$twoFactorBasePath/enable';
  static const String twoFactorVerifyPath = '$twoFactorBasePath/verify';
  static const String twoFactorDisablePath = '$twoFactorBasePath/disable';
  static const String twoFactorBackupCodesPath =
      '$twoFactorBasePath/backup-codes/regenerate';

  // Admin endpoints
  static const String adminBasePath = '/admin';
  static const String adminDashboardPath = '$adminBasePath/dashboard';
  static const String adminStatsPath = '$adminBasePath/stats';
  static const String adminUsersPath = '$adminBasePath/users';
  static const String adminActiveSessionsPath =
      '$adminBasePath/sessions/active';
  static const String adminSessionsPath = '$adminBasePath/sessions';
  static const String adminAuditLogsPath = '$adminBasePath/audit-logs';
  static const String adminActivityReportPath =
      '$adminBasePath/activity-report';
  static const String adminSecurityReportPath =
      '$adminBasePath/security-report';
  static const String adminSystemHealthPath = '$adminBasePath/system/health';
  static const String adminSystemConfigPath = '$adminBasePath/system/config';
  static const String adminMaintenancePath =
      '$adminBasePath/system/maintenance';
  static const String adminCacheClearPath = '$adminBasePath/cache/clear';
  static const String adminExportUsersPath = '$adminBasePath/exports/users';
  static const String adminExportAuditLogsPath =
      '$adminBasePath/exports/audit-logs';

  // API Keys endpoints
  static const String apiKeysPath = '$adminBasePath/api-keys';

  // Webhooks endpoints
  static const String webhooksPath = '$adminBasePath/webhooks';

  // Health endpoint
  static const String healthPath = '/health';

  // HTTP Headers
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String userAgentHeader = 'User-Agent';

  // Header Values
  static const String applicationJsonContentType = 'application/json';
  static const String bearerPrefix = 'Bearer ';

  // Timeouts
  static const int connectTimeoutMs = 30000; // 30 seconds
  static const int receiveTimeoutMs = 60000; // 60 seconds
  static const int sendTimeoutMs = 30000; // 30 seconds

  // Cache
  static const String tokenCacheKey = 'access_token';
  static const String refreshTokenCacheKey = 'refresh_token';
  static const String userCacheKey = 'user_data';

  // OAuth Providers
  static const List<String> supportedOAuthProviders = [
    'google',
    'github',
    'discord',
  ];

  // WebAuthn
  static const String webauthnTimeout = '60000'; // 60 seconds in milliseconds
  static const String webauthnUserVerification = 'required';

  // Two-Factor Authentication
  static const int totpCodeLength = 6;
  static const int backupCodeLength = 8;
  static const int backupCodeCount = 10;

  // Password requirements
  static const int minPasswordLength = 8;
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';

  // Rate limiting
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  // Token expiration
  static const int accessTokenExpiryMinutes = 15;
  static const int refreshTokenExpiryDays = 7;

  // Deep linking
  static const String appScheme = 'enterpriseauth';
  static const String oauthCallbackScheme = '$appScheme://oauth';
  static const String magicLinkScheme = '$appScheme://magic-link';
  static const String emailVerificationScheme = '$appScheme://verify-email';
}

class ApiErrors {
  static const String networkError = 'NETWORK_ERROR';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String userNotFound = 'USER_NOT_FOUND';
  static const String emailAlreadyExists = 'EMAIL_ALREADY_EXISTS';
  static const String accountLocked = 'ACCOUNT_LOCKED';
  static const String emailNotVerified = 'EMAIL_NOT_VERIFIED';
  static const String twoFactorRequired = 'TWO_FACTOR_REQUIRED';
  static const String invalidTwoFactorCode = 'INVALID_TWO_FACTOR_CODE';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String invalidToken = 'INVALID_TOKEN';
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String serverError = 'SERVER_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String rateLimitExceeded = 'RATE_LIMIT_EXCEEDED';
}
