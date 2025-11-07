import 'dart:io';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'RegistrarGastoEvent.dart';
import 'RegistrarGastoState.dart';

class RegistrarGastoBloc
    extends Bloc<RegistrarGastoEvent, RegistrarGastoState> {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  // Campos para guardar los datos del formulario
  String _monto = '0.0';
  String _idCategoria = '';
  String _nombreCategoria = '';
  DateTime _fecha = (() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  })();
  String? _urlEvidencia; // URL de la imagen subida

  RegistrarGastoBloc({
    required FirestoreService firestoreService,
    StorageService? storageService,
  }) : _firestoreService = firestoreService,
       _storageService = storageService ?? StorageService(),
       super(const RegistrarGastoState()) {
    on<MontoChanged>(_onMontoChanged);
    on<CategoriaChanged>(_onCategoriaChanged);
    on<FechaChanged>(_onFechaChanged);
    on<ImagenSelected>(_onImagenSelected);
    on<ImagenRemoved>(_onImagenRemoved);
    on<GastoSubmitted>(_onGastoSubmitted);
  }

  void _onMontoChanged(MontoChanged event, Emitter<RegistrarGastoState> emit) {
    _monto = event.monto;
    // (Aquí puedes añadir lógica de validación si quieres)
  }

  void _onCategoriaChanged(
    CategoriaChanged event,
    Emitter<RegistrarGastoState> emit,
  ) {
    _idCategoria = event.idCategoria;
    _nombreCategoria = event.nombreCategoria;
  }

  void _onFechaChanged(FechaChanged event, Emitter<RegistrarGastoState> emit) {
    _fecha = event.fecha;
    print('=== BLOC FECHA CHANGED ===');
    print('Nueva fecha en BLoC: $_fecha');
    print('Día: ${_fecha.day}/${_fecha.month}/${_fecha.year}');
    print('Es UTC: ${_fecha.isUtc}');
    print('==========================');
  }

  void _onImagenSelected(
    ImagenSelected event,
    Emitter<RegistrarGastoState> emit,
  ) async {
    emit(state.copyWith(subiendoImagen: true, error: null));

    try {
      // Subir la imagen a Firebase Storage
      final File imageFile = File(event.imagePath);
      final String imageUrl = await _storageService.uploadImage(
        imageFile: imageFile,
        folder: 'evidencias',
      );

      _urlEvidencia = imageUrl;
      emit(
        state.copyWith(
          imagePath: event.imagePath,
          imageUrl: imageUrl,
          subiendoImagen: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          subiendoImagen: false,
          error: 'Error al subir la imagen: ${e.toString()}',
        ),
      );
    }
  }

  void _onImagenRemoved(
    ImagenRemoved event,
    Emitter<RegistrarGastoState> emit,
  ) async {
    try {
      // Si había una imagen subida, eliminarla de Firebase Storage
      if (_urlEvidencia != null) {
        await _storageService.deleteImage(_urlEvidencia!);
      }

      _urlEvidencia = null;
      emit(state.copyWith(imagePath: null, imageUrl: null));
    } catch (e) {
      emit(
        state.copyWith(error: 'Error al eliminar la imagen: ${e.toString()}'),
      );
    }
  }

  // --- Handler del botón "Guardar" ---

  Future<void> _onGastoSubmitted(
    GastoSubmitted event,
    Emitter<RegistrarGastoState> emit,
  ) async {
    // 1. Validar campos
    final double? montoDouble = double.tryParse(_monto);
    if (montoDouble == null || montoDouble <= 0) {
      emit(state.copyWith(error: "El monto debe ser mayor a 0."));
      // Limpiar el error después de un tiempo
      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(error: null));
      return;
    }

    if (_idCategoria.isEmpty || _nombreCategoria.isEmpty) {
      final tipoTransaccion = event.isGasto ? "gasto" : "ingreso";
      emit(
        state.copyWith(
          error: "Debes seleccionar una categoría para el $tipoTransaccion.",
        ),
      );
      // Limpiar el error después de un tiempo
      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(error: null));
      return;
    }

    emit(state.copyWith(guardando: true, exito: false, error: null));

    try {
      // Debug: Mostrar la fecha que se va a guardar
      print('=== DEBUG FECHA ===');
      print('Fecha a guardar: $_fecha');
      print('Fecha UTC: ${_fecha.toUtc()}');
      print('Fecha local: ${_fecha.toLocal()}');
      print('==================');

      // Guardar según el tipo (gasto o ingreso)
      if (event.isGasto) {
        await _firestoreService.agregarGasto(
          monto: montoDouble,
          descripcion: _nombreCategoria,
          idCategoria: _idCategoria,
          fecha: _fecha,
          urlArchivo: _urlEvidencia, // Incluir la URL de la imagen
        );
      } else {
        await _firestoreService.agregarIngreso(
          monto: montoDouble,
          concepto: _nombreCategoria,
          idCategoria: _idCategoria,
          fecha: _fecha,
          urlArchivo: _urlEvidencia, // Incluir la URL de la imagen
        );
      }

      emit(state.copyWith(guardando: false, exito: true));

      // Limpiar el estado incluyendo la imagen
      _urlEvidencia = null;
      emit(const RegistrarGastoState()); // Opcional: limpiar todo
    } catch (e) {
      final tipoTransaccion = event.isGasto ? "gasto" : "ingreso";
      emit(
        state.copyWith(
          guardando: false,
          error: "No se pudo guardar el $tipoTransaccion.",
        ),
      );
    }
  }
}
