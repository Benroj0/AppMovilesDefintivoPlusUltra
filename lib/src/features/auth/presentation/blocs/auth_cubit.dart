import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importa los servicios y estados que acabamos de crear
import 'package:flutter_application_1/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  // 1. Dependencias del servicio
  final AuthService _authService;
  late StreamSubscription _authSubscription;

  // 2. Constructor
  AuthCubit({required AuthService authService})
    : _authService = authService,
      super(AuthInitial()) {
    // El estado inicial

    // 3. Escuchar el stream de authStateChanges
    // Apenas se crea el Cubit, empieza a escuchar los cambios de sesión
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      print('🔥 AuthCubit Listener recibió: $user');
      if (user == null) {
        // Si el usuario es nulo, emitimos Unauthenticated
        print('🚪 Emitiendo Unauthenticated() - Usuario desconectado');
        emit(Unauthenticated());
        // TODO: Aquí podríamos disparar eventos para limpiar otros BLoCs
      } else {
        // Si hay un usuario, emitimos Authenticated
        print(
          '✅ Emitiendo Authenticated(${user.email}) - Nuevo usuario conectado',
        );
        emit(Authenticated(user));
        // TODO: Aquí podríamos disparar eventos para recargar datos de otros BLoCs
      }
    });
  }

  // 4. Función para cerrar sesión - VERSIÓN ULTRA ROBUSTA
  // La UI llamará a esto, que a su vez llama al servicio
  Future<void> signOut() async {
    print('🚪 AuthCubit: ===== INICIANDO SIGNOUT ULTRA ROBUSTO =====');

    try {
      // Paso 1: Emitir estado de carga/logout
      print('🚪 AuthCubit: Emitiendo AuthInitial (logout en progreso)');
      emit(AuthInitial());

      // Paso 2: Ejecutar logout del servicio
      await _authService.cerrarSesion();
      print('✅ AuthCubit: AuthService.cerrarSesion() EXITOSO');

      // Paso 3: Espera adicional para asegurar propagación
      await Future.delayed(const Duration(milliseconds: 800));

      // Paso 4: FORZAR estado Unauthenticated
      print('🚪 AuthCubit: FORZANDO estado Unauthenticated()');
      emit(Unauthenticated());

      print('🎉 AuthCubit: ===== SIGNOUT COMPLETADO EXITOSAMENTE =====');
    } catch (e) {
      print('❌ AuthCubit: ERROR CRÍTICO en signOut: $e');

      // Manejo de emergencia: forzar logout aunque Firebase falle
      print('🚨 AuthCubit: EJECUTANDO LOGOUT DE EMERGENCIA');
      emit(Unauthenticated());

      // No hacer rethrow para no bloquear la UI
      print('⚠️ AuthCubit: Logout forzado completado (con errores)');
    }
  }

  // 5. Buena práctica: Cancelar la suscripción al cerrar el Cubit
  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
