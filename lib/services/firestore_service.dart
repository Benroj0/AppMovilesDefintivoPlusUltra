import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Instancias de Firebase
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- OBTENER STREAMS (Para listas en tiempo real) ---

  /// Obtener un Stream de los gastos del usuario actual
  /// Tu BLoC usará esto para la pantalla "Historial" y "Home".
  Stream<QuerySnapshot> obtenerGastosStream() {
    final uid = _auth.currentUser?.uid;
    print('🔍 FirestoreService.obtenerGastosStream() - UID actual: $uid');
    if (uid == null) {
      print(
        '❌ FirestoreService.obtenerGastosStream() - No hay usuario, retornando stream vacío',
      );
      return Stream.empty();
    }

    print(
      '✅ FirestoreService.obtenerGastosStream() - Filtrando gastos por UID: $uid',
    );
    return _db
        .collection('gastos')
        .where('id_usuario', isEqualTo: uid)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  /// Obtener un Stream de los ingresos del usuario actual
  /// Tu BLoC usará esto para la pantalla de "Finanzas - Ingresos".
  Stream<QuerySnapshot> obtenerIngresosStream() {
    final uid = _auth.currentUser?.uid;
    print('🔍 FirestoreService.obtenerIngresosStream() - UID actual: $uid');
    if (uid == null) {
      print(
        '❌ FirestoreService.obtenerIngresosStream() - No hay usuario, retornando stream vacío',
      );
      return Stream.empty();
    }

    print(
      '✅ FirestoreService.obtenerIngresosStream() - Filtrando ingresos por UID: $uid',
    );
    return _db
        .collection('ingresos')
        .where('id_usuario', isEqualTo: uid)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  /// Obtener un Stream de las categorías del usuario
  /// Tu BLoC usará esto para la pantalla "Agregar Gasto" y "Categorías".
  Stream<QuerySnapshot> obtenerCategoriasStream() {
    final uid = _auth.currentUser?.uid;
    print('🔍 FirestoreService.obtenerCategoriasStream() - UID actual: $uid');
    if (uid == null) {
      print(
        '❌ FirestoreService.obtenerCategoriasStream() - No hay usuario, retornando stream vacío',
      );
      return Stream.empty();
    }

    print(
      '✅ FirestoreService.obtenerCategoriasStream() - Filtrando categorías por UID: $uid',
    );
    // FILTRAR CATEGORÍAS POR USUARIO - Solo mostrar las del usuario actual
    return _db
        .collection('categorias')
        .where('id_usuario', isEqualTo: uid) // Filtrar por usuario actual
        .snapshots();
  }

  // --- CREAR DOCUMENTOS ---

  /// Guardar un nuevo gasto
  /// Lo llamarás desde el BLoC de "Agregar Gasto".
  Future<void> agregarGasto({
    required double monto,
    required String descripcion,
    required String idCategoria,
    required DateTime fecha,
    String? urlArchivo, // Opcional, para la foto
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Debug: Mostrar información de la fecha antes de guardar
    print('=== FIRESTORE DEBUG GASTO ===');
    print('Fecha recibida: $fecha');
    print('Día: ${fecha.day}/${fecha.month}/${fecha.year}');
    print('Es UTC: ${fecha.isUtc}');
    final timestamp = Timestamp.fromDate(fecha);
    print('Timestamp que se guardará: $timestamp');
    print('Timestamp en segundos: ${timestamp.seconds}');
    // Verificar qué fecha representa ese timestamp
    final fechaVerificacion = timestamp.toDate();
    print('Verificación - esa timestamp representa: $fechaVerificacion');
    print('==============================');

    await _db.collection('gastos').add({
      'importe': monto,
      'descripcion': descripcion,
      'id_categoria': idCategoria,
      'fecha': Timestamp.fromDate(fecha),
      'url_archivo': urlArchivo, // Será null si no se sube imagen
      'id_usuario': uid,
    });
  }

  /// Guardar un nuevo ingreso
  /// Lo llamarás desde el BLoC de "Agregar Ingreso".
  Future<void> agregarIngreso({
    required double monto,
    required String concepto, // O "categoría" de ingreso
    required DateTime fecha,
    String?
    idCategoria, // Nuevo parámetro opcional para categorías personalizadas
    String? urlArchivo, // Agregar parámetro para URL de imagen
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Debug: Mostrar información de la fecha antes de guardar
    print('=== FIRESTORE DEBUG INGRESO ===');
    print('Fecha recibida: $fecha');
    print('Día: ${fecha.day}/${fecha.month}/${fecha.year}');
    print('Es UTC: ${fecha.isUtc}');
    final timestamp = Timestamp.fromDate(fecha);
    print('Timestamp que se guardará: $timestamp');
    print('Timestamp en segundos: ${timestamp.seconds}');
    // Verificar qué fecha representa ese timestamp
    final fechaVerificacion = timestamp.toDate();
    print('Verificación - esa timestamp representa: $fechaVerificacion');
    print('=================================');

    final data = {
      'importe': monto,
      'concepto': concepto,
      'fecha': Timestamp.fromDate(fecha),
      'id_usuario': uid,
      'url_archivo': urlArchivo, // Incluir URL del archivo si existe
    };

    // Si se proporciona idCategoria, agregarlo al documento
    if (idCategoria != null && idCategoria.isNotEmpty) {
      data['id_categoria'] = idCategoria;
    }

    await _db.collection('ingresos').add(data);
  }

  /// Guardar una nueva categoría (desde el popup)
  Future<String> agregarCategoria({
    required String nombre,
    required int iconCode, // Código del ícono
    required int colorValue, // Valor del color
    required String tipo, // 'gastos' o 'ingresos'
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    final docRef = await _db.collection('categorias').add({
      'nombre': nombre,
      'icon_code': iconCode,
      'color_value': colorValue,
      'tipo': tipo,
      'id_usuario': uid,
      'created_at': Timestamp.now(),
    });

    return docRef.id; // Retorna el ID generado por Firebase
  }

  /// Migración automática: Crear categorías faltantes basadas en los gastos existentes
  Future<void> migrarCategoriasExistentes() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Obtener todos los gastos del usuario
      final gastosSnapshot = await _db
          .collection('gastos')
          .where('id_usuario', isEqualTo: uid)
          .get();

      // Obtener todas las categorías existentes
      final categoriasSnapshot = await _db
          .collection('categorias')
          .where('id_usuario', isEqualTo: uid)
          .get();

      final categoriasExistentes = categoriasSnapshot.docs
          .map((doc) => doc.id)
          .toSet();

      // Buscar categorías referenciadas en gastos que no existen
      final categoriasRequeridas = <String>{};
      for (final doc in gastosSnapshot.docs) {
        final data = doc.data();
        final categoriaId = data['id_categoria'] as String?;
        if (categoriaId != null && categoriaId.startsWith('custom_')) {
          categoriasRequeridas.add(categoriaId);
        }
      }

      // Crear las categorías faltantes
      for (final categoriaId in categoriasRequeridas) {
        if (!categoriasExistentes.contains(categoriaId)) {
          // Crear categoría genérica para la migración
          await _db.collection('categorias').doc(categoriaId).set({
            'nombre':
                'Categoría Migrada ${categoriaId.replaceAll('custom_', '')}',
            'icon_code': 0xe24d, // Icons.category
            'color_value': 0xFF2196F3, // Colors.blue
            'tipo': 'gastos',
            'id_usuario': uid,
            'created_at': Timestamp.now(),
            'migrated': true, // Marcar como migrada
          });
        }
      }
    } catch (e) {
      print('Error en migración de categorías: $e');
    }
  }

  /// Obtener categorías personalizadas del usuario
  Future<List<Map<String, dynamic>>> obtenerCategoriasPersonalizadas() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      final querySnapshot = await _db
          .collection('categorias')
          .where('id_usuario', isEqualTo: uid)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombre': data['nombre'] ?? '',
          'icon_code': data['icon_code'] ?? 0xe24d, // Icons.category
          'color_value': data['color_value'] ?? 0xFF2196F3, // Colors.blue
          'tipo': data['tipo'] ?? 'gastos',
          'created_at': data['created_at'],
        };
      }).toList();
    } catch (e) {
      print('Error al obtener categorías personalizadas: $e');
      return [];
    }
  }

  /// Obtener el perfil de usuario por UID
  /// Lo llamarás desde el BLoC de "Perfil" para cargar los datos del usuario.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc = await _db
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener perfil de usuario: $e');
      rethrow;
    }
  }

  // --- FUNCIONES DE ELIMINACIÓN ---

  /// Eliminar un gasto por ID
  Future<void> eliminarGasto(String idGasto) async {
    try {
      await _db.collection('gastos').doc(idGasto).delete();
    } catch (e) {
      print('Error al eliminar gasto: $e');
      rethrow;
    }
  }

  /// Eliminar un ingreso por ID
  Future<void> eliminarIngreso(String idIngreso) async {
    try {
      await _db.collection('ingresos').doc(idIngreso).delete();
    } catch (e) {
      print('Error al eliminar ingreso: $e');
      rethrow;
    }
  }

  /// Verificar si una categoría tiene gastos o ingresos asociados
  Future<bool> categoriaTieneTransacciones(String idCategoria) async {
    final uid = _auth.currentUser?.uid;
    print('=== VERIFICANDO TRANSACCIONES ===');
    print('Usuario: $uid');
    print('Categoría ID: $idCategoria');

    if (uid == null) {
      print('Usuario no autenticado');
      return false;
    }

    try {
      // Verificar gastos
      print('Consultando gastos...');
      final gastosSnapshot = await _db
          .collection('gastos')
          .where('id_usuario', isEqualTo: uid)
          .where('id_categoria', isEqualTo: idCategoria)
          .limit(1)
          .get();

      print('Gastos encontrados: ${gastosSnapshot.docs.length}');
      if (gastosSnapshot.docs.isNotEmpty) {
        print('Categoría SÍ tiene gastos asociados');
        return true;
      }

      // Verificar ingresos
      print('Consultando ingresos...');
      final ingresosSnapshot = await _db
          .collection('ingresos')
          .where('id_usuario', isEqualTo: uid)
          .where('id_categoria', isEqualTo: idCategoria)
          .limit(1)
          .get();

      print('Ingresos encontrados: ${ingresosSnapshot.docs.length}');
      final tieneIngresos = ingresosSnapshot.docs.isNotEmpty;

      print('Resultado final - tiene transacciones: $tieneIngresos');
      return tieneIngresos;
    } catch (e) {
      print('Error al verificar transacciones de categoría: $e');
      return true; // Por seguridad, si hay error asumimos que sí tiene transacciones
    }
  }

  /// Eliminar una categoría personalizada
  Future<void> eliminarCategoria(String idCategoria) async {
    final uid = _auth.currentUser?.uid;
    print('=== FIRESTORE: ELIMINAR CATEGORÍA ===');
    print('Usuario autenticado: $uid');
    print('ID de categoría: $idCategoria');

    if (uid == null) throw Exception('Usuario no autenticado');

    try {
      // Primero verificar que el documento existe
      print('Verificando que el documento existe...');
      final doc = await _db.collection('categorias').doc(idCategoria).get();
      print('Documento existe: ${doc.exists}');
      if (doc.exists) {
        print('Datos del documento: ${doc.data()}');
        final data = doc.data();
        if (data != null) {
          print('id_usuario del documento: ${data['id_usuario']}');
          print('Usuario actual: $uid');
          print('¿Coinciden? ${data['id_usuario'] == uid}');
        }
      }

      print('Intentando eliminar documento de Firebase...');
      await _db.collection('categorias').doc(idCategoria).delete();
      print('Comando de eliminación ejecutado');

      // Verificar que se eliminó
      print('Verificando eliminación...');
      final docAfter = await _db
          .collection('categorias')
          .doc(idCategoria)
          .get();
      print('Documento existe después de eliminar: ${docAfter.exists}');
    } catch (e) {
      print('ERROR en Firebase al eliminar categoría: $e');
      print('Tipo de error: ${e.runtimeType}');
      rethrow;
    }
  }

  // --- AQUÍ IRÍAN LAS FUNCIONES DE ACTUALIZAR ---
  // Future<void> actualizarGasto(String idGasto, Map<String, dynamic> data) { ... }
}
