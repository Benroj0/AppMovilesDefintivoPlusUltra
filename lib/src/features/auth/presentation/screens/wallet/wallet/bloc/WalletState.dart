import 'package:equatable/equatable.dart';

class WalletState extends Equatable {
  final double presupuesto;
  final double gastado;
  final int cantidadGastos;
  final String topCategoria;
  final double montoTopCategoria;

  const WalletState({
    required this.presupuesto,
    required this.gastado,
    required this.cantidadGastos,
    required this.topCategoria,
    required this.montoTopCategoria,
  });

  factory WalletState.initial() => const WalletState(
        presupuesto: 3000.0,
        gastado: 0.0,
        cantidadGastos: 0,
        topCategoria: '',
        montoTopCategoria: 0.0,
      );

  @override
  List<Object?> get props =>
      [presupuesto, gastado, cantidadGastos, topCategoria, montoTopCategoria];
}