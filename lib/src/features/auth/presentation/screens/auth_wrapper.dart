import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:flutter_application_1/src/features/auth/presentation/blocs/auth_state.dart';
import 'package:flutter_application_1/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder escuchará los cambios en tu AuthCubit

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        print('🎯 AuthWrapper recibió state: $state');
        // Si el estado es "autenticado", vamos al Dashboard
        if (state is Authenticated) {
          print('🏠 AuthWrapper: Navegando a DashboardScreen');
          return const DashboardScreen();
        }
        // Si el estado es "no autenticado", vamos a la Bienvenida
        else if (state is Unauthenticated) {
          print('👋 AuthWrapper: Navegando a WelcomeScreen');
          return const WelcomeScreen();
        }
        // Mientras el cubit está en AuthInitial (cargando),
        // mostramos un indicador de carga.
        else {
          print('⏳ AuthWrapper: Mostrando loading (state: $state)');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
