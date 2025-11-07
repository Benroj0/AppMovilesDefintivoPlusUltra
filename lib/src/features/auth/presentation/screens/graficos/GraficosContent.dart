import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../historial/bloc/HistorialBloc.dart';
import '../historial/bloc/HistorialState.dart';
import '../categories/bloc/CategoriesBloc.dart';
import '../categories/bloc/CategoriesState.dart';

class GraficosContent extends StatefulWidget {
  const GraficosContent({super.key});

  @override
  State<GraficosContent> createState() => _GraficosContentState();
}

class _GraficosContentState extends State<GraficosContent> {
  bool showGastos = true; // Para alternar entre gastos e ingresos

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistorialBloc, HistorialState>(
      builder: (context, historialState) {
        return BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, categoriesState) {
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              height: double.infinity,
              width: double.infinity,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).iconTheme.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Gráficos',
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
                      const SizedBox(height: 24),

                      // Gráfico de Categorías
                      _buildCategoriesChart(
                        context,
                        historialState.historial,
                        categoriesState,
                      ),

                      const SizedBox(height: 24),

                      // Gráfico de Finanzas
                      _buildFinancesChart(context, historialState.historial),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesChart(
    BuildContext context,
    List<Map<String, dynamic>> historial,
    CategoriesState categoriesState,
  ) {
    return Card(
      elevation: 4,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorías',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 20),

            // Calcular gastos por categoría
            Builder(
              builder: (context) {
                Map<String, double> categoryTotals = {};

                for (var transaction in historial) {
                  if (transaction['descripcion'] == 'Gasto') {
                    String category = transaction['categoria'];
                    double amount = (transaction['monto'] as num).toDouble();
                    categoryTotals[category] =
                        (categoryTotals[category] ?? 0) + amount;
                  }
                }

                // Obtener el total máximo para calcular porcentajes
                double maxAmount = categoryTotals.values.isNotEmpty
                    ? categoryTotals.values.reduce(math.max)
                    : 0;

                if (categoryTotals.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay gastos registrados',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  );
                }

                return Column(
                  children: categoryTotals.entries.map((entry) {
                    // Buscar la categoría para obtener el color
                    Color categoryColor = Colors.orange;
                    try {
                      final category = categoriesState.allCategories.firstWhere(
                        (cat) => cat.name == entry.key,
                      );
                      categoryColor = category.color;
                    } catch (e) {
                      // Si no encuentra la categoría, usar color por defecto
                    }

                    return Column(
                      children: [
                        _buildCategoryBar(
                          context,
                          entry.key,
                          entry.value,
                          maxAmount,
                          categoryColor,
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // Leyenda con punto naranja
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Gastos por categoría',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Botón Revisar mis categorías
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a categorías
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Revisar mis categorías',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar(
    BuildContext context,
    String category,
    double value,
    double maxValue,
    Color color,
  ) {
    final percentage = value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              value.toInt().toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancesChart(
    BuildContext context,
    List<Map<String, dynamic>> historial,
  ) {
    return Card(
      elevation: 4,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finanzas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 20),

            // Tabs Gastos e Ingresos
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showGastos = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: showGastos
                                ? Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.color ??
                                      Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Gastos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: showGastos
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: showGastos
                              ? Theme.of(context).textTheme.titleLarge?.color
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showGastos = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !showGastos
                                ? Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.color ??
                                      Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Ingresos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: !showGastos
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: !showGastos
                              ? Theme.of(context).textTheme.titleLarge?.color
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Gráfico de dona dinámico
            Builder(
              builder: (context) {
                Map<String, double> data = {};
                String typeFilter = showGastos ? 'Gasto' : 'Ingreso';

                for (var transaction in historial) {
                  if (transaction['descripcion'] == typeFilter) {
                    String category = transaction['categoria'];
                    double amount = (transaction['monto'] as num).toDouble();
                    data[category] = (data[category] ?? 0) + amount;
                  }
                }

                if (data.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        showGastos
                            ? 'No hay gastos registrados'
                            : 'No hay ingresos registrados',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  );
                }

                return Center(
                  child: SizedBox(
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: DonutChartPainter(data: data),
                        ),
                        // Mostrar total en el centro
                        Text(
                          'Total\nS/ ${data.values.reduce((a, b) => a + b).toStringAsFixed(0)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                        // Etiquetas alrededor del gráfico
                        ...data.entries.toList().asMap().entries.map((entry) {
                          int index = entry.key;
                          MapEntry<String, double> dataEntry = entry.value;
                          double percentage =
                              (dataEntry.value /
                                  data.values.reduce((a, b) => a + b)) *
                              100;

                          // Calcular posición de la etiqueta
                          double angle =
                              (index / data.length) * 2 * math.pi - math.pi / 2;
                          double labelRadius = 130;
                          double x = 150 + labelRadius * math.cos(angle);
                          double y = 150 + labelRadius * math.sin(angle);

                          // Colores predefinidos
                          List<Color> colors = [
                            const Color(0xFF26A69A),
                            const Color(0xFF4FC3F7),
                            Colors.cyan[300]!,
                            Colors.orange,
                            Colors.purple,
                            Colors.green,
                            Colors.red,
                            Colors.blue,
                          ];

                          return Positioned(
                            left: x - 40,
                            top: y - 10,
                            child: _buildChartLabel(
                              '${dataEntry.key}\n${percentage.toStringAsFixed(1)}%',
                              colors[index % colors.length],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLabel(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<String, double> data;

  DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 30.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Calcular el total
    double total = data.values.reduce((a, b) => a + b);

    // Colores predefinidos para las categorías
    List<Color> colors = [
      const Color(0xFF26A69A),
      const Color(0xFF4FC3F7),
      Colors.cyan[300]!,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.blue,
    ];

    double startAngle = -math.pi / 2;
    int colorIndex = 0;

    // Dibujar cada segmento
    for (var entry in data.entries) {
      double percentage = entry.value / total;
      double sweepAngle = 2 * math.pi * percentage;

      paint.color = colors[colorIndex % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
