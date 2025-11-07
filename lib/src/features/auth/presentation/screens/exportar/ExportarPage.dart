import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/constants/app_colors.dart';
import 'ExportarContent.dart';
import '../registrar_gasto/RegistrarGastoContent.dart';

class ExportarPage extends StatefulWidget {
  const ExportarPage({super.key});

  @override
  State<ExportarPage> createState() => _ExportarPageState();
}

class _ExportarPageState extends State<ExportarPage> {
  int _selectedIndex = 2; // Inicializar en perfil ya que venimos del perfil
  Widget? _currentRegistroView;

  void _showFloatingOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Toque fuera del modal para cerrar
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Modal flotante
            Positioned(
              bottom: 100, // Encima del bottom navigation
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón Gastos
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedIndex = 1;
                          _currentRegistroView = RegistrarGastoContent(
                            key: const ValueKey('gastos'),
                            isGastos: true,
                            onBack: () {
                              setState(() {
                                _currentRegistroView = null;
                                _selectedIndex = 2; // Volver a exportar
                              });
                            },
                          );
                        });
                      },
                      child: Container(
                        width: 200,
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_down,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Gastos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón Ingresos
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedIndex = 1;
                          _currentRegistroView = RegistrarGastoContent(
                            key: const ValueKey('ingresos'),
                            isGastos: false,
                            onBack: () {
                              setState(() {
                                _currentRegistroView = null;
                                _selectedIndex = 2; // Volver a exportar
                              });
                            },
                          );
                        });
                      },
                      child: Container(
                        width: 200,
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Ingresos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;

    // Determinar qué vista mostrar
    if (_selectedIndex == 1 && _currentRegistroView != null) {
      currentView = _currentRegistroView!;
    } else {
      // Solo mostramos la vista de exportar
      currentView = ExportarContent(
        onBack: () {
          Navigator.pop(context);
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: currentView,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentRegistroView != null ? 1 : _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Mostrar el modal de opciones
            _showFloatingOptions(context);
          } else if (index == 0) {
            // Ir al dashboard principal
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            // Quedarse en exportar o ir al perfil
            setState(() {
              _selectedIndex = index;
              _currentRegistroView = null;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
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
}
