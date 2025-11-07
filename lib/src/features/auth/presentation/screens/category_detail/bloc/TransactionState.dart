abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionDeleted extends TransactionState {
  final String message;

  TransactionDeleted(this.message);
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
}
