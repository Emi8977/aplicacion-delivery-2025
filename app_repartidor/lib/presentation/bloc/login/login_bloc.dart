import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_repartidor/core/useCases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc({required this.loginUseCase}) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      // 1. Llamada al Use Case (Asumo que devuelve un objeto 'user' con 'userUid' y 'role')
      final user = await loginUseCase(event.email, event.password);

      if (user != null) {
        // 2. Éxito: Emitimos el rol y el UID, alineado con el nuevo LoginSuccess
        final roleString = user.role.toString().split('.').last;
        emit(LoginSuccess(userUid: user.uid as String, rol: roleString));
      } else {
        // 3. Fallo: Emitimos un error genérico
        emit(const LoginFailure(error: 'Credenciales inválidas.'));
      }
    } catch (e) {
      // 4. Manejo de excepciones (ej: error de red, DB)
      emit(LoginFailure(error: 'Ocurrió un error: ${e.toString()}'));
    }
  }
}