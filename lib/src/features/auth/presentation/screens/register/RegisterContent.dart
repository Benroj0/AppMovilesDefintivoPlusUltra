import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/common_widgets/labeled_text_field.dart';
import 'package:flutter_application_1/src/common_widgets/primary_button.dart';
import 'package:flutter_application_1/src/common_widgets/register_background.dart';
import 'package:flutter_application_1/src/constants/app_text_styles.dart';
import 'package:flutter_application_1/src/constants/app_colors.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterEvent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterState.dart';
import 'package:flutter_application_1/src/features/utils/BlocFormItem.dart';

class RegisterContent extends StatelessWidget {
  final RegisterBloc? bloc;
  final RegisterState state;

  const RegisterContent(this.bloc, this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return RegisterBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: state.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Mantener stretch para los campos
                children: [
                  // Botón de atrás alineado a la izquierda
                  const SizedBox(height: 8), // Reducido de 16 a 8
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                    ),
                  ),

                  // Espaciado superior reducido
                  const SizedBox(height: 10), // Reducido de 20 a 10
                  // Título principal alineado a la derecha
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Regístrate\nahora',
                      style: AppTextStyles.screenTitle,
                      textAlign: TextAlign.right,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ), // Reducido de 40 a 24                  // Campo Nombre con etiqueta arriba
                  LabeledTextField(
                    label: 'Nombre',
                    onChanged: (value) {
                      bloc?.add(
                        RegisterNameChanged(name: BlocFormItem(value: value)),
                      );
                    },
                    validator: (value) => state.name.error,
                  ),

                  const SizedBox(height: 16), // Reducido de 20 a 16
                  // Campo Apellido con etiqueta arriba
                  LabeledTextField(
                    label: 'Apellido',
                    onChanged: (value) {
                      bloc?.add(
                        RegisterLastNameChanged(
                          lastname: BlocFormItem(value: value),
                        ),
                      );
                    },
                    validator: (value) => state.lastname.error,
                  ),

                  const SizedBox(height: 16), // Reducido de 20 a 16
                  // Campo Correo con etiqueta arriba
                  LabeledTextField(
                    label: 'Correo',
                    onChanged: (value) {
                      bloc?.add(
                        RegisterEmailChanged(email: BlocFormItem(value: value)),
                      );
                    },
                    validator: (value) => state.email.error,
                  ),

                  const SizedBox(height: 16), // Reducido de 20 a 16
                  // Campo Contraseña con etiqueta arriba
                  LabeledTextField(
                    label: 'Contraseña',
                    isPassword: true,
                    onChanged: (value) {
                      bloc?.add(
                        RegisterPasswordChanged(
                          password: BlocFormItem(value: value),
                        ),
                      );
                    },
                    validator: (value) => state.password.error,
                  ),

                  const SizedBox(
                    height: 16,
                  ), // Reducido de 20 a 16                  // Campo Confirmar Contraseña con etiqueta arriba
                  LabeledTextField(
                    label: 'Confirmar Contraseña',
                    isPassword: true,
                    onChanged: (value) {
                      bloc?.add(
                        RegisterConfirmPasswordChanged(
                          confirmPassword: BlocFormItem(value: value),
                        ),
                      );
                    },
                    validator: (value) => state.confirmPassword.error,
                  ),

                  const SizedBox(height: 24), // Reducido de 32 a 24
                  // Botón Registrarse
                  PrimaryButton(
                    text: 'Registrarse',
                    onPressed: () {
                      if (state.formKey!.currentState!.validate()) {
                        bloc?.add(const RegisterSubmitted());
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Por favor, corrige los errores del formulario.'),
                        backgroundColor: Colors.orange[700], // Un color de advertencia
                      ),
                    );
                      }
                    },
                  ),

                  const SizedBox(
                    height: 40,
                  ), // Reemplazar Spacer con altura fija                  // Enlace para iniciar sesión
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta? ',
                          style: AppTextStyles.body.copyWith(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Inicia sesión',
                            style: AppTextStyles.textLink,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16), // Reducido de 32 a 16
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
