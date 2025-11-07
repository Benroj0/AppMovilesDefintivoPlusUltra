import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/src/domain/utils/Resource.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterEvent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/register/bloc/RegisterState.dart';
import 'package:flutter_application_1/src/features/utils/BlocFormItem.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterBloc extends Bloc<RegisterEvent,RegisterState>  {
 final AuthService _authService;
 RegisterBloc({required AuthService authService}):_authService = authService,
 super(RegisterState(formKey: GlobalKey<FormState>(),response: Initial())) {

  on<RegisterInit>(_onInit);
  on<RegisterNameChanged>(_onNameChanged);
  on<RegisterLastNameChanged>(_onLastNameChanged);
  on<RegisterEmailChanged>(_onEmailChanged);
  on<RegisterPasswordChanged>(_onPasswordChanged);
  on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
  on<RegisterSubmitted>(_onSubmitted);
 }
  final formKey = GlobalKey<FormState>();
  void _onInit(RegisterInit event, Emitter<RegisterState> emit) {
    emit(RegisterState(formKey: formKey, response: Initial()));
    
  }
  Future<void> _onNameChanged(RegisterNameChanged event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
      name: BlocFormItem(
        value: event.name.value,
        error: event.name.value.isNotEmpty ? null : 'Ingresa tu nombre',
      ),
      formKey: formKey,
    ));
  }
  Future<void> _onLastNameChanged(RegisterLastNameChanged event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
      lastname: BlocFormItem(
        value: event.lastname.value,
        error: event.lastname.value.isNotEmpty ? null : 'Ingresa tu apellido',
      ),
      formKey: formKey,
    ));
  }
  Future<void> _onEmailChanged(RegisterEmailChanged event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
      email: BlocFormItem(
        value: event.email.value,
        error: event.email.value.isNotEmpty ? null : 'Ingresa tu correo',
      ),
      formKey: formKey,
    ));
  }
  Future<void> _onPasswordChanged(RegisterPasswordChanged event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
      password: BlocFormItem(
        value: event.password.value,
        error: event.password.value.length >= 6 ?  null : 'Password mínimo 6 caracteres',
      ),
      formKey: formKey,
    ));
  }
  Future<void> _onConfirmPasswordChanged(RegisterConfirmPasswordChanged event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
      confirmPassword: BlocFormItem(
        value: event.confirmPassword.value,
        error: event.confirmPassword.value == state.password.value ? null : 
        'Las contraseñas no coinciden',
      ),
      formKey: formKey,
    ));
  }
  Future<void> _onSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    final name = state.name.value.trim();
    final lastName = state.lastname.value.trim();
    final email = state.email.value.trim();
    final password = state.password.value.trim();
    final confirmPassword = state.confirmPassword.value.trim();
    final nameError = name.isEmpty ? 'Ingresa tu nombre' : null;
    final lastNameError = lastName.isEmpty ? 'Ingresa tu apellido' : null;
    final emailError = email.isEmpty ? 'Ingresa el email' : null;
    final passwordError = password.length >= 6 ? null : 'Password mínimo 6 caracteres';
    final confirmPasswordError = confirmPassword != password ? 'Las contraseñas no coinciden' : null;

    emit(state.copyWith(
      name: state.name.copyWith(error: nameError),
      lastname: state.lastname.copyWith(error: lastNameError),
      email: state.email.copyWith(error: emailError),
      password: state.password.copyWith(error: passwordError),
      confirmPassword: state.confirmPassword.copyWith(error: confirmPasswordError),
    ));

    if (nameError != null || lastNameError != null || emailError != null || passwordError != null || confirmPasswordError != null) {
      return;
    }
    if (!state.formKey!.currentState!.validate()) {
       // Muestra un SnackBar de error en la UI (lo harás en RegisterPage)
       emit(state.copyWith(response: Error("Por favor, corrige los campos.")));
       return;
    }
    emit(state.copyWith(response: Loading()));

    try {
      await _authService.registrarUsuario(
        nombre: state.name.value.trim(),
        apellido: state.lastname.value.trim(),
        email: state.email.value.trim(),
        password: state.password.value.trim(),
      );
      
      // Éxito - emitir Success para que RegisterPage navegue al login
      emit(state.copyWith(response: Success("Usuario registrado exitosamente")));

    } on FirebaseAuthException catch (e) {
      // Atrapamos errores específicos de Firebase
      String errorMessage = "Ocurrió un error.";
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Este correo ya está registrado.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es muy débil.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El correo no es válido.';
      }
      emit(state.copyWith(response: Error(errorMessage)));
    } catch (e) {
      // Atrapamos cualquier otro error
      emit(state.copyWith(response: Error("Ocurrió un error inesperado.")));
    }
  }
}
