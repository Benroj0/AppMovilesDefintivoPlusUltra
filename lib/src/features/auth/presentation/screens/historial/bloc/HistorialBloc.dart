import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'HistorialEvent.dart';
import 'HistorialState.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription _authSubscription;

  HistorialBloc({required FirestoreService firestoreService})
    : _firestoreService = firestoreService,
      super(const HistorialState()) {
    on<AddHistorial>(_onAddHistorial);
    on<LoadHistorial>(_onLoadHistorial);
    on<DeleteHistorial>(_onDeleteHistorial);
    on<ClearHistorialEvent>(_onClearHistorial);

    // 🔥 ESCUCHAR CAMBIOS DE AUTENTICACIÓN AUTOMÁTICAMENTE
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      print(
        '🔄 HistorialBloc: Auth state changed - User: ${user?.email ?? 'null'}',
      );
      if (user != null) {
        // Usuario autenticado - cargar historial automáticamente
        print('✅ HistorialBloc: Cargando historial para nuevo usuario');
        add(const LoadHistorial());
      } else {
        // Usuario desconectado - limpiar estado
        print('🧹 HistorialBloc: Limpiando estado por logout');
        add(ClearHistorialEvent());
      }
    });
  }

  void _onAddHistorial(AddHistorial event, Emitter<HistorialState> emit) {
    final nuevo = {
      "categoria": event.categoria,
      "monto": event.monto,
      "descripcion": event.descripcion,
      "fecha": event.fecha,
    };
    emit(state.copyWith(historial: List.from(state.historial)..add(nuevo)));
  }

  void _onLoadHistorial(
    LoadHistorial event,
    Emitter<HistorialState> emit,
  ) async {
    try {
      emit(state.copyWith(loading: true, error: null));

      final gastosStream = _firestoreService.obtenerGastosStream();
      final ingresosStream = _firestoreService.obtenerIngresosStream();
      final categoriasStream = _firestoreService.obtenerCategoriasStream();

      // Obtener los datos de los streams
      final gastosSnapshot = await gastosStream.first;
      final ingresosSnapshot = await ingresosStream.first;
      final categoriasSnapshot = await categoriasStream.first;

      // Crear mapa de categorías por ID
      Map<String, String> categoriesMap = {};
      for (var doc in categoriasSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        categoriesMap[doc.id] = data['name'] ?? 'Sin nombre';
      }

      List<Map<String, dynamic>> historial = [];

      // Agregar gastos al historial
      print('=== DEBUG HistorialBloc ===');
      print('gastosSnapshot.docs.length: ${gastosSnapshot.docs.length}');
      print('categoriesMap: $categoriesMap');

      for (var doc in gastosSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('Gasto doc ID: ${doc.id}');
        print('Gasto data: $data');

        String categoryName = 'Sin categoría';

        // Priorizar id_categoria, si no existe usar concepto
        if (data['id_categoria'] != null) {
          categoryName =
              categoriesMap[data['id_categoria']] ?? 'Categoría eliminada';
          print('Using id_categoria: ${data['id_categoria']} -> $categoryName');
        } else if (data['concepto'] != null) {
          categoryName = data['concepto'];
          print('Using concepto: $categoryName');
        }

        print('Final categoryName: "$categoryName"');
        print(
          '_isValidCategory($categoryName): ${_isValidCategory(categoryName)}',
        );

        // Filtrar categorías no deseadas
        if (_isValidCategory(categoryName)) {
          final historialItem = {
            'categoria': categoryName,
            'monto': (data['importe'] ?? 0.0)
                .toDouble(), // Usar 'importe' en lugar de 'monto'
            'descripcion': 'Gasto',
            'fecha':
                data['fecha']?.toDate() ??
                DateTime.now(), // Usar 'fecha' en lugar de 'fecha_creacion'
            'imageUrl':
                data['url_archivo'], // Incluir URL de la imagen (campo correcto)
          };
          print('Adding to historial: $historialItem');
          historial.add(historialItem);
        }
      }

      print('Total historial items added: ${historial.length}');
      print('=== END DEBUG HistorialBloc ===');

      // Agregar ingresos al historial
      for (var doc in ingresosSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String categoryName = 'Sin categoría';

        // Priorizar id_categoria, si no existe usar concepto
        if (data['id_categoria'] != null) {
          categoryName =
              categoriesMap[data['id_categoria']] ?? 'Categoría eliminada';
        } else if (data['concepto'] != null) {
          categoryName = data['concepto'];
        }

        // Filtrar categorías no deseadas
        if (_isValidCategory(categoryName)) {
          historial.add({
            'categoria': categoryName,
            'monto': (data['importe'] ?? 0.0)
                .toDouble(), // Usar 'importe' en lugar de 'monto'
            'descripción': 'Ingreso',
            'fecha':
                data['fecha']?.toDate() ??
                DateTime.now(), // Usar 'fecha' en lugar de 'fecha_creacion'
            'imageUrl':
                data['url_archivo'], // Incluir URL de la imagen (campo correcto)
          });
        }
      }

      // Ordenar por fecha (más recientes primero)
      historial.sort(
        (a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime),
      );

      emit(state.copyWith(historial: historial, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onDeleteHistorial(DeleteHistorial event, Emitter<HistorialState> emit) {
    final updatedHistorial = List<Map<String, dynamic>>.from(state.historial);

    // Buscar y eliminar la transacción que coincida
    updatedHistorial.removeWhere((transaction) {
      return transaction['categoria'] ==
              event.transactionToDelete['categoria'] &&
          transaction['monto'] == event.transactionToDelete['monto'] &&
          transaction['descripcion'] ==
              event.transactionToDelete['descripcion'] &&
          transaction['fecha'] == event.transactionToDelete['fecha'];
    });

    emit(state.copyWith(historial: updatedHistorial));
  }

  /// Valida si una categoría es válida para mostrar en el historial
  bool _isValidCategory(String categoryName) {
    // TEMPORAL: Permitir todas las categorías para debug
    return categoryName.isNotEmpty && categoryName.trim().isNotEmpty;

    // ORIGINAL (comentado temporalmente):
    // final invalidCategories = [
    //   'Sin nombre',
    //   'Categoría eliminada',
    //   'Sin categoría',
    // ];
    // return categoryName.isNotEmpty &&
    //     !invalidCategories.contains(categoryName) &&
    //     categoryName.trim().isNotEmpty;
  }

  void _onClearHistorial(
    ClearHistorialEvent event,
    Emitter<HistorialState> emit,
  ) {
    print('🧹 HistorialBloc: Limpiando estado del historial');
    emit(const HistorialState()); // Reset al estado inicial
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
