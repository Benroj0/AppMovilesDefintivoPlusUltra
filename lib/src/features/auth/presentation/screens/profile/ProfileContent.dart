import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/src/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/ProfileBloc.dart';
import 'bloc/ProfileState.dart';
import '../historial/HistorialPage.dart';
import '../exportar/ExportarPage.dart';
import '../graficos/GraficosPage.dart';
import '../../../../../color_theme/theme_bloc.dart';
import '../../../../../color_theme/theme_state.dart';
import '../../../../../color_theme/theme_event.dart';

class ProfileContent extends StatelessWidget {
  final VoidCallback? onBackPressed;
  const ProfileContent({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          height: double.infinity,
          width: double.infinity,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
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
                      // Header con flecha y título dentro del card
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print(
                                '🔙 ProfileContent: Botón Regresar presionado',
                              );
                              if (onBackPressed != null) {
                                print(
                                  '🔙 ProfileContent: Usando callback para cambiar pestaña',
                                );
                                // Si hay callback, lo usamos (para pestañas)
                                onBackPressed!();
                              } else {
                                print(
                                  '🔙 ProfileContent: Usando navegación normal',
                                );
                                // Si no hay callback, navegación normal (para pantallas apiladas)
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
                            'Perfil',
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

                      // Avatar EXACTO como la imagen
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4DB6AC),
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF87CEEB),
                                        Color(0xFFADD8E6),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4682B4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 45,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4DB6AC),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Información del usuario - exacta como la imagen
                      Center(
                        child: Text(
                          state.userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          state.userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Opciones del menú - EXACTAS como la imagen
                      _buildMenuOption(
                        icon: Icons.history,
                        title: 'Historial',
                        iconColor: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistorialPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildMenuOption(
                        icon: Icons.attach_money,
                        title: 'Moneda',
                        iconColor: const Color(0xFFFF9800),
                        onTap: () {},
                      ),

                      const SizedBox(height: 8),

                      _buildMenuOption(
                        icon: Icons.upload_file,
                        title: 'Exportar',
                        iconColor: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExportarPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildMenuOption(
                        icon: Icons.bar_chart,
                        title: 'Gráficos',
                        iconColor: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GraficosPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildMenuOption(
                        icon: Icons.notifications_outlined,
                        title: 'Recordatorios',
                        iconColor: const Color(0xFFFF9800),
                        onTap: () {},
                      ),

                      const SizedBox(height: 8),

                      _buildMenuOption(
                        icon: Icons.settings,
                        title: 'Ajustes',
                        iconColor: const Color(0xFFFF9800),
                        onTap: () {},
                      ),

                      const SizedBox(height: 8),

                      // Solo el botón de cambio de tema como en la imagen
                      BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, themeState) {
                          return _buildThemeToggleOption(
                            isDarkMode: themeState.isDarkMode,
                            onTap: () {
                              context.read<ThemeBloc>().add(
                                const ToggleTheme(),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Botón Salir - exacto como la imagen
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            print(
                              '🚪 ProfileContent: ===== BOTÓN SALIR PRESIONADO =====',
                            );

                            // Mostrar indicador de carga
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              // Paso 1: Ejecutar logout ultra robusto
                              print('🚪 ProfileContent: Ejecutando logout...');
                              await context.read<AuthCubit>().signOut();

                              // Paso 2: Espera adicional para asegurar logout
                              await Future.delayed(
                                const Duration(milliseconds: 1200),
                              );

                              // Paso 3: Verificar estado final
                              final currentState = context
                                  .read<AuthCubit>()
                                  .state;
                              print(
                                '🚪 ProfileContent: Estado final: $currentState',
                              );

                              // Cerrar diálogo de carga
                              if (context.mounted) Navigator.of(context).pop();

                              // Paso 4: REINICIO COMPLETO
                              print(
                                '🚪 ProfileContent: Reiniciando aplicación completamente...',
                              );
                              MyApp.restartApp();
                            } catch (e) {
                              print('❌ ProfileContent: ERROR en logout: $e');

                              // Cerrar diálogo de carga
                              if (context.mounted) Navigator.of(context).pop();

                              // Forzar reinicio de emergencia
                              print(
                                '🚨 ProfileContent: REINICIO DE EMERGENCIA',
                              );
                              MyApp.restartApp();
                            }
                          },
                          icon: const Icon(
                            Icons.exit_to_app,
                            color: Color(0xFFFF9800),
                            size: 18,
                          ),
                          label: const Text(
                            'Salir',
                            style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Material(
        borderRadius: BorderRadius.circular(25),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00ACC1), // Color teal exacto de la imagen
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFFF9800), // Naranja como en la imagen
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleOption({
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Material(
        borderRadius: BorderRadius.circular(25),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00ACC1), // Color teal exacto de la imagen
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: const Color(0xFFFF9800),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isDarkMode
                        ? const Color(0xFFFF9800)
                        : Colors.grey.shade400,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: isDarkMode
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
