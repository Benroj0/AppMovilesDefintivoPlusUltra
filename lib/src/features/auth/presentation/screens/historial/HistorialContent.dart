import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../categories/bloc/CategoriesBloc.dart';
import '../categories/bloc/CategoriesEvent.dart';
import '../categories/bloc/CategoriesState.dart';
import '../../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'bloc/HistorialBloc.dart';
import 'bloc/HistorialEvent.dart';
import 'bloc/HistorialState.dart';

class HistorialContent extends StatefulWidget {
  const HistorialContent({super.key});

  @override
  State<HistorialContent> createState() => _HistorialContentState();
}

class _HistorialContentState extends State<HistorialContent> {
  DateTime? _selectedDate;
  String? _selectedCategory;
  String _selectedType = 'Tipo';

  List<Map<String, dynamic>> _filteredHistorial = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Cargar categorías e historial al inicializar
    context.read<CategoriesBloc>().add(LoadCategoriesEvent());
    context.read<HistorialBloc>().add(const LoadHistorial());
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> _getCategories(List<Category> allCategories) {
    // Si no hay tipo seleccionado o es "Tipo", mostrar todas las categorías
    if (_selectedType == 'Tipo') {
      return [
        'Todas',
        ...allCategories.map((category) => category.name).toList(),
      ];
    }

    // Filtrar categorías según el tipo seleccionado
    CategoryType filterType = _selectedType == 'Gastos'
        ? CategoryType.gastos
        : CategoryType.ingresos;

    List<Category> filteredCategories = allCategories
        .where((category) => category.type == filterType)
        .toList();

    return [
      'Todas',
      ...filteredCategories.map((category) => category.name).toList(),
    ];
  }

  final List<String> _types = ['Tipo', 'Gastos', 'Ingresos'];

  // Función para filtrar el historial según los criterios seleccionados
  List<Map<String, dynamic>> _filterHistorial(
    List<Map<String, dynamic>> allHistorial,
  ) {
    List<Map<String, dynamic>> filtered = List.from(allHistorial);

    // Filtrar por categoría
    if (_selectedCategory != null &&
        _selectedCategory != 'Categoría' &&
        _selectedCategory != 'Todas') {
      filtered = filtered
          .where((item) => item['categoria'] == _selectedCategory)
          .toList();
    }

    // Filtrar por tipo
    if (_selectedType != 'Tipo') {
      String typeFilter = _selectedType == 'Gastos' ? 'Gasto' : 'Ingreso';
      filtered = filtered
          .where((item) => item['descripcion'] == typeFilter)
          .toList();
    }

    // Filtrar por fecha
    if (_selectedDate != null) {
      filtered = filtered.where((item) {
        DateTime itemDate = item['fecha'];
        return itemDate.year == _selectedDate!.year &&
            itemDate.month == _selectedDate!.month &&
            itemDate.day == _selectedDate!.day;
      }).toList();
    }

    return filtered;
  }

  // Función para ejecutar la búsqueda
  void _performSearch(List<Map<String, dynamic>> allHistorial) {
    setState(() {
      _filteredHistorial = _filterHistorial(allHistorial);
      _hasSearched = true;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, categoriesState) {
        return BlocBuilder<HistorialBloc, HistorialState>(
          builder: (context, historialState) {
            final categories = _getCategories(categoriesState.allCategories);
            final displayHistorial = _hasSearched
                ? _filteredHistorial
                : historialState.historial;

            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                child: Column(
                  children: [
                    // Header con flecha y título
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Historial',
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
                          // Botón de perfil en el header
                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DashboardScreen(initialIndex: 2),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.person,
                              color: Theme.of(context).iconTheme.color,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contenido principal
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: Card(
                          elevation: 8,
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Filtros
                                Row(
                                  children: [
                                    // Filtro de Fecha
                                    Text(
                                      'Fecha:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _selectDate,
                                        child: Container(
                                          height: 40,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Theme.of(
                                                context,
                                              ).dividerColor,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _selectedDate != null
                                                    ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
                                                    : 'DD/MM/AAAA',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Filtro de Categoría y Tipo - Layout en columna para evitar overflow
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Labels para Categoría y Tipo
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Categoría:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Tipo:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Selector de Categoría
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).dividerColor,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _selectedCategory,
                                                hint: const Text(
                                                  'Todas',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                items: categories.map((
                                                  String category,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: category,
                                                    child: Text(
                                                      category,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _selectedCategory =
                                                        newValue;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Selector de Tipo
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).dividerColor,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _selectedType,
                                                items: _types.map((
                                                  String type,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: type,
                                                    child: Text(
                                                      type,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _selectedType =
                                                        newValue ?? 'Tipo';
                                                    // Resetear categoría seleccionada cuando cambie el tipo
                                                    _selectedCategory = null;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Botón Buscar
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Ejecutar búsqueda con los filtros seleccionados
                                      _performSearch(historialState.historial);
                                    },
                                    child: const Text(
                                      'Buscar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Header de la tabla
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Categoría',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Monto',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Lista de transacciones
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: displayHistorial.length,
                                    itemBuilder: (context, index) {
                                      final item = displayHistorial[index];

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).dividerColor,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                item['categoria'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              flex: 1,
                                              child: Text(
                                                'S/ ${item['monto'].toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium?.color,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
