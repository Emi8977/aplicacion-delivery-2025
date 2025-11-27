import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/enums.dart'; // Importación de UserRole
import '../bloc/auth/auth_bloc.dart'; // Importación de AuthBloc
import 'dart:math';

// Widget de Drawer reutilizable para Manager, Repartidor y Público
class CustomDrawer extends StatelessWidget {
  final UserRole role;
  // Añadimos campos para mostrar y pasar a la pantalla de Settings
  final String? userName;
  final String? userEmail;

  const CustomDrawer({
    super.key,
    required this.role,
    this.userName,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // 1. Encabezado del Drawer (AHORA ES UN WIDGET PERSONALIZADO)
          _buildHeader(context),

          // 2. Contenido Principal basado en el rol
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildNavigationItems(context),
            ),
          ),

          // 3. Pie de página (Acceso/Logout)
          _buildFooterItem(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // --- BUILDERS DE WIDGETS ---

  // Constructor del Encabezado (MODIFICADO COMPLETAMENTE)
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    String? userUid;

    if (authState is AuthAuthenticated) {
      userUid = authState.userUid;
    }

    if (role == UserRole.public) {
      return DrawerHeader(
        decoration: BoxDecoration(color: theme.colorScheme.secondary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.person_outline, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              'Menú de Acceso',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    }

    // --- Encabezado para usuarios autenticados (Manager y Repartidor) ---

    // 1. Obtener datos
    // Usamos los primeros 8 caracteres para ID si está disponible
    final displayUid = userUid != null && userUid.length >= 8
        ? userUid.substring(0, 8).toUpperCase()
        : 'N/A';

    // Usamos el `userName` pasado como prop, limpiándolo si contiene el ID.
    final displayUserName = userName != null && userName!.contains(':')
        ? userName!.split(':').last.trim() // Extrae el nombre después del ':' si el formato es "Role: Name"
        : (userName ?? (role == UserRole.manager ? 'Gerente' : 'Repartidor'));

    // 2. Definir las tres líneas de texto
    // Línea 1: Empleado: [ID del Usuario]
    final line1 = 'Empleado: $displayUid';
    // Línea 2: [Nombre del Empleado], el empleado estrella
    final line2 = '$displayUserName, el empleado estrella ★';
    // Línea 3: [Email]
    final line3 = userEmail ?? 'email.desconocido@app.com';

    // 3. Reemplazamos UserAccountsDrawerHeader por un DrawerHeader y un Column
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💡 IMAGEN DE PERFIL (AUMENTADO TAMAÑO)
          Container(
            height: 80, // Aumentado de 64 a 80
            width: 80,  // Aumentado de 64 a 80
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo2.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    role == UserRole.manager ? Icons.security : Icons.motorcycle,
                    color: theme.colorScheme.primary,
                    size: 40, // Aumentado el tamaño del icono de fallback
                  );
                },
              ),
            ),
          ),

          const Spacer(),

          // 💡 LÍNEA 1 (ID - CAMBIADO A NEGRO)
          Text(
            line1,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black, // CAMBIADO A NEGRO
              fontSize: 14.0,
            ),
          ),

          // 💡 LÍNEA 2 (Nombre + Estrella - CAMBIADO A NEGRO)
          Text(
            line2,
            style: const TextStyle(
              color: Colors.black87, // CAMBIADO A NEGRO (con un poco de opacidad)
              fontSize: 12.0,
            ),
          ),

          // 💡 LÍNEA 3 (Email - CAMBIADO A NEGRO)
          Text(
            line3,
            style: const TextStyle(
              color: Colors.black54, // CAMBIADO A NEGRO (con más opacidad)
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  // Constructor del contenido de navegación (sin cambios)
  List<Widget> _buildNavigationItems(BuildContext context) {

    final Map<UserRole, List<_DrawerItemData>> roleItems = {
      UserRole.public: [
        _DrawerItemData(Icons.login, 'Acceder', '/login'),
        _DrawerItemData(Icons.person_add, 'Registrarse', '/register'),
      ],
      UserRole.repartidor: [
        _DrawerItemData(Icons.dashboard, 'Mis Entregas', '/courier_dashboard'),
        _DrawerItemData(Icons.leaderboard, 'Ranking de Repartidores', '/ranking'),
        _DrawerItemData(Icons.support_agent, 'Soporte', '/settings'),
      ],
      UserRole.manager: [
        _DrawerItemData(Icons.dashboard, 'Manager Dashboard', '/manager_dashboard'),
        _DrawerItemData(Icons.leaderboard, 'Ranking de Repartidores', '/ranking'),
        _DrawerItemData(Icons.support_agent, 'Soporte', '/settings'),
      ],
    };

    final itemsData = roleItems[role] ?? [];

    return itemsData.map((data) => _buildDrawerItem(
      context,
      icon: data.icon,
      title: data.title,
      onTap: () {
        Navigator.pop(context);

        if (data.route == '/settings') {
          if (userName != null && userEmail != null) {
            Navigator.of(context).pushNamed(
              '/settings',
              arguments: {
                'currentUserName': userName,
                'currentUserMail': userEmail,
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Datos de usuario no disponibles para Configuración.')),
            );
          }
        }

        else if (data.route == '/courier_dashboard' || data.route == '/manager_dashboard') {
          final authState = context.read<AuthBloc>().state;
          String? userUid;
          if (authState is AuthAuthenticated) {
            userUid = authState.userUid;
          }

          if (data.route == '/courier_dashboard' && userUid != null) {
            Navigator.of(context).pushReplacementNamed(
              data.route,
              arguments: {'userUid': userUid},
            );
          } else {
            Navigator.of(context).pushReplacementNamed(data.route);
          }
        }
        else {
          Navigator.of(context).pushNamed(data.route);
        }
      },
    )).toList();
  }

  // Constructor del item de pie de página (Logout o vacío)
  Widget _buildFooterItem(BuildContext context) {
    if (role == UserRole.public) {
      return const SizedBox(height: 0);
    }

    // Cerrar Sesión para usuarios Autenticados
    return _buildDrawerItem(
      context,
      icon: Icons.logout,
      title: 'Cerrar Sesión',
      color: Colors.red, // Resaltar el botón de logout
      onTap: () {
        Navigator.pop(context); // Cierra el drawer

        context.read<AuthBloc>().add(LogoutRequested());

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/welcome_screen',
              (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cerrando sesión...'), duration: Duration(seconds: 1))
        );
      },
    );
  }


  // Widget auxiliar genérico
  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color? color,
      }) {
    final theme = Theme.of(context);
    final finalColor = color ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: finalColor),
      title: Text(
        title,
        style: TextStyle(color: finalColor, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

class _DrawerItemData {
  final IconData icon;
  final String title;
  final String route;
  _DrawerItemData(this.icon, this.title, this.route);
}
