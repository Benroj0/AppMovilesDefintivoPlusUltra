import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/RegisterPage.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/WalletPage.dart';
import 'package:flutter_application_1/src/routing/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/LoginPage.dart';
//import 'package:flutter_application_1/src/features/auth/presentation/screens/welcome_screen.dart'; // No longer needed directly here
import 'package:flutter_application_1/src/features/blocProvider.dart';
import 'package:flutter_application_1/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter_application_1/src/color_theme/theme_bloc.dart';
import 'package:flutter_application_1/src/color_theme/theme_state.dart';
import 'package:flutter_application_1/src/color_theme/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// GlobalKey para forzar recreación completa de la app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Función estática para reiniciar la navegación al AuthWrapper
  static void restartApp() {
    print('🔄 MyApp: Navegando al AuthWrapper después de logout');
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: blocProviders,
          child: const AuthWrapper(),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,

      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'APP GASTOS',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeState.themeMode,

            home: const AuthWrapper(),

            // 5. Routes map is correct (without '/')
            routes: {
              AppRoutes.login: (context) => const LoginPage(),
              AppRoutes.register: (context) => const RegisterPage(),
              AppRoutes.dashboard: (context) => const DashboardScreen(),
              AppRoutes.wallet: (context) => const WalletPage(),
              // Add other named routes as needed
            },
          );
        },
      ),
    );
  }
}
