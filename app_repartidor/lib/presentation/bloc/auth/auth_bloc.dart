import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

// 1. Declaramos el archivo de eventos y el archivo de estados como PARTES
part 'auth_event.dart';
part 'auth_state.dart';

// Este BLoC gestiona el estado de autenticación (logueado, no logueado)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Aquí inyectarías un Repositorio de Autenticación real
  AuthBloc() : super(AuthInitial()) {
    on<AppLoaded>(_onAppLoaded);
    on<UserLoggedIn>(_onUserLoggedIn);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // Simulación: Cargar estado inicial de la aplicación (comprobar token)
  void _onAppLoaded(AppLoaded event, Emitter<AuthState> emit) async {
    // Aquí iría la lógica para leer un token guardado
    await Future.delayed(const Duration(milliseconds: 500));
    // Por simplicidad, emitimos no autenticado por defecto o cargamos desde un storage.
    emit(AuthUnauthenticated());
  }

  // Maneja el éxito del LoginBloc
  void _onUserLoggedIn(UserLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(userUid: event.userUid, userRole: event.role));
  }

  // Maneja el Logout
  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Muestra un spinner mientras se limpia la sesión

    // Lógica real para limpiar el token o cerrar sesión en Firebase/API
    await Future.delayed(const Duration(seconds: 1));

    emit(AuthUnauthenticated());
    // Después de esto, la aplicación navegará de vuelta a la pantalla de Login
  }
}