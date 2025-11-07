import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/src/domain/utils/Resource.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/bloc/LoginEvent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/login/bloc/LoginState.dart';
import 'package:flutter_application_1/src/features/utils/BlocFormItem.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;
  LoginBloc({required AuthService authService})
    : _authService = authService,
      super(LoginState(formKey: GlobalKey<FormState>(), response: Initial())) {
    on<LoginInit>(_onInit);
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginWithGoogleSubmitted>(_onGoogleSubmitted);
  }
  final formKey = GlobalKey<FormState>();

  void _onInit(LoginInit event, Emitter<LoginState> emit) async {
    emit(LoginState(formKey: formKey, response: Initial()));
  }

  Future<void> _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        email: BlocFormItem(
          value: event.email.value,
          error: event.email.value.isNotEmpty ? null : 'Ingresa el email',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        password: BlocFormItem(
          value: event.password.value,
          error:
              event.password.value.isNotEmpty &&
                  event.password.value.length >= 6
              ? null
              : 'Ingresa el password',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    print('🚀 LoginBloc: Recibido LoginSubmitted event');
    // Validación final
    final email = state.email.value.trim();
    final password = state.password.value.trim();

    final emailError = email.isEmpty ? 'Ingresa el email' : null;
    final passwordError = password.isEmpty || password.length < 6
        ? 'Ingresa el password (mínimo 6 caracteres)'
        : null;

    emit(
      state.copyWith(
        email: state.email.copyWith(error: emailError),
        password: state.password.copyWith(error: passwordError),
      ),
    );

    if (emailError != null || passwordError != null) return;

    emit(state.copyWith(response: Loading()));
    // Simula login
    await Future.delayed(const Duration(seconds: 2));

    // Usamos Firebase con try-catch
    try {
      print('🔐 LoginBloc: Intentando login...');
      await _authService.iniciarSesion(
        email: state.email.value.trim(),
        password: state.password.value.trim(),
      );

      print('✅ LoginBloc: Login exitoso, emitiendo Success()');
      // Si el login es exitoso, emitimos Success para que LoginPage pueda navegar
      emit(state.copyWith(response: Success("Login exitoso")));
    } on FirebaseAuthException catch (e) {
      // Atrapamos errores específicos de Firebase
      String errorMessage = "Correo o contraseña incorrectos.";
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = 'Correo o contraseña incorrectos.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El formato del correo no es válido.';
      }
      emit(state.copyWith(response: Error(errorMessage)));
    } catch (e) {
      // Atrapamos cualquier otro error
      emit(state.copyWith(response: Error("Ocurrió un error inesperado.")));
    }
  }

  Future<void> _onGoogleSubmitted(
    LoginWithGoogleSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(response: Loading())); // Show loading
    try {
      await _authService.signInWithGoogle();
      // Si el login es exitoso, emitimos Success para que LoginPage pueda navegar
      emit(state.copyWith(response: Success("Login con Google exitoso")));
    } catch (e) {
      // Handle errors (e.g., user cancelled, network error)
      String errorMessage = "Error al iniciar con Google.";
      if (e is FirebaseAuthException && e.code == 'USER_CANCELLED') {
        errorMessage = "Inicio de sesión con Google cancelado.";
      }
      emit(state.copyWith(response: Error(errorMessage)));
    }
  }
}
