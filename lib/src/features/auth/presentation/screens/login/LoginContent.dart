import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/common_widgets/labeled_text_field.dart';
import 'package:flutter_application_1/src/common_widgets/primary_button.dart';
import 'package:flutter_application_1/src/common_widgets/google_signin_button.dart';
import 'package:flutter_application_1/src/common_widgets/login_background.dart';
import 'package:flutter_application_1/src/constants/app_text_styles.dart';
import 'package:flutter_application_1/src/constants/app_colors.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/bloc/LoginBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/bloc/LoginEvent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/bloc/LoginState.dart';
import 'package:flutter_application_1/src/features/utils/BlocFormItem.dart';
import 'package:flutter_application_1/src/routing/app_router.dart';

class LoginContent extends StatelessWidget {
  final LoginBloc? bloc;
  final LoginState state;

  const LoginContent(this.bloc, this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // --- ¡AQUÍ EMPIEZA EL CAMBIO! ---
          child: SingleChildScrollView(
            child: Form(
              key: state.formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alineación a la izquierda
                children: [
                  // Espaciado superior
                  const SizedBox(height: 40), 
                  // Logo de la app centrado y más arriba
                  Center(
                    child: Image.asset(
                      'assets/img/logo2.png',
                      width: 150,
                      height: 150,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ), 
                  // Título principal centrado
                  const Center(
                    child: Text(
                      'Inicio de Sesión',
                      style: AppTextStyles.screenTitle,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botón de Google
                  GoogleSignInButton(
                    onPressed: () {
                      bloc?.add(const LoginWithGoogleSubmitted());
                    },
                  ),

                  const SizedBox(height: 24),

                  // Divisor
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: AppColors.inputBorder),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('o', style: AppTextStyles.subtitle),
                      ),
                      Expanded(
                        child: Container(height: 1, color: AppColors.inputBorder),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Campo Usuario con etiqueta arriba
                  LabeledTextField(
                    label: 'Usuario',
                    onChanged: (value) {
                      bloc?.add(
                        LoginEmailChanged(email: BlocFormItem(value: value)),
                      );
                    },
                    validator: (value) => state.email.error,
                  ),

                  const SizedBox(height: 20),

                  // Campo Contraseña con etiqueta arriba
                  LabeledTextField(
                    label: 'Contraseña',
                    isPassword: true,
                    onChanged: (value) {
                      bloc?.add(
                        LoginPasswordChanged(
                          password: BlocFormItem(value: value),
                        ),
                      );
                    },
                    validator: (value) => state.password.error,
                  ),

                  const SizedBox(height: 32),

                  // Botón Iniciar Sesión
                  PrimaryButton(
                    text: 'Iniciar Sesión',
                    onPressed: () {
                      if (state.formKey!.currentState!.validate()) {
                        bloc?.add(const LoginSubmitted());
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Por favor, corrige los errores del formulario.'),
                            backgroundColor: Colors.orange[700],
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Enlaces de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text(
                          'Registrarse',
                          style: AppTextStyles.textLink,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Lógica para "Olvidaste tu contraseña"
                        },
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: AppTextStyles.textLink,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40), // Usamos un espacio fijo en su lugar

                  // Omitir inicio de sesión
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.dashboard,
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Omitir inicio de sesión',
                        style: AppTextStyles.textLink.copyWith(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}