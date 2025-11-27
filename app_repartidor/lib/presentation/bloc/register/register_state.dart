import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? error;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.error,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? error,
  }) {
    return RegisterState(
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}