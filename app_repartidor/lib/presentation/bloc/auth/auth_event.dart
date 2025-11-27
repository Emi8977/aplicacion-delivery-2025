part of 'auth_bloc.dart'; // ¡CRÍTICO! Esto lo une al archivo principal.

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

// Evento que se dispara al iniciar la aplicación para chequear si hay sesión.
class AppLoaded extends AuthEvent {}

// Evento que se dispara al recibir el token de un usuario logueado.
class UserLoggedIn extends AuthEvent {
  final String userUid;
  final String role; // Role como String (ej: 'manager', 'repartidor')
  const UserLoggedIn({required this.userUid, required this.role});
}

// Evento CRÍTICO: Se dispara al pulsar "Cerrar Sesión" en el Drawer.
class LogoutRequested extends AuthEvent {}