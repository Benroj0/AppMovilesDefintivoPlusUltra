import 'package:equatable/equatable.dart';

// Clase base abstracta
abstract class RegistrarGastoEvent extends Equatable {
  const RegistrarGastoEvent();

  @override
  List<Object> get props => [];
}

// Evento para cuando el usuario cambia el monto
class MontoChanged extends RegistrarGastoEvent {
  final String monto; // Es mejor recibirlo como String desde el TextField
  const MontoChanged(this.monto);

  @override
  List<Object> get props => [monto];
}

// Evento para cuando el usuario cambia la descripción
class DescripcionChanged extends RegistrarGastoEvent {
  final String descripcion;
  const DescripcionChanged(this.descripcion);

  @override
  List<Object> get props => [descripcion];
}

// Evento para cuando el usuario selecciona una categoría
class CategoriaChanged extends RegistrarGastoEvent {
  final String idCategoria;
  final String nombreCategoria;
  const CategoriaChanged({
    required this.idCategoria,
    required this.nombreCategoria,
  });

  @override
  List<Object> get props => [idCategoria, nombreCategoria];
}

// Evento para cuando el usuario selecciona una fecha
class FechaChanged extends RegistrarGastoEvent {
  final DateTime fecha;
  const FechaChanged(this.fecha);

  @override
  List<Object> get props => [fecha];
}

// Evento para cuando el usuario selecciona una imagen
class ImagenSelected extends RegistrarGastoEvent {
  final String imagePath;
  const ImagenSelected(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

// Evento para cuando el usuario elimina la imagen seleccionada
class ImagenRemoved extends RegistrarGastoEvent {
  const ImagenRemoved();

  @override
  List<Object> get props => [];
}

// Evento para cuando el usuario presiona el botón "Guardar"
class GastoSubmitted extends RegistrarGastoEvent {
  final bool isGasto; // true para gasto, false para ingreso
  const GastoSubmitted({required this.isGasto});

  @override
  List<Object> get props => [isGasto];
}
