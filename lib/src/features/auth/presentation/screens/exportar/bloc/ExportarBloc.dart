import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/services/excel_service.dart';
import 'ExportarEvent.dart';
import 'ExportarState.dart';

class ExportarBloc extends Bloc<ExportarEvent, ExportarState> {
  final ExcelService _excelService = ExcelService();

  ExportarBloc() : super(_getInitialState()) {
    on<SelectPeriodEvent>(_onSelectPeriod);
    on<SelectCustomDateEvent>(_onSelectCustomDate);
    on<ExportDataEvent>(_onExportData);
  }

  static ExportarState _getInitialState() {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, 1);
    DateTime endDate = DateTime(now.year, now.month + 1, 0);

    final initialState = ExportarPeriodSelected(
      selectedPeriod: 'Mes actual',
      startDate: startDate,
      endDate: endDate,
    );

    print('🚀 ExportarBloc: Estado inicial creado');
    print('📅 ExportarBloc: Período inicial: ${initialState.selectedPeriod}');
    print('📅 ExportarBloc: Fecha inicial inicio: ${initialState.startDate}');
    print('📅 ExportarBloc: Fecha inicial fin: ${initialState.endDate}');

    return initialState;
  }

  void _onSelectPeriod(SelectPeriodEvent event, Emitter<ExportarState> emit) {
    DateTime now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (event.period) {
      case 'Mes actual':
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
      print('📊 ExportarBloc: Iniciando exportación de datos...');
      print('🔍 ExportarBloc: Estado actual: ${state.runtimeType}');

      // Obtener el estado actual para acceder a las fechas seleccionadas
      final currentState = state;

      String period;
      DateTime? startDate;
      DateTime? endDate;

      if (currentState is ExportarPeriodSelected) {
        print('✅ ExportarBloc: Estado válido encontrado');
        period = currentState.selectedPeriod;
        startDate = currentState.startDate;
        endDate = currentState.endDate;
        print('📅 ExportarBloc: Período: $period');
        print('📅 ExportarBloc: Fecha inicio: $startDate');
        print('📅 ExportarBloc: Fecha fin: $endDate');
      } else {
        print(
          '⚠️ ExportarBloc: Estado actual NO es ExportarPeriodSelected, usando valores por defecto',
        );
        print('⚠️ ExportarBloc: Estado actual es: $currentState');

        // Usar valores por defecto para mes actual
        DateTime now = DateTime.now();
        period = 'Mes actual';
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);

        print('📅 ExportarBloc: Usando período por defecto: $period');
        print('📅 ExportarBloc: Usando fecha inicio por defecto: $startDate');
        print('📅 ExportarBloc: Usando fecha fin por defecto: $endDate');
      }

      await _excelService.exportToExcel(
        period: period,
        startDate: startDate,
        endDate: endDate,
      );

      emit(
        const ExportarSuccess(
          '¡Archivo Excel exportado y compartido exitosamente!',
        ),
      );
    } catch (e) {
      print('❌ ExportarBloc: Error en exportación: $e');
      emit(ExportarError('Error al exportar datos: ${e.toString()}'));
    }
  }
}
