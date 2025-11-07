import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/ExportarBloc.dart';
import 'bloc/ExportarEvent.dart';
import 'bloc/ExportarState.dart';

class ExportarContent extends StatelessWidget {
  final VoidCallback? onBack;

  const ExportarContent({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExportarBloc(),
      child: _ExportarContentBody(onBack: onBack),
    );
  }
}

class _ExportarContentBody extends StatefulWidget {
  final VoidCallback? onBack;

  const _ExportarContentBody({this.onBack});

  @override
  State<_ExportarContentBody> createState() => _ExportarContentBodyState();
}

class _ExportarContentBodyState extends State<_ExportarContentBody> {
  String? selectedPeriod;
  DateTime? customStartDate;
  DateTime? customEndDate;

  final List<String> periods = [
    'Mes actual (Octubre)',
    'Últimos 30 días',
    'Últimos 90 días',
    'Últimos 365 días',
    'Costumbre',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportarBloc, ExportarState>(
      listener: (context, state) {
        if (state is ExportarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ExportarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        color: const Color(0xFFE8F5E8),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con flecha de retroceso
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              widget.onBack ?? () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).iconTheme.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exportar datos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Título Período
                    Text(
                      'Período',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista de opciones de período
                    Expanded(
                      child: Column(
                        children: [
                          ...periods.map(
                            (period) => _buildPeriodOption(period),
                          ),

                          // Campo de fecha personalizada si se selecciona "Costumbre"
                          if (selectedPeriod == 'Costumbre') ...[
                            const SizedBox(height: 20),
                            _buildCustomDatePicker(),
                          ],

                          const Spacer(),

                          // Botón Exportar
                          BlocBuilder<ExportarBloc, ExportarState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: selectedPeriod != null
                                      ? () {
                                          context.read<ExportarBloc>().add(
                                            ExportDataEvent(),
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: state is ExportarLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Exportar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodOption(String period) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
        context.read<ExportarBloc>().add(SelectPeriodEvent(period));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Radio<String>(
              value: period,
              groupValue: selectedPeriod,
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value;
                });
                if (value != null) {
                  context.read<ExportarBloc>().add(SelectPeriodEvent(value));
                }
              },
              activeColor: Colors.teal,
            ),
            const SizedBox(width: 8),
            Text(
              period,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDatePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: customStartDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    customStartDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  customStartDate != null
                      ? '${customStartDate!.day.toString().padLeft(2, '0')}/${customStartDate!.month.toString().padLeft(2, '0')}/${customStartDate!.year}'
                      : 'DD/MM/AAAA',
                  style: TextStyle(
                    color: customStartDate != null
                        ? Colors.black
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('-'),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: customEndDate ?? DateTime.now(),
                  firstDate: customStartDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    customEndDate = date;
                  });
                  if (customStartDate != null) {
                    context.read<ExportarBloc>().add(
                      SelectCustomDateEvent(customStartDate!, date),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  customEndDate != null
                      ? '${customEndDate!.day.toString().padLeft(2, '0')}/${customEndDate!.month.toString().padLeft(2, '0')}/${customEndDate!.year}'
                      : 'DD/MM/AAAA',
                  style: TextStyle(
                    color: customEndDate != null
                        ? Colors.black
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
