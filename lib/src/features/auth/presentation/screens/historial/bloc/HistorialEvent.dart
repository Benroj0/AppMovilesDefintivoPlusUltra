import 'package:equatable/equatable.dart';

abstract class HistorialEvent extends Equatable {
  const HistorialEvent();

  @override
  List<Object?> get props => [];
}

class AddHistorial extends HistorialEvent {
  final String categoria;
  final double monto;
  final String descripcion;
  final DateTime fecha;

  const AddHistorial({
    required this.categoria,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  @override
  List<Object?> get props => [categoria, monto, descripcion, fecha];
}

class LoadHistorial extends HistorialEvent {
  const LoadHistorial();
}

class DeleteHistorial extends HistorialEvent {
  final Map<String, dynamic> transactionToDelete;

  const DeleteHistorial({required this.transactionToDelete});

  @override
  List<Object?> get props => [transactionToDelete];
}

class ClearHistorialEvent extends HistorialEvent {
  const ClearHistorialEvent();
}
