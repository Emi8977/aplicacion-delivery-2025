// data/repositories/usuario_repository.dart
import '../../data/models/usuario_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UsuarioRepository {
  Future<UsuarioModel> create(UsuarioModel usuario);
  Future<UsuarioModel?> getById(String uid);
  Future<List<UsuarioModel>> getAll();
  Future<UsuarioModel> update(UsuarioModel usuario);
  Future<void> delete(String uid);
  Future<UsuarioModel?> getByMail(String mail); // Para Login


  // Nuevo método para registrar con email y contraseña
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Método existente para login
  Future<UsuarioModel?> loginWithEmailAndPassword(
      String email, String password);

  //Metodo  de ocultar


}