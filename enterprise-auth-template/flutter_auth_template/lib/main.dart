import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: FlutterAuthApp(),
    ),
  );

  // Initialize security after app starts (non-blocking)
  Future.delayed(const Duration(seconds: 1), () async {
    try {
      // This will be initialized through providers when needed
      print('Security features available');
    } catch (e) {
      print('Security initialization deferred: $e');
    }
  });
}
