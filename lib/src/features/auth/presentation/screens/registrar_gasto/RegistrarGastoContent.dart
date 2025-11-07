import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/registrar_gasto/bloc/RegistarGastoBloc.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/registrar_gasto/bloc/RegistrarGastoEvent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/registrar_gasto/bloc/RegistrarGastoState.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../categories/bloc/CategoriesBloc.dart';
import '../categories/bloc/CategoriesEvent.dart';
import '../categories/bloc/CategoriesState.dart';
import '../categories/CategoriesContent.dart';
import '../historial/bloc/HistorialBloc.dart';
import '../historial/bloc/HistorialEvent.dart';

class RegistrarGastoContent extends StatefulWidget {
  final bool isGastos;
  final VoidCallback? onBack;

  const RegistrarGastoContent({super.key, this.isGastos = true, this.onBack});

  @override
  State<RegistrarGastoContent> createState() => _RegistrarGastoContentState();
}

class _RegistrarGastoContentState extends State<RegistrarGastoContent> {
  final TextEditingController _montoController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Se ajustará en initState
  String? _selectedCategoryId;
  late bool isGastos; // Para controlar si es gasto o ingreso
  String _selectedCurrency = 'PEN'; // Moneda seleccionada por defecto
  final StorageService _storageService = StorageService();
  bool _showCategoryError = false; // Para mostrar error de categoría

  // Lista de monedas más usadas
  final List<Map<String, String>> currencies = [
    {'code': 'PEN', 'name': 'Sol Peruano', 'symbol': 'S/'},
    {'code': 'USD', 'name': 'Dólar Americano', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'Libra Esterlina', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Yen Japonés', 'symbol': '¥'},
    {'code': 'CAD', 'name': 'Dólar Canadiense', 'symbol': 'C\$'},
    {'code': 'AUD', 'name': 'Dólar Australiano', 'symbol': 'A\$'},
    {'code': 'CHF', 'name': 'Franco Suizo', 'symbol': 'CHF'},
    {'code': 'CNY', 'name': 'Yuan Chino', 'symbol': '¥'},
    {'code': 'MXN', 'name': 'Peso Mexicano', 'symbol': '\$'},
    {'code': 'BRL', 'name': 'Real Brasileño', 'symbol': 'R\$'},
    {'code': 'ARS', 'name': 'Peso Argentino', 'symbol': '\$'},
    {'code': 'CLP', 'name': 'Peso Chileno', 'symbol': '\$'},
    {'code': 'COP', 'name': 'Peso Colombiano', 'symbol': '\$'},
  ];

  @override
  void initState() {
    super.initState();
    isGastos = widget.isGastos;

    // Ajustar la fecha inicial al final del día para evitar problemas de zona horaria
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    print('=== INIT STATE DEBUG ===');
    print('Fecha inicial configurada: $_selectedDate');
    print('Es UTC: ${_selectedDate.isUtc}');
    print(
      'Día: ${_selectedDate.day}, Mes: ${_selectedDate.month}, Año: ${_selectedDate.year}',
    );
    print('========================');

    _montoController.addListener(() {
      context.read<RegistrarGastoBloc>().add(
        MontoChanged(_montoController.text),
      );
    });

    // Informar al BLoC de la fecha inicial
    context.read<RegistrarGastoBloc>().add(FechaChanged(_selectedDate));
    
    // 🔥 FORZAR CARGA DE CATEGORÍAS AL ENTRAR A ESTA PANTALLA
    // Esto asegura que las categorías del usuario actual estén cargadas
    print('===========================================');
    print('🚀🚀 REGISTRAR GASTO CONTENT: INIT STATE');
    print('🚀RegistrarGastoContent: Forzando carga de categorías para usuario actual');
    print('===========================================');
    context.read<CategoriesBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  // Categorías para gastos
  final List<Map<String, dynamic>> gastosCategories = [
    {'icon': '🍽️', 'name': 'Comida', 'color': Colors.orange},
    {'icon': '🏥', 'name': 'Salud', 'color': Colors.red},
    {'icon': '🚗', 'name': 'Transporte', 'color': Colors.blue},
    {'icon': '🏠', 'name': 'Hogar', 'color': Colors.purple},
  ];

  // Categorías para ingresos
  final List<Map<String, dynamic>> ingresosCategories = [
    {'icon': '💼', 'name': 'Salario', 'color': Colors.orange},
    {'icon': '🎁', 'name': 'Regalo', 'color': Colors.blue},
    {'icon': '💰', 'name': 'Interés', 'color': Colors.pink},
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      // Crear una fecha en hora local para mantener el día seleccionado
      final adjustedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        23, // 11 PM hora local para evitar que cambie al día anterior
        59,
        59,
      );

      print('=== FECHA SELECCIONADA ===');
      print('Fecha original del picker: $picked');
      print('Fecha ajustada: $adjustedDate');
      print(
        'Día seleccionado: ${adjustedDate.day}/${adjustedDate.month}/${adjustedDate.year}',
      );
      print('==========================');

      setState(() {
        _selectedDate = adjustedDate;
      });
      context.read<RegistrarGastoBloc>().add(FechaChanged(adjustedDate));
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar imagen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    onTap: () async {
                      Navigator.pop(context);
                      await _selectImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () async {
                      Navigator.pop(context);
                      await _selectImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal),
            ),
            child: Icon(icon, size: 32, color: Colors.teal),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _storageService.pickImage(source: source);
      if (pickedFile != null) {
        context.read<RegistrarGastoBloc>().add(ImagenSelected(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    context.read<RegistrarGastoBloc>().add(const ImagenRemoved());
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Seleccionar Moneda',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    final isSelected = currency['code'] == _selectedCurrency;

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.teal.withOpacity(0.2)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.teal
                                : Theme.of(context).dividerColor,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            currency['symbol']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.teal
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        currency['name']!,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.teal : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        currency['code']!,
                        style: TextStyle(
                          color: isSelected ? Colors.teal : Colors.grey,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.teal)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCurrency = currency['code']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryModal() async {
    final categoryType = isGastos ? CategoryType.gastos : CategoryType.ingresos;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<CategoriesBloc>(),
        child: CategoriesContent(categoryType: categoryType),
      ),
    );

    // Si se guardó exitosamente, actualizar la vista
    if (result == true) {
      setState(() {
        // La vista se actualizará automáticamente por el BlocBuilder
      });
    }
  }

  void _showDeleteCategoryDialog(Category category) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la categoría "${category.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CategoriesBloc>().add(
                RemoveCategoryEvent(category.id),
              );
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Verificando eliminación...'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrarGastoBloc, RegistrarGastoState>(
      listener: (context, state) {
        if (state.error != null) {
          // 1. Manejar errores
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );

          // Mostrar error visual si es de categoría
          if (state.error!.contains("categoría")) {
            setState(() {
              _showCategoryError = true;
            });
            // Ocultar el error visual después de un tiempo
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showCategoryError = false;
                });
              }
            });
          }
        }

        if (state.exito) {
          // 2. Manejar éxito
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isGastos ? "Gasto guardado" : "Ingreso guardado"),
              backgroundColor: Colors.green,
            ),
          );

          // 2.1. Recargar el historial para incluir los nuevos datos con imageUrl
          context.read<HistorialBloc>().add(const LoadHistorial());

          // 3. Limpiar el formulario y cerrar
          _montoController.clear();
          setState(() {
            _selectedCategoryId = null;
            // Resetear fecha al final del día actual
            final now = DateTime.now();
            _selectedDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
            _showCategoryError = false; // Limpiar error visual
          });
          //Navigator.pop(context); // Cierra la pantalla de registro
        }
      },
      child: BlocListener<CategoriesBloc, CategoriesState>(
        listener: (context, categoriesState) {
          if (categoriesState.error != null &&
              categoriesState.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(categoriesState.error!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, categoriesState) {
            // Filtrar categorías por tipo (gastos o ingresos)
            final categoryType = isGastos
                ? CategoryType.gastos
                : CategoryType.ingresos;
            final filteredCategories = categoriesState.getCategoriesByType(
              categoryType,
            );

            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              height: double.infinity,
              width: double.infinity,
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con flecha y título
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (widget.onBack != null) {
                                    widget.onBack!();
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                isGastos ? 'Agregar Gasto' : 'Agregar Ingreso',
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

                          // Monto
                          Row(
                            children: [
                              Text(
                                "Monto:",
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
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _montoController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _showCurrencyPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.teal,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedCurrency,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.teal,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Categorías
                          Row(
                            children: [
                              Text(
                                "Categorías:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              if (_selectedCategoryId == null ||
                                  _showCategoryError)
                                Text(
                                  " *",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Mensaje de error si no hay categoría seleccionada
                          if (_showCategoryError)
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Por favor, selecciona una categoría",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Grid de categorías
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              ...filteredCategories.map((category) {
                                final isSelected =
                                    _selectedCategoryId == category.id;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = category.id;
                                      _showCategoryError =
                                          false; // Limpiar error al seleccionar categoría
                                    });
                                    context.read<RegistrarGastoBloc>().add(
                                      CategoriaChanged(
                                        idCategoria: category.id,
                                        nombreCategoria: category.name,
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? category.color.withOpacity(0.8)
                                              : category.color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                  color: category.color,
                                                  width: 2,
                                                )
                                              : Border.all(
                                                  color: Theme.of(
                                                    context,
                                                  ).dividerColor,
                                                  width: 1,
                                                ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              category.icon,
                                              size: 24,
                                              color: isSelected
                                                  ? Colors.white
                                                  : category.color,
                                            ),
                                            const SizedBox(height: 2),
                                            Flexible(
                                              child: Text(
                                                category.name,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Botón de eliminar solo para categorías personalizadas
                                      if (!category.isDefault)
                                        Positioned(
                                          top: -5,
                                          right: -5,
                                          child: GestureDetector(
                                            onTap: () {
                                              print(
                                                '=== BOTÓN ELIMINAR CLICKEADO ===',
                                              );
                                              print(
                                                'Categoría: ${category.name} (ID: ${category.id})',
                                              );
                                              print(
                                                'Es default: ${category.isDefault}',
                                              );
                                              _showDeleteCategoryDialog(
                                                category,
                                              );
                                            },
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              // Botón "Más"
                              GestureDetector(
                                onTap: _showAddCategoryModal,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 24,
                                        color: Theme.of(
                                          context,
                                        ).iconTheme.color,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Más',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Fecha
                          Row(
                            children: [
                              Text(
                                "Fecha:",
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
                                  onTap: _pickDate,
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Evidencia (solo para gastos)
                          if (isGastos) ...[
                            Text(
                              "Evidencia:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<
                              RegistrarGastoBloc,
                              RegistrarGastoState
                            >(
                              builder: (context, state) {
                                if (state.subiendoImagen) {
                                  return Container(
                                    width: double.infinity,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.teal,
                                        ),
                                        SizedBox(height: 8),
                                        Text('Subiendo imagen...'),
                                      ],
                                    ),
                                  );
                                }

                                if (state.imagePath != null) {
                                  return Container(
                                    width: double.infinity,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.teal,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.file(
                                            File(state.imagePath!),
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: _removeImage,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: double.infinity,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 32,
                                          color: Theme.of(
                                            context,
                                          ).iconTheme.color,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Agregar Imagen',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                          ] else ...[
                            const SizedBox(height: 32),
                          ],

                          // Botón Guardar
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child:
                                BlocBuilder<
                                  RegistrarGastoBloc,
                                  RegistrarGastoState
                                >(
                                  builder: (context, state) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      onPressed: state.guardando
                                          ? null
                                          : () {
                                              context
                                                  .read<RegistrarGastoBloc>()
                                                  .add(
                                                    GastoSubmitted(
                                                      isGasto: isGastos,
                                                    ),
                                                  );
                                            },
                                      child: state.guardando
                                          ? const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            )
                                          : Text(
                                              "Guardar",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
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
            );
          },
        ),
      ),
    );
  }
}
