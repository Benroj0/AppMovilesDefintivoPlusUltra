import 'package:equatable/equatable.dart';

class HistorialState extends Equatable {
  final List<Map<String, dynamic>> historial;
  final bool loading;
  final String? error;

  const HistorialState({
    this.historial = const [],
    this.loading = false, 
    this.error,           
  });

  HistorialState copyWith({
    List<Map<String, dynamic>>? historial,
    bool? loading, 
    String? error, 
  }) {
    return HistorialState(
      historial: historial ?? this.historial,
      loading: loading ?? this.loading, 
      error: error,                       
    );
  }

  @override
  // Update props
  List<Object?> get props => [historial, loading, error]; // <-- UPDATED
}
