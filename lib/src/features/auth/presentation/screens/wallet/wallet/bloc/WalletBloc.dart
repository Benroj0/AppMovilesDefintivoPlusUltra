import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/bloc/WalletEvent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/wallet/wallet/bloc/WalletState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletState.initial()) {
    on<LoadWalletData>(_onLoadWalletData);
  }

  void _onLoadWalletData(LoadWalletData event, Emitter<WalletState> emit) {
    // Aquí puedes cargar los datos reales de tu repo/db.
    emit(
      WalletState(
        presupuesto: 3000.0,
        gastado: 2.08,
        cantidadGastos: 1,
        topCategoria: "Compras",
        montoTopCategoria: 2.08,
      ),
    );
  }
}
