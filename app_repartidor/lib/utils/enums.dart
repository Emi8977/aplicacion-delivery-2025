// Este enum se utiliza para definir el marco de tiempo para los rankings.
// Es una utilidad que se comparte entre el repositorio y los BLoCs.
enum Timeframe {
  today,
  week,
  month,
}

// Define los posibles roles de usuario en la aplicación.
enum UserRole {
  manager,
  repartidor, // CRÍTICO: El nombre es 'repartidor'
  public
}

/// Convierte una cadena de texto (String) a su correspondiente enum UserRole.
/// Se utiliza para interpretar el rol almacenado en el AuthBloc.
UserRole stringToUserRole(String roleString) {
  final lowerCaseRole = roleString.toLowerCase();

  switch (lowerCaseRole) {
    case 'manager':
      return UserRole.manager;
    case 'repartidor': // Debe coincidir exactamente con el nombre del enum o la BD
    case 'courier': // Añadimos 'courier' como un alias común por robustez
      return UserRole.repartidor;
    default:
    // Si el string del rol es desconocido o nulo, cae en public
      return UserRole.public;
  }
}

// Helper para facilitar las comparaciones en minúsculas en el código.
extension UserRoleExtension on UserRole {
  String get nameLower => name.toLowerCase();
}