import 'package:equatable/equatable.dart';
import 'package:app_repartidor/data/models/usuario_model.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterRequested extends RegisterEvent {
  final String nombre;
  final String email;
  final String password;
  final UsuarioRole role;

  const RegisterRequested({
    required this.nombre,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [nombre, email, password, role];
}