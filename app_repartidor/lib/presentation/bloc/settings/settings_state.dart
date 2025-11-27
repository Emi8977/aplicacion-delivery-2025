// presentation/bloc/settings/settings_state.dart
import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}

class EmergencySendSuccess extends SettingsState {
  const EmergencySendSuccess();
}

class EmergencySendFailure extends SettingsState {
  final String error;
  const EmergencySendFailure(this.error);
  @override
  List<Object> get props => [error];
}