import 'package:flutter_bloc/flutter_bloc.dart';
import 'ExportarEvent.dart';
import 'ExportarState.dart';

class ExportarBloc extends Bloc<ExportarEvent, ExportarState> {
  ExportarBloc() : super(ExportarInitial()) {
    on<SelectPeriodEvent>(_onSelectPeriod);
    on<SelectCustomDateEvent>(_onSelectCustomDate);
    on<ExportDataEvent>(_onExportData);
  }

  void _onSelectPeriod(SelectPeriodEvent event, Emitter<ExportarState> emit) {
    DateTime now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (event.period) {
      case 'Mes actual (Octubre)':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Últimos 30 días':
        startDate = now.subtract(const Duration(days: 30));
        endDate = now;
        break;
      case 'Últimos 90 días':
        startDate = now.subtract(const Duration(days: 90));
        endDate = now;
        break;
      case 'Últimos 365 días':
        startDate = now.subtract(const Duration(days: 365));
        endDate = now;
        break;
    }

    emit(
      ExportarPeriodSelected(
        selectedPeriod: event.period,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  void _onSelectCustomDate(
    SelectCustomDateEvent event,
    Emitter<ExportarState> emit,
  ) {
    emit(
      ExportarPeriodSelected(
        selectedPeriod: 'Costumbre',
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
  }

  void _onExportData(ExportDataEvent event, Emitter<ExportarState> emit) async {
    emit(ExportarLoading());

    try {
      // Simular proceso de exportación
      await Future.delayed(const Duration(seconds: 2));

      // Aquí iría la lógica real de exportación
      emit(const ExportarSuccess('Datos exportados exitosamente'));
    } catch (e) {
      emit(ExportarError('Error al exportar datos: ${e.toString()}'));
    }
  }
}
