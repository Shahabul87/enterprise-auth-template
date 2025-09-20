import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/presentation/widgets/compliance/cookie_consent_banner.dart';
import 'app_router.dart';
import 'theme.dart';

class FlutterAuthApp extends ConsumerWidget {
  const FlutterAuthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Enterprise Auth Template',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Add the navigation key for global navigation access
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            // Add cookie consent banner for web platform
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CookieConsentBanner(),
            ),
          ],
        );
      },
    );
  }
}
