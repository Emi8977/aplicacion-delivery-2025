import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Importación necesaria para acceder a la constante supportEmail
import 'package:app_repartidor/data/email_service.dart';

import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  final String currentUserName;
  final String currentUserMail;

  const SettingsScreen({
    super.key,
    required this.currentUserName,
    required this.currentUserMail,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _messageController = TextEditingController();

  // --- ESTADO Y LÓGICA DEL MODO VELOZ ---
  bool _isSpeedModeActive = false;

  // Muestra una ventana emergente (AlertDialog)
  void _showStatusModal(String title, String content, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Usar el esquema de colores del tema
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          content: Text(content, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          actions: <Widget>[
            TextButton(
              // Usamos el color de acento para el texto del botón
              child: Text('Entendido', style: TextStyle(color: color)),
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
        'Modo ZZuper VeloZzz Activado',
        'Tu veloZzidad de proZzezamiento ha Zzido optimiZzada. ¡A trabajar eZclavo, digo MI MEJOR empleado!',
        Colors.greenAccent.shade400, // Color para ACTIVADO
      );
    } else {
      _showStatusModal(
        'Modo Zzuper VeloZz DeZzactivado.',
        'Volviendo a la configuraZión normal. Que aburrido Zzzz',
        Colors.amber.shade400, // Color para DESACTIVADO
      );
    }
  }
  // --- FIN LÓGICA MODO VELOZ ---

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendEmergency(BuildContext context) {
    context.read<SettingsBloc>().add(
      SendEmergencyRequested(
        message: _messageController.text.trim().isEmpty
            ? 'Alerta de emergencia sin mensaje adicional.'
            : _messageController.text.trim(),
        senderName: widget.currentUserName,
        senderMail: widget.currentUserMail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Variables del botón Modo Veloz
    final speedButtonColor = _isSpeedModeActive ? Colors.deepPurple.shade700 : Colors.teal.shade500;
    final speedButtonLabel = _isSpeedModeActive ? 'Desactivar Modo VeloZz' : 'Activar Modo VeloZz';
    final speedButtonIcon = _isSpeedModeActive ? Icons.flash_off : Icons.rocket_launch;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración y Ayuda'),
        // --- CAMBIO DE COLOR ---
        // Usamos el color secundario (Ámbar) para el fondo
        backgroundColor: theme.colorScheme.secondary,
        // Usamos el color onPrimary (Negro) para el texto e iconos para que se vean bien sobre el amarillo
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Enviando mensaje de emergencia...', style: TextStyle(color: theme.colorScheme.onPrimary)), backgroundColor: theme.colorScheme.primary)
            );
          } else if (state is EmergencySendSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Cliente de correo abierto con éxito. ¡Presione ENVIAR!', style: TextStyle(color: theme.colorScheme.onPrimary)), backgroundColor: Colors.green.shade800)
            );
            _messageController.clear();
          } else if (state is EmergencySendFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ Error: ${state.error}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red.shade800)
            );
          }
        },
        child: SingleChildScrollView( // Añadido para asegurar que la vista sea desplazable
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 1. BOTÓN DE MODO VELOZ ---
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

                // --- 2. SECCIÓN DE EMERGENCIA (Existente) ---
                Text(
                  'Botón de Emergencia "Zzocorro"',
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  'Si tienes una emergencia, presiona el botón. Tu ubicación y mensaje serán enviados a ${EmailServiceImpl.supportEmail}.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje de emergencia (opcional)',
                    hintText: 'Detalles de la emergencia...',
                  ),
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),

                // Botón de emergencia
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: state is SettingsLoading ? null : () {
                        _sendEmergency(context);
                      },
                      icon: state is SettingsLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      label: Text(
                        state is SettingsLoading ? 'ENVIANDO ALERTA...' : 'ZZZOCORROO!!!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}