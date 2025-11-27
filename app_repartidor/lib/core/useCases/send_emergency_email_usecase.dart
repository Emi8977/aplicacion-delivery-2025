// core/usecases/send_emergency_email_usecase.dart
import '../../data/email_service.dart';

class SendEmergencyEmailUseCase {
  final EmailService emailService;

  // Correo de destino fijo para las alertas
  static const String supportEmail = EmailServiceImpl.supportEmail;

  SendEmergencyEmailUseCase(this.emailService);

  Future<void> execute({
    required String message,
    required String senderName,
    required String senderMail,
  }) async {
    final subject = 'ALERTA DE EMERGENCIA - ${senderName}';
    final body = 'Mail de contacto: ${senderMail}\n\n${message}';

    await emailService.sendEmail(
      recipient: senderName, // Usado como parte de la firma
      subject: subject,      // Asunto del correo
      body: body,            // Cuerpo del mensaje
    );
  }
}