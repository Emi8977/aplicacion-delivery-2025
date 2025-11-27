// presentation/bloc/settings/settings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../../core/useCases/send_emergency_email_usecase.dart';
import 'package:app_repartidor/core/useCases/send_emergency_email_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SendEmergencyEmailUseCase sendEmergencyEmailUseCase;

  SettingsBloc({required this.sendEmergencyEmailUseCase}) : super(SettingsInitial()) {
    on<SendEmergencyRequested>(_onSendEmergencyRequested);
  }

  void _onSendEmergencyRequested(
      SendEmergencyRequested event,
      Emitter<SettingsState> emit,
      ) async {
    emit(SettingsLoading());
    try {
      // 1. Llamada al Use Case para enviar el correo (CORRECCIÓN AQUÍ)
      await sendEmergencyEmailUseCase.execute( // <-- Usamos .execute
        senderName: event.senderName,
        message: event.message,            // <-- El parámetro correcto es 'message'
        senderMail: event.senderMail,
      );

      // 2. Éxito (El cliente de correo se ha abierto)
      emit(const EmergencySendSuccess());

      // 3. Volver al estado inicial para permitir nuevos envíos
      emit(SettingsInitial());

    } catch (e) {
      // 4. Fallo
      emit(EmergencySendFailure('Fallo al enviar el mensaje: ${e.toString()}'));
      // Volver al estado inicial después del fallo
      emit(SettingsInitial());
    }
  }
}