part of 'auth_bloc.dart'; // ¡CRÍTICO! Esto lo une al archivo principal.

// El estado abstracto es la base para todos los estados de autenticación
@immutable
abstract class AuthState {
  const AuthState();
}

// 1. Estado inicial del BLoC
class AuthInitial extends AuthState {}

// 2. Estado de carga (ej: limpiando token o verificando credenciales)
class AuthLoading extends AuthState {}

// 3. Estado cuando no hay un usuario logueado (debe mostrar el login)
class AuthUnauthenticated extends AuthState {}

// 4. Estado cuando el usuario está logueado
class AuthAuthenticated extends AuthState {
  final String userUid;
  // CORRECCIÓN: Usamos 'userRole' para coincidir con lo que espera la vista.
  final String userRole;

  const AuthAuthenticated({required this.userUid, required this.userRole});
}