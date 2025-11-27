import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

// *** CORRECCIÓN CLAVE: Agregamos userUid a LoginSuccess ***
class LoginSuccess extends LoginState {
  final String userUid;
  final String rol;

  const LoginSuccess({required this.userUid, required this.rol});

  @override
  List<Object> get props => [userUid, rol];
}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}