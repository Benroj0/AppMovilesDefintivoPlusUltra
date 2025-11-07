import 'package:equatable/equatable.dart';

abstract class ExportarState extends Equatable {
  const ExportarState();

  @override
  List<Object?> get props => [];
}

class ExportarInitial extends ExportarState {}

class ExportarLoading extends ExportarState {}

class ExportarPeriodSelected extends ExportarState {
  final String selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportarPeriodSelected({
    required this.selectedPeriod,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [selectedPeriod, startDate, endDate];
}

class ExportarSuccess extends ExportarState {
  final String message;

  const ExportarSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ExportarError extends ExportarState {
  final String message;

  const ExportarError(this.message);

  @override
  List<Object> get props => [message];
}
