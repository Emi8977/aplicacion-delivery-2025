// data/email_service.dart
import 'package:url_launcher/url_launcher.dart';

// Definición de la interfaz (Contrato)
abstract class EmailService {
  Future<void> sendEmail({
    required String recipient,
    required String subject,
    required String body,
  });
}

// Implementación usando el cliente de correo del dispositivo (Mailto)
class EmailServiceImpl implements EmailService {
  // Dirección de correo central de la empresa que recibe las alertas.
  static const String supportEmail = 'alerta.supervision@lukzentregas.com';

  @override
  Future<void> sendEmail({
    required String recipient, // Nombre del Courier que envía (usado en el cuerpo)
    required String subject,   // Asunto del correo (ej: Alerta de emergencia)
    required String body,      // Mensaje detallado
  }) async {

    // Construye el cuerpo final del correo
    final fullBody = 'Remitente: $recipient\n\nDetalles:\n$body';

    // 1. Construir la URI 'mailto:' con los campos codificados
    final uri = Uri.parse(
      'mailto:$supportEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(fullBody)}',
    );

    // 2. Verificar si el sistema puede manejar el enlace (si hay una app de correo)
    if (await canLaunchUrl(uri)) {
      // 3. Abrir el cliente de correo por defecto del usuario
      await launchUrl(uri);

      print('✅ Cliente de correo lanzado con éxito.');

    } else {
      // Manejo de error si no hay aplicación de correo configurada
      print('❌ ERROR: No se pudo abrir el cliente de correo.');
      throw Exception('Error: Asegúrate de tener una aplicación de correo configurada en tu dispositivo.');
    }
  }
}