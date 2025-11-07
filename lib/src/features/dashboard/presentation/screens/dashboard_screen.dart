import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/inicio/InicioContent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/registrar_gasto/RegistrarGastoContent.dart';
import 'package:flutter_application_1/src/features/auth/presentation/screens/profile/ProfilePage.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;
  Widget? _currentRegistroView;
  User? _usuarioActual;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _usuarioActual = FirebaseAuth.instance.currentUser;
  }

  List<Widget> _buildWidgetOptions() {
    return <Widget>[
      InicioContent(usuario: _usuarioActual),
      Container(),
      ProfilePage(
        usuario: _usuarioActual,
        onBackPressed: () {
          setState(() {
            _selectedIndex = 0; // Regresar a la pestaña Home (índice 0)
          });
        },
      ),
    ];
  }

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
              bottom: 100,
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
                                _selectedIndex = 0;
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
                          color: Theme.of(context).primaryColor,
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
                            key: const ValueKey(
                              'ingresos',
                            ), // Key único para forzar reconstrucción
                            isGastos: false,
                            onBack: () {
                              setState(() {
                                _currentRegistroView = null;
                                _selectedIndex = 0;
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
                          color: Theme.of(context).primaryColor,
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
      final _widgetOptions = _buildWidgetOptions();
      if (_selectedIndex >= 0 && _selectedIndex < _widgetOptions.length) {
        currentView = _widgetOptions.elementAt(_selectedIndex);
      } else {
        currentView = _widgetOptions.first;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            // Siempre mostrar el modal de opciones, sin importar el estado actual
            _showFloatingOptions(context);
          } else {
            setState(() {
              _selectedIndex = index;
              _currentRegistroView = null; // Limpiar vista de registro
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.unselectedItemColor,
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
