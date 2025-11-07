import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/common_widgets/app_logo.dart';
import 'package:flutter_application_1/src/common_widgets/primary_button.dart';
import 'package:flutter_application_1/src/constants/app_text_styles.dart';
import 'package:flutter_application_1/src/routing/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                '',
                style: AppTextStyles.screenTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const AppLogo(size: 150),
              const SizedBox(height: 16),
              Text(
                '',
                style: AppTextStyles.brandName,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text('', style: AppTextStyles.body, textAlign: TextAlign.center),
              const Spacer(),

              PrimaryButton(
                text: 'Comenzar',
                onPressed: () {
                  print('🚀 WelcomeScreen: Botón Comenzar presionado');
                  print('🚀 WelcomeScreen: Navegando a ${AppRoutes.login}');
                  try {
                    Navigator.pushNamed(context, AppRoutes.login);
                    print('🚀 WelcomeScreen: Navegación ejecutada');
                  } catch (e) {
                    print('❌ WelcomeScreen: Error en navegación: $e');
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
