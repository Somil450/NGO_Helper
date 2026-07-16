import 'package:flutter/material.dart';

import '../../features/auth/screens/landing_screen.dart';

class AppRoutes {
  static const String landing = '/';
}

class AppRouter {
  /// Lightweight route factory for the current UI-only stage.
  ///
  /// The app currently uses `main.dart` flow switching (no external router).
  /// This keeps a safe, compile-clean placeholder for future router expansion.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const LandingScreen(),
    );
  }
}
