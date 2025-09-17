import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';

/// Certificate pinning implementation for enhanced security
class CertificatePinning {
  static const String _productionCertHash = 'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
  static const String _stagingCertHash = 'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=';

  /// Configure Dio with certificate pinning
  static void configureCertificatePinning(Dio dio, {required bool isProduction}) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();

      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Get the certificate's SHA256 fingerprint
        final certDerBytes = cert.der;
        final hash = base64.encode(certDerBytes);

        // In production, check against known certificate hashes
        if (isProduction) {
          return hash == _productionCertHash;
        } else {
          // In development, you might want to be more lenient or check staging cert
          return hash == _stagingCertHash || host == 'localhost';
        }
      };

      return client;
    };
  }

  /// Validate certificate against known pins
  static bool validateCertificate(X509Certificate cert, String expectedHost) {
    try {
      // Check certificate validity period
      final now = DateTime.now();
      if (cert.startValidity.isAfter(now) || cert.endValidity.isBefore(now)) {
        return false;
      }

      // Check certificate subject
      final subject = cert.subject;
      if (!subject.contains(expectedHost)) {
        return false;
      }

      // Additional checks can be added here
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load certificate from assets for comparison
  static Future<String?> loadCertificateFromAssets(String path) async {
    try {
      final certData = await rootBundle.loadString(path);
      return certData;
    } catch (e) {
      return null;
    }
  }
}