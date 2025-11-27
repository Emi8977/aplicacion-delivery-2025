import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

/// Evento para solicitar el inicio de sesión con credenciales.
class LoginRequested extends LoginEvent {
  // CORRECCIÓN: Usamos 'email' para coincidir con el BLoC y UsuarioModel
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}