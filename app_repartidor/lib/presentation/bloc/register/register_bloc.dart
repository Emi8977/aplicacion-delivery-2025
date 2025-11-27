import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_repartidor/core/useCases/register_user_usecase.dart';

import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUserUseCase registerUserUseCase;

  RegisterBloc({required this.registerUserUseCase})
      : super(const RegisterState()) {
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<RegisterState> emit,
      ) async {
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      await registerUserUseCase.execute(
        nombre: event.nombre,
        email: event.email,
        password: event.password,
        role: event.role,
      );

      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        error: e.toString(),
      ));
    }
  }
}