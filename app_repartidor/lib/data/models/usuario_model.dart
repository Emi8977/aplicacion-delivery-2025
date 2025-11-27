// Definición del Enum de Roles
enum UsuarioRole {
  manager,
  courier
}

class UsuarioModel {
  final String uid;
  final String nombre;
  final String email;
  final String? telefono;
  final UsuarioRole role;
  // --- arrayCronometro ELIMINADO de aquí ---

  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.email,
    this.telefono,
    required this.role,
    // required this.arrayCronometro, <-- ELIMINADO
  });

  // ----------------------------------------------------
  // CONVERSIÓN DE FIRESTORE: fromJson
  // ----------------------------------------------------
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    final String roleString = json['role'] as String;
    final UsuarioRole role = UsuarioRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleString,
      orElse: () => UsuarioRole.courier,
    );

    return UsuarioModel(
      uid: json['uid'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      role: role,
      // arrayCronometro ELIMINADO de la construcción
    );
  }

  // ----------------------------------------------------
  // CONVERSIÓN A FIRESTORE: toJson
  // ----------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'role': role.toString().split('.').last,
      // arrayCronometro ELIMINADO de la conversión
    };
  }

  // Clonación para inmutabilidad
  UsuarioModel copyWith({
    String? uid,
    String? nombre,
    String? email,
    String? telefono,
    UsuarioRole? role,
    // List<String>? arrayCronometro, <-- ELIMINADO
  }) {
    return UsuarioModel(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      role: role ?? this.role,
      // arrayCronometro: arrayCronometro ?? this.arrayCronometro, <-- ELIMINADO
    );
  }
}