import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream para escuchar los cambios de autenticación
  /// Tu `AuthBloc` escuchará esto para saber si el usuario
  /// está logueado o no.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  /// Función de Iniciar Sesión
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 AuthService: Intentando login con $email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('✅ AuthService: Login exitoso');
    } catch (e) {
      // Manejar el error (ej. "usuario no encontrado", "contraseña incorrecta")
      // 'rethrow' lanza el error para que tu BLoC pueda atraparlo y mostrarlo en la UI.
      print('❌ Error en inicio de sesión: $e');
      rethrow;
    }
  }

  /// Función de Registro
  Future<void> registrarUsuario({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Crear el usuario en Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // 2. Crear el documento del usuario en la base de datos Firestore
        // ¡Este es el paso clave para conectar Auth con tu colección 'usuarios'!
        await _db.collection('usuarios').doc(user.uid).set({
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          // Aquí puedes añadir los otros campos de tu UI si los tienes
          // 'user_name': '...',
          // 'paterno': '...',
        });
      }
    } catch (e) {
      // Manejar el error (ej. "el email ya está en uso")
      print('Error en registro: $e');
      rethrow;
    }
  }

  /// Función de Cerrar Sesión - VERSIÓN ULTRA ROBUSTA CON LIMPIEZA DE CACHÉ
  Future<void> cerrarSesion() async {
    print('🚪 AuthService: ===== INICIANDO LOGOUT ULTRA ROBUSTO =====');

    // Paso 1: Obtener usuario actual antes del logout
    final usuarioAntes = _auth.currentUser;
    print(
      '🚪 AuthService: Usuario antes del logout: ${usuarioAntes?.email ?? 'null'}',
    );

    // Paso 2: LIMPIAR CACHÉ DE FIRESTORE PRIMERO (MUY IMPORTANTE)
    try {
      print('🧹 AuthService: Limpiando caché de Firestore...');
      await _db.clearPersistence();
      print('✅ AuthService: Caché de Firestore eliminado');
    } catch (firestoreError) {
      print(
        '⚠️ Error limpiando caché Firestore (continuando): $firestoreError',
      );
      // Intentar alternativa: deshabilitar y reactivar la red
      try {
        await _db.disableNetwork();
        await Future.delayed(const Duration(milliseconds: 500));
        await _db.enableNetwork();
        print('✅ AuthService: Red de Firestore reiniciada como alternativa');
      } catch (networkError) {
        print('⚠️ Error en reinicio de red Firestore: $networkError');
      }
    }

    // Paso 3: Logout de Google de manera agresiva
    try {
      print('🚪 AuthService: Desconectando Google...');
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
      // Limpiar caché de Google adicional
      await _googleSignIn.signOut();
      print('✅ AuthService: Google desconectado completamente');
    } catch (googleError) {
      print('⚠️ Error en Google logout (continuando): $googleError');
    }

    // Paso 4: Logout de Firebase Auth de manera MUY agresiva
    for (int intento = 1; intento <= 5; intento++) {
      print('🚪 AuthService: Intento #$intento de Firebase signOut');
      try {
        await _auth.signOut();
        await Future.delayed(const Duration(milliseconds: 800));

        final usuarioActual = _auth.currentUser;
        print(
          '🚪 AuthService: Usuario después del intento #$intento: ${usuarioActual?.email ?? 'null'}',
        );

        if (usuarioActual == null) {
          print(
            '✅ AuthService: ¡Firebase logout exitoso en intento #$intento!',
          );
          break;
        } else if (intento == 5) {
          print(
            '❌ AuthService: FALLO CRÍTICO - Usuario sigue conectado después de 5 intentos',
          );
          // Último recurso: forzar reinicio del AuthService
          throw Exception(
            'Firebase Auth no se desconectó después de 5 intentos',
          );
        }
      } catch (e) {
        print('❌ AuthService: Error en intento #$intento: $e');
        if (intento == 5) rethrow;
        // Esperar más tiempo entre reintentos
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }

    // Paso 5: SEGUNDA LIMPIEZA DE CACHÉ DESPUÉS DEL LOGOUT
    try {
      print('🧹 AuthService: Segunda limpieza de caché post-logout...');
      await _db.clearPersistence();
      print('✅ AuthService: Segunda limpieza completada');
    } catch (e) {
      print('⚠️ Error en segunda limpieza: $e');
    }

    // Paso 6: Verificación final
    await Future.delayed(const Duration(milliseconds: 800));
    final usuarioFinal = _auth.currentUser;

    if (usuarioFinal == null) {
      print('🎉 AuthService: ===== LOGOUT COMPLETAMENTE EXITOSO =====');
    } else {
      print('💥 AuthService: ===== LOGOUT FALLÓ - USUARIO AÚN CONECTADO =====');
      print('💥 Usuario persistente: ${usuarioFinal.email}');
      throw Exception('LOGOUT CRÍTICO FALLIDO: ${usuarioFinal.email}');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      print('🔄 AuthService: Iniciando Google Sign-In...');
      
      // 1. Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancelled the flow
      if (googleUser == null) {
        print('⚠️ AuthService: Usuario canceló Google Sign-In');
        throw FirebaseAuthException(
          code: 'USER_CANCELLED',
          message: 'Google Sign-In cancelled.',
        );
      }

      print('✅ AuthService: Usuario de Google obtenido: ${googleUser.email}');

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🔑 AuthService: Tokens de Google obtenidos');

      // 3. Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔐 AuthService: Credential de Firebase creado');

      // 4. Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      print('✅ AuthService: Login con Firebase exitoso: ${user?.email}');

      // 5. IMPORTANT: Check if user is NEW and create Firestore doc if needed
      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        print('👤 AuthService: Usuario nuevo, creando documento en Firestore');
        await _db.collection('usuarios').doc(user.uid).set({
          'nombre': user.displayName?.split(' ').first ?? '', // Primer nombre
          'apellido': user.displayName?.split(' ').skip(1).join(' ') ?? '', // Resto como apellido
          'email': user.email ?? '', // Get email from Google profile
        });
        print('✅ AuthService: Documento de usuario creado en Firestore');
      }
      
      print('🎉 AuthService: Google Sign-In completado exitosamente');
    } catch (e) {
      print('❌ Error en Google Sign-In: $e');
      
      // Manejo específico de errores comunes
      if (e.toString().contains('ApiException: 10')) {
        throw FirebaseAuthException(
          code: 'google_signin_configuration_error',
          message: 'Error de configuración de Google Sign-In. Verifica la configuración de Firebase.',
        );
      } else if (e.toString().contains('network_error')) {
        throw FirebaseAuthException(
          code: 'network_error',
          message: 'Error de conexión. Verifica tu conexión a internet.',
        );
      }
      
      rethrow; // Re-throw the error for the BLoC to catch
    }
  }
}
