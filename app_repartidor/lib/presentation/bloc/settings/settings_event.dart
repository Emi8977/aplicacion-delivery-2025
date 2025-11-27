// presentation/bloc/settings/settings_event.dart
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class SendEmergencyRequested extends SettingsEvent {
  final String message;
  final String senderName;
  final String senderMail;

  const SendEmergencyRequested({
    required this.message,
    required this.senderName,
    required this.senderMail,
  });

  @override
  List<Object> get props => [message, senderName, senderMail];
}

