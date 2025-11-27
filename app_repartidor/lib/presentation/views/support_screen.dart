import 'package:app_repartidor/config/app_theme.dart';
import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // Estado para controlar si el Modo Veloz está activado
  bool _isSpeedModeActive = false;

  // Función para manejar el retroceso
  void _popScreen() {
    // Si la pantalla es el 'home' no se puede hacer pop, pero en un flujo de navegación normal sí.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // Función para manejar el botón de emergencia (simulación)
  void _sendEmergencyAlert() {
    // Lógica real: Aquí se notificaría al servidor o se enviaría el email de emergencia
    // Por simplicidad, solo mostramos un SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 Alerta de Socorro Enviada al Manager y a Emergencias.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Muestra una ventana emergente (AlertDialog)
  void _showStatusModal(String title, String content, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          content: Text(content, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          actions: <Widget>[
            TextButton(
              child: const Text('Entendido', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Función para alternar el Modo Veloz
  void _toggleSpeedMode() {
    setState(() {
      _isSpeedModeActive = !_isSpeedModeActive;
    });

    if (_isSpeedModeActive) {
      _showStatusModal(
        'Modo Super Veloz Activado',
        'Tu velocidad de procesamiento ha sido optimizada. ¡A rodar!',
        Colors.greenAccent.shade400, // Color para ACTIVADO
      );
    } else {
      _showStatusModal(
        'Modo Super Veloz Desactivado',
        'Volviendo a la configuración estándar.',
        Colors.amber.shade400, // Color para DESACTIVADO
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Colores basados en el estado
    final speedButtonColor = _isSpeedModeActive ? Colors.deepPurple.shade700 : Colors.teal.shade500;
    final speedButtonLabel = _isSpeedModeActive ? 'Desactivar Modo Veloz' : 'Activar Modo Veloz';
    final speedButtonIcon = _isSpeedModeActive ? Icons.flash_off : Icons.rocket_launch;

    // Color para el contraste en la AppBar
    final appBarTextColor = theme.colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        // Fondo Ámbar (secondary, según el tema)
        backgroundColor: theme.colorScheme.secondary,

        // Letras e Íconos
        foregroundColor: appBarTextColor,

        // Deshabilitar la flecha automática
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Ícono de retroceso manual
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _popScreen,
              tooltip: 'Volver a la pantalla anterior',
            ),
            // Título de la pantalla
            const Text(
              'Soporte y Emergencias',
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // --- DEBUG VISUAL: Si ves este contenedor, el problema es el botón.
                // Si no lo ves, algo está crashando el Column.
                Container(
                  height: 10,
                  width: double.infinity,
                  color: Colors.pinkAccent,
                ),
                const SizedBox(height: 16),

                // --- 1. Botón de Modo Veloz ---
                ElevatedButton.icon(
                  onPressed: _toggleSpeedMode,
                  icon: Icon(speedButtonIcon, size: 24),
                  label: Text(
                    speedButtonLabel,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: speedButtonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 8,
                  ),
                ),
                const SizedBox(height: 40),

                // --- 2. Sección de Emergencia ---
                const Icon(
                  Icons.report_problem,
                  color: Colors.amber, // Corregido para usar Colors.amber, no la constante
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  '¿Necesitas Ayuda Inmediata?',
                  // Aseguramos que el texto sea blanco o contraste en fondo oscuro
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Si estás en una situación de riesgo o necesitas asistencia urgente, usa el botón de socorro. Esto notificará a los managers de inmediato.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                // Botón de Socorro Grande y Llamativo
                ElevatedButton.icon(
                  onPressed: _sendEmergencyAlert,
                  icon: const Icon(Icons.sos_outlined, size: 30),
                  label: const Text(
                    'BOTÓN DE SOCORRO',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    // Lógica para contactar soporte no urgente
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Llamando a soporte no urgente...')),
                    );
                  },
                  child: Text(
                    'Soporte no urgente',
                    style: TextStyle(color: theme.colorScheme.secondary),
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