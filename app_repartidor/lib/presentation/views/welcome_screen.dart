import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_repartidor/presentation/widgets/custom_drawer.dart'; // Importación necesaria
import '../../utils/enums.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Definimos el tamaño para el lado del cuadrado
    const double buttonSize = 140.0;
    // Espacio entre los botones
    const double spacing = 40.0;

    return Scaffold(
      drawer: const CustomDrawer(role: UserRole.public),
      appBar: AppBar(
        title: const Text('Bienvenido'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Título de la Aplicación
                Text(
                  'LuckZ Entregazz',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),

                // LOGO DE LA EMPRESA
                Image.asset(
                  'assets/images/logo.png',
                  width: 195,
                ),
                const SizedBox(height: 20),

                Text(
                  'Tu zoluzión de entregazz rápidazz.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // 💡 CONTENEDOR DE BOTONES CUADRADOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- 1. BOTÓN INICIAR SESIÓN (ELEVATED BUTTON CUADRADO) ---
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero, // Quitamos padding interno
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 50), // Icono grande
                            SizedBox(height: 8),
                            Text(
                              'INICIAR',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'SESIÓN',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 💡 SEPARACIÓN ENTRE BOTONES
                    const SizedBox(width: spacing),

                    // --- 2. BOTÓN REGISTRARSE (OUTLINED BUTTON CUADRADO) ---
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary, width: 2), // Borde más grueso
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero, // Quitamos padding interno
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_alt_1, size: 50), // Icono grande
                            SizedBox(height: 8),
                            Text(
                              'REGISTRARSE',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}