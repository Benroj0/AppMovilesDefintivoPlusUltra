import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ProfileEvent.dart';
import 'ProfileState.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription _authSubscription;

  ProfileBloc({required FirestoreService firestoreService})
    : _firestoreService = firestoreService,
      super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateUserNameEvent>(_onUpdateUserName);
    on<UpdateUserEmailEvent>(_onUpdateUserEmail);
    on<LogoutEvent>(_onLogout);
    on<ClearProfileEvent>(_onClearProfile);

    // 🔥 ESCUCHAR CAMBIOS DE AUTENTICACIÓN AUTOMÁTICAMENTE
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      print(
        '🔄 ProfileBloc: Auth state changed - User: ${user?.email ?? 'null'}',
      );
      if (user != null) {
        // Usuario autenticado - cargar perfil automáticamente
        print('✅ ProfileBloc: Cargando perfil para nuevo usuario');
        add(LoadProfileEvent());
      } else {
        // Usuario desconectado - limpiar estado
        print('🧹 ProfileBloc: Limpiando estado por logout');
        add(ClearProfileEvent());
      }
    });
  }

  Future<void> _onLoadProfile(
    // Simular carga de datos del perfil
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔄 ProfileBloc: ===== CARGANDO PERFIL =====');
    emit(state.copyWith(isLoading: true)); // Empieza a cargar

    final User? currentUser = _auth.currentUser;
    print('🔄 ProfileBloc: Usuario actual: ${currentUser?.email ?? 'null'}');
    print('🔄 ProfileBloc: UID: ${currentUser?.uid ?? 'null'}');

    if (currentUser == null) {
      print('❌ ProfileBloc: No hay usuario logueado');
      emit(state.copyWith(isLoading: false, error: "No hay usuario logueado."));
      return;
    }

    try {
      // 1. Obtener el email desde Firebase Auth
      final String email = currentUser.email ?? "Email no disponible";
      print('📧 ProfileBloc: Email obtenido: $email');

      // 2. Obtener los datos (nombre/apellido) desde Firestore
      print('🔍 ProfileBloc: Obteniendo datos de Firestore...');
      final profileData = await _firestoreService.getUserProfile(
        currentUser.uid,
      );
      print('📄 ProfileBloc: Datos obtenidos: $profileData');

      String nombreCompleto = "Usuario"; // Fallback
      if (profileData != null) {
        // Asumiendo que guardaste 'nombre' y 'apellido' o 'paterno'
        // Ajusta estos nombres de campo a como estén en tu Firestore
        final String nombre = profileData['nombre'] ?? '';
        final String apellido =
            profileData['apellido'] ?? profileData['paterno'] ?? '';
        nombreCompleto = '$nombre $apellido'.trim();
        print(
          '👤 ProfileBloc: Nombre construido desde Firestore: "$nombreCompleto"',
        );
      } else if (currentUser.displayName != null &&
          currentUser.displayName!.isNotEmpty) {
        // Fallback al 'displayName' (útil para Google Sign-In)
        nombreCompleto = currentUser.displayName!;
        print('👤 ProfileBloc: Nombre desde displayName: "$nombreCompleto"');
      }

      // 3. Emitir el estado final con los datos
      print('✅ ProfileBloc: Emitiendo estado final');
      print('✅ ProfileBloc: userName: "$nombreCompleto"');
      print('✅ ProfileBloc: userEmail: "$email"');
      emit(
        state.copyWith(
          isLoading: false,
          userName: nombreCompleto,
          userEmail: email,
        ),
      );
      print('🎉 ProfileBloc: ===== PERFIL CARGADO EXITOSAMENTE =====');
    } catch (e) {
      print('❌ ProfileBloc: ERROR al cargar perfil: $e');
      emit(state.copyWith(isLoading: false, error: "Error al cargar perfil."));
    }
  }

  void _onUpdateUserName(
    UpdateUserNameEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(userName: event.userName));
  }

  void _onUpdateUserEmail(
    UpdateUserEmailEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(userEmail: event.userEmail));
  }

  void _onLogout(LogoutEvent event, Emitter<ProfileState> emit) {
    // Lógica para cerrar sesión
    emit(const ProfileState()); // Reset al estado inicial
  }

  void _onClearProfile(ClearProfileEvent event, Emitter<ProfileState> emit) {
    print('🧹 ProfileBloc: Limpiando estado del perfil');
    emit(const ProfileState()); // Reset al estado inicial
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
