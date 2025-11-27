import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// Importaciones necesarias basadas en tu arquitectura
import '../../data/models/usuario_model.dart';
import '../repositories/usuario_repository.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'usuarios'; // Colección donde se guardan los datos del usuario

  // --- MÉTODOS CRUD EN FIRESTORE ---

  @override
  Future<UsuarioModel> create(UsuarioModel usuario) async {
    // Usamos el UID del modelo como ID del documento en Firestore
    await _firestore.collection(_collection).doc(usuario.uid).set(usuario.toJson());
    return usuario;
  }

  @override
  Future<UsuarioModel?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      // Si el documento existe, garantizamos que doc.data() no es nulo.
      if (doc.exists) {
        // CORRECCIÓN 1: Pasamos solo el mapa de datos a fromJson.
        // Asumimos que el ID se maneja internamente en el modelo o no es requerido aquí.
        return UsuarioModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      developer.log('ERROR al obtener usuario por ID: $e', name: 'Firestore ERROR');
      return null;
    }
  }

  @override
  Future<UsuarioModel?> getByMail(String mail) async {
    try {
      final snapshot = await _firestore.collection(_collection)
          .where('email', isEqualTo: mail)
          .limit(1) // Solo necesitamos uno
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        // CORRECCIÓN 2: Pasamos solo el mapa de datos. Usamos ! para seguridad.
        return UsuarioModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      developer.log('ERROR al obtener usuario por mail: $e', name: 'Firestore ERROR');
      return null;
    }
  }

  @override
  Future<List<UsuarioModel>> getAll() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      // CORRECCIÓN 3: Pasamos solo el mapa de datos.
      return snapshot.docs.map((doc) => UsuarioModel.fromJson(doc.data()!)).toList();
    } catch (e) {
      developer.log('ERROR al obtener todos los usuarios: $e', name: 'Firestore ERROR');
      rethrow;
    }
  }

  @override
  Future<UsuarioModel> update(UsuarioModel usuario) async {
    // CORRECCIÓN 4: Simplificamos la comprobación de nulo para el uso del operador !.
    if (usuario.uid == null) {
      throw Exception("El UsuarioModel debe tener un UID para ser actualizado.");
    }

    await _firestore.collection(_collection).doc(usuario.uid).set( // uid ya no necesita ! aquí
        usuario.toJson(),
        SetOptions(merge: true)
    );
    return usuario;
  }

  @override
  Future<void> delete(String uid) async {
    await _firestore.collection(_collection).doc(uid).delete();
  }

  // --- MÉTODOS DE AUTENTICACIÓN FIREBASE ---

  @override
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UsuarioModel?> loginWithEmailAndPassword(
      String email, String password) async {

    // 1. Autenticar en Firebase Auth
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;

    // Ya no es necesario el 'if (firebaseUser != null)' porque el 'return await'
    // solo ocurre si el usuario existe. Si no existe, se devuelve null al final.
    if (firebaseUser != null) {
      // 2. Buscar los datos del usuario en Firestore
      return await getById(firebaseUser.uid);
    }

    // CORRECCIÓN 5: Esta línea ahora es el único return si firebaseUser es nulo,
    // eliminando el warning de "Dead Code".
    return null;
  }



}