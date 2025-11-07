import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/src/constants/app_colors.dart';
import '../categories/bloc/CategoriesBloc.dart';
import '../categories/bloc/CategoriesState.dart';
import '../../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'TransactionDetailPage.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;
  final bool isGastos;

  const CategoryDetailPage({
    super.key,
    required this.categoryName,
    required this.isGastos,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  String _getCategoryNameFromDoc(
    Map<String, dynamic> data,
    CategoriesState categoriesState,
  ) {
    // Si tiene id_categoria, buscar el nombre en categoriesState
    if (data['id_categoria'] != null) {
      final category = categoriesState.allCategories.firstWhere(
        (cat) => cat.id == data['id_categoria'],
        orElse: () => categoriesState.allCategories.firstWhere(
          (cat) => cat.name.toLowerCase() == widget.categoryName.toLowerCase(),
          orElse: () => categoriesState.allCategories.first,
        ),
      );
      return category.name;
    }

    // Si no tiene id_categoria, usar la descripcion directamente
    return data['descripcion'] ?? 'Sin categoría';
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, categoriesState) {
            // Buscar la categoría para obtener el color e ícono
            final category = categoriesState.allCategories.firstWhere(
              (cat) =>
                  cat.name.toLowerCase() == widget.categoryName.toLowerCase(),
              orElse: () => categoriesState.allCategories.first,
            );

            return StreamBuilder<QuerySnapshot>(
              stream: widget.isGastos
                  ? firestoreService.obtenerGastosStream()
                  : firestoreService.obtenerIngresosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Filtrar transacciones para esta categoría
                final allTransactions = snapshot.data?.docs ?? [];
                final filteredTransactions = allTransactions.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final docCategoryName = _getCategoryNameFromDoc(
                    data,
                    categoriesState,
                  );
                  return docCategoryName.toLowerCase() ==
                      widget.categoryName.toLowerCase();
                }).toList();

                // Calcular el total
                double totalAmount = 0.0;
                for (final doc in filteredTransactions) {
                  final data = doc.data() as Map<String, dynamic>;
                  totalAmount += (data['importe'] ?? 0.0).toDouble();
                }

                return Column(
                  children: [
                    // Header con botón de retroceso
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DashboardScreen(initialIndex: 0),
                              ),
                            ),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).iconTheme.color,
                              size: 24,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.categoryName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ), // Para balancear el botón de retroceso
                        ],
                      ),
                    ),

                    // Card principal con total
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.categoryName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'S/ ${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista de transacciones
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: filteredTransactions.isEmpty
                            ? Center(
                                child: Text(
                                  'No hay ${widget.isGastos ? 'gastos' : 'ingresos'} registrados para ${widget.categoryName}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  final docSnapshot =
                                      filteredTransactions[index];
                                  final transactionData =
                                      docSnapshot.data()
                                          as Map<String, dynamic>;
                                  final date =
                                      (transactionData['fecha'] as Timestamp?)
                                          ?.toDate() ??
                                      DateTime.now();

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TransactionDetailPage(
                                            transaction: {
                                              'categoria': widget.categoryName,
                                              'monto':
                                                  (transactionData['importe'] ??
                                                          0.0)
                                                      .toDouble(),
                                              'descripcion': widget.isGastos
                                                  ? 'Gasto'
                                                  : 'Ingreso',
                                              'fecha': date,
                                              'imageUrl': widget.isGastos
                                                  ? transactionData['url_archivo']
                                                  : null, // Los ingresos no tienen imagen
                                            },
                                            category: category,
                                            isGastos: widget.isGastos,
                                            transactionId: docSnapshot
                                                .id, // Agregamos el ID del documento
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Fecha
                                          Text(
                                            '${date.day} de ${_getMonthName(date.month)} de ${date.year}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // Categoría y monto
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: category.color
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  category.icon,
                                                  color: category.color,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.categoryName,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Principal',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                'S/ ${(transactionData['importe'] ?? 0.0).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            // Mostrar modal de opciones
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(initialIndex: 2),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(initialIndex: 0),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }
}
