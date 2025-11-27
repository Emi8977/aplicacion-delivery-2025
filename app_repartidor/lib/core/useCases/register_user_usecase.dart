import 'package:firebase_auth/firebase_auth.dart'; // Importación necesaria para UserCredential
import '../../data/models/usuario_model.dart';
import '../../data/repositories/usuario_repository.dart';

// Este use case se encarga de registrar un nuevo usuario en la aplicación.
// Recibe un UsuarioModel (pre-creado con el rol deseado) y la contraseña.
class RegisterUserUseCase {
  final UsuarioRepository repository;

  RegisterUserUseCase(this.repository);

  Future<UsuarioModel> execute({
    required String nombre,
    required String email,
    required String password,
    required UsuarioRole role,
    // El campo 'telefono' ya no es requerido en UsuarioModel, por lo que puede ser opcional aquí
    String? telefono,
  }) async {
    // 1. Crear el usuario en Firebase Auth y obtener el UID.
    final authResult = await repository.registerWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Acceder al UID a través de .user?.uid
    final uid = authResult.user?.uid;

    if (uid == null) {
      throw Exception("Fallo en la creación de usuario en Firebase Auth (UID nulo).");
    }

    // 2. Crear el modelo con el UID obtenido.
    final newUser = UsuarioModel(
      uid: uid,
      nombre: nombre,
      email: email,
      role: role,
      // ** CORRECCIÓN CLAVE **: arrayCronometro ha sido eliminado de UsuarioModel
      // y 'telefono' puede ser nulo, así que lo pasamos si está disponible.
      telefono: telefono,
    );

    // 3. Guardar el modelo en Firestore.
    await repository.create(newUser);

    return newUser;
  }
}