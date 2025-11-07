import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/constants/app_colors.dart';
import 'package:flutter_application_1/src/domain/models/gasto_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../categories/bloc/CategoriesBloc.dart';
import '../categories/bloc/CategoriesEvent.dart';
import '../categories/bloc/CategoriesState.dart';
import '../category_detail/CategoryDetailPage.dart';

class InicioContent extends StatefulWidget {
  final User? usuario;
  const InicioContent({super.key, this.usuario});

  @override
  State<InicioContent> createState() => _InicioContentState();
}

class _InicioContentState extends State<InicioContent> {
  bool isGastosSelected = true;

  // Límite de gastos (puedes hacer esto configurable más adelante)
  final double limitAmount = 500.00;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Función para calcular el total de gastos o ingresos
  double _getTotalAmount(List<Gasto> gastos) {
    return gastos.fold(0.0, (sum, gasto) => sum + gasto.importe);
  }

  // Función para obtener datos dinámicos de categorías con totales por categoría
  List<Map<String, dynamic>> _getCategoryData(
    CategoryType type,
    List<Category> categories,
    List<Gasto> gastos,
  ) {
    if (type != CategoryType.gastos) return [];
    // Crear un mapa para agrupar por categoría
    Map<String, double> categoryTotals = {};
    Map<String, Category> categoryInfo = {};

    // Inicializar todas las categorías del tipo específico
    for (Category category in categories.where(
      (c) => c.type == CategoryType.gastos,
    )) {
      categoryTotals[category.id] = 0.0;
      categoryInfo[category.id] = category;
    }
    for (Gasto gasto in gastos) {
      if (categoryTotals.containsKey(gasto.idCategoria)) {
        categoryTotals[gasto.idCategoria] =
            categoryTotals[gasto.idCategoria]! + gasto.importe;
      }
    }
    // Sumar los montos por categoría

    // Convertir a lista de mapas y solo incluir categorías con monto > 0
    return categoryTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          final category = categoryInfo[entry.key];
          if (category == null) return null;
          return {
            'id': category.id,
            'icon': category.icon,
            'category': category.name,
            'amount': entry.value,
            'color': category.color,
          };
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, categoriesState) {
        if (categoriesState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        // Nota: Los errores se manejan en las pantallas donde se originan (RegistrarGastoContent)
        // No mostramos errores en la vista del inicio para evitar interferir con la navegación

        final List<Category> allCategories = categoriesState.allCategories;

        return StreamBuilder<QuerySnapshot>(
          stream: isGastosSelected
              ? firestoreService.obtenerGastosStream()
              : firestoreService.obtenerIngresosStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<Map<String, dynamic>> currentData = [];
            double totalAmount = 0.0;

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              if (isGastosSelected) {
                // Procesar gastos
                final gastos = snapshot.data!.docs
                    .map((doc) => Gasto.fromSnapshot(doc))
                    .toList();
                totalAmount = _getTotalAmount(gastos);
                currentData = _getCategoryData(
                  CategoryType.gastos,
                  allCategories,
                  gastos,
                );
              } else {
                // Procesar ingresos - lógica híbrida para compatibilidad
                final ingresos = snapshot.data!.docs;
                Map<String, double> categoryTotals = {};
                Map<String, Category> categoryInfo = {};
                Map<String, double> conceptTotals =
                    {}; // Para ingresos antiguos por concepto

                // Inicializar categorías de ingresos
                for (Category category in allCategories.where(
                  (c) => c.type == CategoryType.ingresos,
                )) {
                  categoryTotals[category.id] = 0.0;
                  categoryInfo[category.id] = category;
                }

                for (var doc in ingresos) {
                  final data = doc.data() as Map<String, dynamic>;
                  final categoriaId = data['id_categoria'];
                  final concepto = data['concepto'] ?? 'Sin concepto';
                  final importe = (data['importe'] ?? 0.0).toDouble();
                  totalAmount += importe;

                  if (categoriaId != null &&
                      categoryTotals.containsKey(categoriaId)) {
                    // Ingreso con categoría personalizada
                    categoryTotals[categoriaId] =
                        categoryTotals[categoriaId]! + importe;
                  } else {
                    // Ingreso por concepto (sistema anterior)
                    conceptTotals[concepto] =
                        (conceptTotals[concepto] ?? 0.0) + importe;
                  }
                }

                // Crear lista combinando categorías personalizadas e ingresos por concepto
                List<Map<String, dynamic>> categoryData = categoryTotals.entries
                    .where((entry) => entry.value > 0)
                    .map((entry) {
                      final category = categoryInfo[entry.key];
                      if (category == null) return null;
                      return {
                        'id': category.id,
                        'icon': category.icon,
                        'category': category.name,
                        'amount': entry.value,
                        'color': category.color,
                      };
                    })
                    .where((item) => item != null)
                    .cast<Map<String, dynamic>>()
                    .toList();

                // Agregar ingresos por concepto (sistema anterior)
                List<Map<String, dynamic>>
                conceptData = conceptTotals.entries.map((entry) {
                  return {
                    'id': entry.key,
                    'icon': Icons
                        .monetization_on, // Ícono por defecto para ingresos antiguos
                    'category': entry.key,
                    'amount': entry.value,
                    'color': Colors.green,
                  };
                }).toList();

                currentData = [...categoryData, ...conceptData];
              }
            }

            final double progressValue = isGastosSelected
                ? (limitAmount > 0)
                      ? (totalAmount / limitAmount).clamp(0.0, 1.0)
                      : 0.0
                : 0.0;

            final double metaIngresos = 1000.00; // Meta de ingresos mensual
            final double progressIngresos = isGastosSelected
                ? 0.0
                : totalAmount / metaIngresos;

            return Container(
              color: const Color(
                0xFFE8F5E8,
              ), // Mismo fondo verde claro del perfil
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 8,
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mostrar sección Total solo si es vista de Gastos
                          if (isGastosSelected) ...[
                            // Sección Total
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'S/ ${totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Límite de Gastos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Barra de progreso - más pequeña con padding horizontal
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  child: Container(
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: Theme.of(
                                              context,
                                            ).dividerColor,
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: progressValue > 1.0
                                              ? 1.0
                                              : progressValue,
                                          child: Container(
                                            height: 16,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Indicadores centrados y más juntos
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 60,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Gastos',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).dividerColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Disponible',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ],

                          // Si es vista de Ingresos, mostrar sección de Ingresos
                          if (!isGastosSelected) ...[
                            // Sección Total de Ingresos
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.trending_up,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Total Ingresos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                //
                                const SizedBox(height: 20),
                                const Text(
                                  'Meta de Ingresos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Barra de progreso - más pequeña con padding horizontal
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  child: Container(
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: Theme.of(
                                              context,
                                            ).dividerColor,
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: progressIngresos > 1.0
                                              ? 1.0
                                              : progressIngresos,
                                          child: Container(
                                            height: 16,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Indicadores centrados y más juntos
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 60,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Ingresos',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).dividerColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Meta',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ],

                          // Toggle Gastos/Ingresos
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isGastosSelected = true;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'Gastos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isGastosSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 2,
                                      width: 60,
                                      color: isGastosSelected
                                          ? Colors.black
                                          : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isGastosSelected = false;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'Ingresos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: !isGastosSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 2,
                                      width: 60,
                                      color: !isGastosSelected
                                          ? Colors.black
                                          : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Mostrar título "Transacciones" solo en vista de Gastos
                          if (isGastosSelected) ...[
                            Text(
                              'Transacciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Header de categorías
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          // Lista de categorías
                          if (currentData.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: Center(
                                child: Text(
                                  isGastosSelected
                                      ? 'No hay gastos aún.'
                                      : 'No hay ingresos aún.',
                                ),
                              ),
                            )
                          else
                            ...currentData.map((item) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryDetailPage(
                                        categoryName: item['category'],
                                        isGastos: isGastosSelected,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: item['color'].withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            item['icon'],
                                            color: item['color'],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item['category'],
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
                                      Text(
                                        'S/ ${item['amount'].toStringAsFixed(2)}',
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
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
