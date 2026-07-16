import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/models/user_model.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/intro_screen.dart';
import 'features/auth/screens/ngo_onboarding_screen.dart';
import 'features/auth/screens/supplier_onboarding_screen.dart';
import 'features/auth/screens/ngo_auth_ui_flow_screen.dart';
import 'features/ngo/screens/ngo_home_screen.dart';
import 'features/ngo/screens/ngo_side_menu_screen.dart';
import 'features/ngo/screens/ngo_history_screen.dart';
import 'features/ngo/screens/ngo_map_screen.dart';
import 'features/supplier/screens/supplier_home_screen.dart';
import 'features/auth/screens/supplier_auth_ui_flow_screen.dart';
import 'features/employee/screens/employee_login_screen.dart';
import 'features/employee/screens/employee_home_screen.dart';

import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/ngo/providers/ngo_provider.dart';
import 'features/supplier/providers/supplier_provider.dart';

import 'core/services/token_service.dart';
import 'core/providers/language_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await TokenService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NGOProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const ManavSevaApp(),
    ),
  );
}

class ManavSevaApp extends StatelessWidget {
  const ManavSevaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ManavSeva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

enum _Screen { splash, authOrHome, supplierOnboarding, supplierAuth, ngoOnboarding, ngoAuth, employeeLogin }

class _AppRootState extends State<_AppRoot> {
  _Screen _current = _Screen.splash;

  void _go(_Screen screen) => setState(() => _current = screen);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: switch (_current) {
        _Screen.splash => SplashScreen(
            key: const ValueKey('splash'),
            onComplete: () => _go(_Screen.authOrHome),
          ),
        _Screen.authOrHome => _AuthWrapper(
            key: const ValueKey('authOrHome'),
            onSupplierTap: () => _go(_Screen.supplierOnboarding),
            onNGOTap: () => _go(_Screen.ngoOnboarding),
            onEmployeeTap: () => _go(_Screen.employeeLogin),
            onLoginTap: () => _go(_Screen.ngoAuth),
          ),
        _Screen.ngoOnboarding => NGOOnboardingScreen(
            key: const ValueKey('ngoOnboarding'),
            onFinish: () => _go(_Screen.ngoAuth),
            onBack: () => _go(_Screen.authOrHome),
          ),
        _Screen.ngoAuth => NGOAuthUIFlowScreen(
            key: const ValueKey('ngoAuth'),
            onBackToLanding: () => _go(_Screen.authOrHome),
            onComplete: () => _go(_Screen.authOrHome),
            onSwitchRole: () => _go(_Screen.supplierAuth),
          ),
        _Screen.supplierOnboarding => SupplierOnboardingScreen(
            key: const ValueKey('supplierOnboarding'),
            onComplete: () => _go(_Screen.supplierAuth),
            onBack: () => _go(_Screen.authOrHome),
          ),
        _Screen.supplierAuth => SupplierAuthUIFlowScreen(
            key: const ValueKey('supplierAuth'),
            onBackToLanding: () => _go(_Screen.authOrHome),
            onComplete: () => _go(_Screen.authOrHome),
            onSwitchRole: () => _go(_Screen.ngoAuth),
          ),
        _Screen.employeeLogin => EmployeeLoginScreen(
            key: const ValueKey('employeeLogin'),
            onBackToLanding: () => _go(_Screen.authOrHome),
            onLoginSuccess: () => _go(_Screen.authOrHome), // Adjust for employee later
          ),
      },
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  final VoidCallback onSupplierTap;
  final VoidCallback onNGOTap;
  final VoidCallback onEmployeeTap;
  final VoidCallback onLoginTap;

  const _AuthWrapper({
    super.key,
    required this.onSupplierTap,
    required this.onNGOTap,
    required this.onEmployeeTap,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isLoggedIn) {
      return IntroScreen(
        onSupplierTap: onSupplierTap,
        onNGOTap: onNGOTap,
        onLoginTap: onLoginTap,
        onEmployeeTap: onEmployeeTap,
      );
    }

    final userType = authProvider.userType;
    if (userType == 'ngo') {
      return NGOHomeScreen(
        onOpenMenu: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NGOSideMenuScreen()),
        ),
        onOpenHistory: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NGOHistoryScreen()),
        ),
        onOpenMap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NGOMapScreen()),
        ),
      );
    }

    if (userType == 'supplier') {
      return SupplierHomeScreen(
        onOpenMenu: () {}, // Add drawer/menu later
      );
    }

    // Fallback if userType is unknown or employee is not fully supported yet
    return IntroScreen(
      onSupplierTap: onSupplierTap,
      onNGOTap: () {},
      onLoginTap: onNGOTap,
      onEmployeeTap: onEmployeeTap,
    );
  }
}
