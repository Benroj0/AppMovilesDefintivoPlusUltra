import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

import 'CategoriesEvent.dart';
import 'CategoriesState.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final FirestoreService _firestoreService;
  late StreamSubscription _authSubscription;
  // Categorías predeterminadas para gastos
  final List<Category> defaultGastosCategories = [
    Category(
      id: 'comida_default',
      name: 'Comida',
      icon: Icons.fastfood,
      color: Colors.red,
      type: CategoryType.gastos,
      isDefault: true,
    ),
    Category(
      id: 'transporte_default',
      name: 'Transporte',
      icon: Icons.directions_car,
      color: Colors.blue,
      type: CategoryType.gastos,
      isDefault: true,
    ),
    Category(
      id: 'servicios_default',
      name: 'Servicios',
      icon: Icons.build,
      color: Colors.orange,
      type: CategoryType.gastos,
      isDefault: true,
    ),
    Category(
      id: 'salud_default',
      name: 'Salud',
      icon: Icons.local_hospital,
      color: Colors.pink,
      type: CategoryType.gastos,
      isDefault: true,
    ),
    Category(
      id: 'otros_gastos_default',
      name: 'Otros',
      icon: Icons.category,
      color: Colors.grey,
      type: CategoryType.gastos,
      isDefault: true,
    ),
  ];

  // Categorías predeterminadas para ingresos
  final List<Category> defaultIngresosCategories = [
    Category(
      id: 'salario_default',
      name: 'Salario',
      icon: Icons.work,
      color: Colors.green,
      type: CategoryType.ingresos,
      isDefault: true,
    ),
    Category(
      id: 'negocio_default',
      name: 'Negocio',
      icon: Icons.business,
      color: Colors.teal,
      type: CategoryType.ingresos,
      isDefault: true,
    ),
    Category(
      id: 'inversiones_default',
      name: 'Inversiones',
      icon: Icons.trending_up,
      color: Colors.purple,
      type: CategoryType.ingresos,
      isDefault: true,
    ),
    Category(
      id: 'otros_ingresos_default',
      name: 'Otros',
      icon: Icons.attach_money,
      color: Colors.lightGreen,
      type: CategoryType.ingresos,
      isDefault: true,
    ),
  ];

  CategoriesBloc({required FirestoreService firestoreService})
    : _firestoreService = firestoreService,
      super(const CategoriesState()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<RemoveCategoryEvent>(_onRemoveCategory);
    on<ClearErrorEvent>(_onClearError);
    on<ClearCategoriesEvent>(_onClearCategories);

    // 🔥 ESCUCHAR CAMBIOS DE AUTENTICACIÓN AUTOMÁTICAMENTE
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      print(
        '🔄 CategoriesBloc: Auth state changed - User: ${user?.email ?? 'null'}',
      );
      if (user != null) {
        // Usuario autenticado - cargar categorías automáticamente
        print('✅ CategoriesBloc: Cargando categorías para nuevo usuario');
        add(LoadCategoriesEvent());
      } else {
        // Usuario desconectado - limpiar estado
        print('🧹 CategoriesBloc: Limpiando estado por logout');
        add(ClearCategoriesEvent());
      }
    });
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    print('🚀 CategoriesBloc: _onLoadCategories iniciando...');
    emit(state.copyWith(loading: true));
    print('⏳ CategoriesBloc: Estado de loading emitido');

    try {
      // Ejecutar migración automática (solo si es necesaria)
      await _firestoreService.migrarCategoriasExistentes();

      // Cargar categorías personalizadas desde Firebase
      final categoriasPersonalizadasData = await _firestoreService
          .obtenerCategoriasPersonalizadas();

      // Convertir los datos de Firebase a objetos Category
      final categoriasPersonalizadas = categoriasPersonalizadasData.map((data) {
        return Category(
          id: data['id'],
          name: data['nombre'],
          icon: IconData(data['icon_code'], fontFamily: 'MaterialIcons'),
          color: Color(data['color_value']),
          type: data['tipo'] == 'ingresos'
              ? CategoryType.ingresos
              : CategoryType.gastos,
          isDefault: false,
        );
      }).toList();

      // Combinar categorías predeterminadas y personalizadas
      final allCategories = [
        ...defaultGastosCategories,
        ...defaultIngresosCategories,
        ...categoriasPersonalizadas,
      ];

      emit(
        state.copyWith(
          allCategories: allCategories,
          customCategories: categoriasPersonalizadas,
          loading: false,
        ),
      );
    } catch (e) {
      print('Error al cargar categorías: $e');
      // En caso de error, solo usar categorías predeterminadas
      final allCategories = [
        ...defaultGastosCategories,
        ...defaultIngresosCategories,
      ];
      emit(
        state.copyWith(
          allCategories: allCategories,
          loading: false,
          error: 'Error al cargar categorías personalizadas',
        ),
      );
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) {
      emit(state.copyWith(error: "El nombre no puede estar vacío"));
      return;
    }

    // Verificar si ya existe una categoría con ese nombre del mismo tipo
    final existingCategory = state.allCategories.any(
      (category) =>
          category.name.toLowerCase() == name.toLowerCase() &&
          category.type == event.type,
    );

    if (existingCategory) {
      emit(state.copyWith(error: "Ya existe una categoría con ese nombre"));
      return;
    }

    try {
      // Guardar en Firebase
      final firebaseId = await _firestoreService.agregarCategoria(
        nombre: name,
        iconCode: event.icon.codePoint,
        colorValue: event.color.value,
        tipo: event.type == CategoryType.gastos ? 'gastos' : 'ingresos',
      );

      // Crear nueva categoría con el ID de Firebase
      final newCategory = Category(
        id: firebaseId,
        name: name,
        icon: event.icon,
        color: event.color,
        type: event.type,
        isDefault: false,
      );

      // Actualizar listas
      final updatedCustomCategories = List<Category>.from(
        state.customCategories,
      )..add(newCategory);

      final updatedAllCategories = List<Category>.from(state.allCategories)
        ..add(newCategory);

      emit(
        state.copyWith(
          customCategories: updatedCustomCategories,
          allCategories: updatedAllCategories,
          error: null,
        ),
      );
    } catch (e) {
      print('Error al guardar categoría: $e');
      emit(state.copyWith(error: "Error al guardar la categoría"));
    }
  }

  Future<void> _onRemoveCategory(
    RemoveCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    print('=== INICIANDO ELIMINACIÓN DE CATEGORÍA ===');
    print('ID de categoría a eliminar: ${event.categoryId}');

    emit(state.copyWith(loading: true));

    try {
      // Solo permitir eliminar categorías personalizadas
      final categoryToRemove = state.allCategories.firstWhere(
        (category) => category.id == event.categoryId,
        orElse: () => throw Exception('Categoría no encontrada'),
      );

      print(
        'Categoría encontrada: ${categoryToRemove.name} (isDefault: ${categoryToRemove.isDefault})',
      );

      if (categoryToRemove.isDefault) {
        print('ERROR: Intentando eliminar categoría predeterminada');

        // Emitir error temporalmente
        emit(
          state.copyWith(
            loading: false,
            error: "No se pueden eliminar categorías predeterminadas",
          ),
        );

        // Limpiar el error inmediatamente después
        Future.delayed(const Duration(milliseconds: 500), () {
          emit(state.copyWith(loading: false, error: null));
        });

        return;
      }

      print('Verificando si tiene transacciones...');
      // Verificar si la categoría tiene transacciones asociadas
      final tieneTransacciones = await _firestoreService
          .categoriaTieneTransacciones(event.categoryId);

      print('Tiene transacciones: $tieneTransacciones');

      if (tieneTransacciones) {
        print('ERROR: Categoría tiene transacciones asociadas');

        // Emitir error temporalmente
        emit(
          state.copyWith(
            loading: false,
            error:
                "No se puede eliminar la categoría porque tiene gastos o ingresos registrados en esa categoría",
          ),
        );

        // Limpiar el error inmediatamente después para que no se propague
        Future.delayed(const Duration(milliseconds: 500), () {
          emit(state.copyWith(loading: false, error: null));
        });

        return;
      }

      print('Eliminando de Firebase...');
      // Eliminar de Firebase
      await _firestoreService.eliminarCategoria(event.categoryId);
      print('Eliminado de Firebase exitosamente');

      // Verificar que realmente se eliminó de Firebase
      print('Verificando eliminación desde Firebase...');
      final categoriasActualizadas = await _firestoreService
          .obtenerCategoriasPersonalizadas();
      print(
        'Categorías en Firebase después de eliminación: ${categoriasActualizadas.length}',
      );
      for (final cat in categoriasActualizadas) {
        print('- ${cat['id']}: ${cat['nombre']}');
      }

      // Remover de ambas listas localmente
      final updatedCustomCategories = state.customCategories
          .where((category) => category.id != event.categoryId)
          .toList();

      final updatedAllCategories = state.allCategories
          .where((category) => category.id != event.categoryId)
          .toList();

      print('Actualizando estado local...');
      print(
        'Categorías personalizadas antes: ${state.customCategories.length}',
      );
      print(
        'Categorías personalizadas después: ${updatedCustomCategories.length}',
      );

      emit(
        state.copyWith(
          customCategories: updatedCustomCategories,
          allCategories: updatedAllCategories,
          loading: false,
          error: null,
        ),
      );

      print('=== ELIMINACIÓN COMPLETADA EXITOSAMENTE ===');
    } catch (e) {
      print('ERROR al eliminar categoría: $e');
      print('Stack trace: ${StackTrace.current}');

      // Emitir error temporalmente
      emit(
        state.copyWith(
          loading: false,
          error: "Error al eliminar la categoría: $e",
        ),
      );

      // Limpiar el error inmediatamente después
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(loading: false, error: null));
      });
    }
  }

  Future<void> _onClearError(
    ClearErrorEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(error: null));
  }

  Future<void> _onClearCategories(
    ClearCategoriesEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    print('🧹 CategoriesBloc: Limpiando estado de categorías');
    emit(const CategoriesState()); // Reset al estado inicial
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
