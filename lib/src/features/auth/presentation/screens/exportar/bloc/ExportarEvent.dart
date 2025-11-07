abstract class ExportarEvent {}

class SelectPeriodEvent extends ExportarEvent {
  final String period;
  SelectPeriodEvent(this.period);
}

class SelectCustomDateEvent extends ExportarEvent {
  final DateTime startDate;
  final DateTime endDate;
  SelectCustomDateEvent(this.startDate, this.endDate);
}

class ExportDataEvent extends ExportarEvent {}
