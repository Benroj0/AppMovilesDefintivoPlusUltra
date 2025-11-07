abstract class TransactionEvent {}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  final bool isGasto; // true para gastos, false para ingresos

  DeleteTransactionEvent({required this.transactionId, required this.isGasto});
}
