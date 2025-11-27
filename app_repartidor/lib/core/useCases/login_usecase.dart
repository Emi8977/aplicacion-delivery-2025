import '../../data/models/usuario_model.dart';
// Se importa la interfaz (el contrato) que está en la capa 'data'
import '../../data/repositories/usuario_repository.dart';

class LoginUseCase {
  final UsuarioRepository repository;

  LoginUseCase(this.repository);

  // El método 'call' permite usar la clase como una función: LoginUseCase()()
  Future<UsuarioModel?> call(String email, String password) async {
    // La única lógica del Use Case es:
    // 1. Llamar al repositorio para realizar el LOGIN COMPLETO.
    // 2. El repositorio se encarga de: Autenticar (Auth) Y Obtener el Modelo (Firestore).

    // Usamos el método que ya definiste en el contrato del repositorio.
    return await repository.loginWithEmailAndPassword(email, password);
  }
}