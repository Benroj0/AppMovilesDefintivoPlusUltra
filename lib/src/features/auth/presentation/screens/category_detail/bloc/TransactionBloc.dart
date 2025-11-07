import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../../services/firestore_service.dart';
import 'TransactionEvent.dart';
import 'TransactionState.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final FirestoreService _firestoreService;

  TransactionBloc(this._firestoreService) : super(TransactionInitial()) {
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());

      if (event.isGasto) {
        await _firestoreService.eliminarGasto(event.transactionId);
      } else {
        await _firestoreService.eliminarIngreso(event.transactionId);
      }

      emit(TransactionDeleted('Transacción eliminada correctamente'));
    } catch (e) {
      emit(TransactionError('Error al eliminar la transacción: $e'));
    }
  }
}
