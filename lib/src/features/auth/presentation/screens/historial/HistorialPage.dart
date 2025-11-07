import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/constants/app_colors.dart';
import 'package:flutter_application_1/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'HistorialContent.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  int _selectedIndex = 0; // Cambio a 0 para que no interfiera

  void _showFloatingOptions(BuildContext context) {
    print("Mostrando modal flotante"); // Debug
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
                        print("Botón Gastos presionado"); // Debug
                        Navigator.of(context).pop();
                        // Navegar al dashboard principal con gastos
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DashboardScreen(initialIndex: 0),
                          ),
                        );
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
                        print("Botón Ingresos presionado"); // Debug
                        Navigator.of(context).pop();
                        // Navegar al dashboard principal con ingresos
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DashboardScreen(initialIndex: 0),
                          ),
                        );
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
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8), // Fondo verde consistente
      body: const SafeArea(child: HistorialContent()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          print("Botón presionado: $index"); // Debug
          if (index == 1) {
            print("Mostrando modal"); // Debug
            // Mostrar modal de opciones para registrar
            _showFloatingOptions(context);
          } else if (index == 0) {
            print("Navegando al inicio"); // Debug
            // Navegar al dashboard principal
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(initialIndex: 0),
              ),
            );
          } else if (index == 2) {
            print("Navegando al perfil"); // Debug
            // Navegar al dashboard con el perfil seleccionado
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(initialIndex: 2),
              ),
            );
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
