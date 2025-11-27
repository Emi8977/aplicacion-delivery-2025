import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Imports de BLoC ---
import 'package:app_repartidor/presentation/bloc/auth/auth_bloc.dart';
import 'package:app_repartidor/presentation/bloc/login/login_bloc.dart';
import 'package:app_repartidor/presentation/bloc/settings/settings_bloc.dart';
import 'package:app_repartidor/presentation/bloc/pedido_courier/pedido_courier_bloc.dart';
import 'package:app_repartidor/presentation/bloc/register/register_bloc.dart';
import 'package:app_repartidor/presentation/bloc/pedido_manager/pedido_manager_bloc.dart';
import 'package:app_repartidor/presentation/bloc/repartidor_ranking/repartidor_ranking_bloc.dart';

// --- Imports de Core y Data ---
import 'package:app_repartidor/data/repositories_impl/usuario_repository_impl.dart';
import 'package:app_repartidor/data/repositories_impl/pedido_repository_impl.dart';
import 'package:app_repartidor/data/email_service.dart';
import 'package:app_repartidor/core/useCases/login_usecase.dart';
import 'package:app_repartidor/core/useCases/send_emergency_email_usecase.dart';
import 'package:app_repartidor/core/useCases/create_pedido_usecase.dart';
import 'package:app_repartidor/core/useCases/update_pedido_status_usecase.dart';
import 'package:app_repartidor/core/useCases/get_pedidos_available_usecase.dart';
import 'package:app_repartidor/core/useCases/register_user_usecase.dart';
import 'package:app_repartidor/core/useCases/hide_pedido_usecase.dart';
// 💡 NUEVA IMPORTACIÓN: CASO DE USO AVANZADO
import 'package:app_repartidor/core/useCases/manager_update_pedido_usecase.dart';
import 'package:app_repartidor/data/repositories/pedido_repository.dart';
import 'package:app_repartidor/data/repositories/usuario_repository.dart';

// --- Imports de Views y Config ---
import 'package:app_repartidor/config/app_theme.dart';
import 'package:app_repartidor/presentation/views/login_screen.dart';
import 'package:app_repartidor/presentation/views/settings_screen.dart';
import 'package:app_repartidor/presentation/views/courier_dashboard_screen.dart';
import 'package:app_repartidor/presentation/views/register_screen.dart';
import 'package:app_repartidor/presentation/views/welcome_screen.dart';
import 'package:app_repartidor/presentation/views/manager_dashboard_screen.dart';
import 'package:app_repartidor/presentation/views/repartidor_ranking_screen.dart';
import 'package:app_repartidor/presentation/views/support_screen.dart';
import 'package:app_repartidor/firebase_options.dart';


// --- DEFINICIÓN ASUMIDA DE UserRole ---
enum UserRole {
  manager,
  repartidor,
  public
}

// Helper para obtener el nombre del rol en minúsculas para la comparación
extension UserRoleExtension on UserRole {
  String get nameLower => name.toLowerCase();
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    FirebaseAuth.instance;
  } catch (e) {
    print('Error al obtener instancia de FirebaseAuth: $e');
  }


  // --- 1. Inicialización de Repositorios (DATA) ---
  final UsuarioRepository usuarioRepository = UsuarioRepositoryImpl();
  final PedidoRepository pedidoRepository = PedidoRepositoryImpl();

  final emailService = EmailServiceImpl();
  const uuid = Uuid();


  // --- 2. Inicialización de Use Cases (CORE) ---
  final loginUseCase = LoginUseCase(usuarioRepository);
  final registerUserUseCase = RegisterUserUseCase(usuarioRepository);
  final sendEmergencyEmailUseCase = SendEmergencyEmailUseCase(emailService);
  final createPedidoUseCase = CreatePedidoUseCase(pedidoRepository, uuid);
  final updatePedidoStatusUseCase = UpdatePedidoStatusUseCase(pedidoRepository);
  final getPedidosAvailableUseCase = GetPedidosAvailableUseCase(pedidoRepository);
  final hidePedidoUseCase = HidePedidoUseCase(pedidoRepository);

  // 💡 INSTANCIACIÓN DEL NUEVO CASO DE USO
  final managerUpdatePedidoUseCase = ManagerUpdatePedidoUseCase(pedidoRepository);


  // 3. Ejecución de la aplicación
  runApp(
    MyApp(
      loginUseCase: loginUseCase,
      registerUserUseCase: registerUserUseCase,
      sendEmergencyEmailUseCase: sendEmergencyEmailUseCase,
      createPedidoUseCase: createPedidoUseCase,
      updatePedidoStatusUseCase: updatePedidoStatusUseCase,
      getPedidosAvailableUseCase: getPedidosAvailableUseCase,
      hidePedidoUseCase: hidePedidoUseCase,
      // 💡 NUEVA INYECCIÓN
      managerUpdatePedidoUseCase: managerUpdatePedidoUseCase,
      pedidoRepository: pedidoRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  // Propiedades para inyectar Use Cases y Repositorios
  final LoginUseCase loginUseCase;
  final RegisterUserUseCase registerUserUseCase;
  final SendEmergencyEmailUseCase sendEmergencyEmailUseCase;
  final CreatePedidoUseCase createPedidoUseCase;
  final UpdatePedidoStatusUseCase updatePedidoStatusUseCase;
  final GetPedidosAvailableUseCase getPedidosAvailableUseCase;
  final HidePedidoUseCase hidePedidoUseCase;
  // 💡 NUEVA PROPIEDAD REQUERIDA
  final ManagerUpdatePedidoUseCase managerUpdatePedidoUseCase;
  final PedidoRepository pedidoRepository;

  const MyApp({
    required this.loginUseCase,
    required this.registerUserUseCase,
    required this.sendEmergencyEmailUseCase,
    required this.createPedidoUseCase,
    required this.updatePedidoStatusUseCase,
    required this.getPedidosAvailableUseCase,
    required this.hidePedidoUseCase,
    // 💡 REQUERIDO EN CONSTRUCTOR
    required this.managerUpdatePedidoUseCase,
    required this.pedidoRepository,
    super.key,
  });

  // --- FUNCIÓN DE GENERACIÓN DE RUTAS DINÁMICAS (MÉTODO DE INSTANCIA) ---
  Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
    // *** RUTA AÑADIDA PARA WELCOME SCREEN ***
      case '/welcome_screen':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
    // ***************************************

    // *** RUTA AÑADIDA PARA SOPORTE ***
      case '/support':
        return MaterialPageRoute(builder: (_) => const SupportScreen());
    // *******************************

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/ranking':
        return MaterialPageRoute(builder: (_) => const RankingScreen());

    // --- RUTA ÚNICA PARA COURIER DASHBOARD (INYECCIÓN DEL PEDIDO COURIER BLOC) ---
      case '/courier_dashboard':
      // Se requiere el userUid como argumento para inicializar el BLoC de Courier
        if (args is Map<String, dynamic> && args.containsKey('userUid')) {
          final userUid = args['userUid'] as String;

          // Creamos y proporcionamos el BLoC para la pantalla a la que se navega
          return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => PedidoCourierBloc(
                currentCourierUid: userUid,
                getAvailablePedidosUseCase: getPedidosAvailableUseCase,
                updatePedidoStatusUseCase: updatePedidoStatusUseCase,
                pedidoRepository: pedidoRepository,
              ),
              child: const CourierDashboardScreen(),
            ),
          );
        }
        // Fallback si la navegación ocurre sin el argumento userUid: Volvemos al login
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    // -------------------------------------------------------------------------

    // --- RUTA DE MANAGER DASHBOARD (USA BLoC GLOBAL) ---
      case '/manager_dashboard':
        return MaterialPageRoute(builder: (_) => const ManagerDashboardScreen());
    // ----------------------------------------------------

      case '/settings':
      // REQUIERE ARGUMENTOS OBLIGATORIOS
        if (args is Map<String, dynamic> &&
            args.containsKey('currentUserName') &&
            args.containsKey('currentUserMail'))
        {
          return MaterialPageRoute(
            builder: (_) => SettingsScreen(
              currentUserName: args['currentUserName'] as String,
              currentUserMail: args['currentUserMail'] as String,
            ),
          );
        }
        // Fallback si la ruta /settings es llamada sin argumentos requeridos
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error de Navegación: Faltan datos de usuario para la pantalla de Configuración.'),
            ),
          ),
        );

      default:
      // Ruta no encontrada
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Error: Ruta ${settings.name} no definida.'),
            ),
          ),
        );
    }
  }
  // ----------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // BLoCs Globales
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AppLoaded()),
        ),
        BlocProvider(create: (context) => LoginBloc(loginUseCase: loginUseCase)),
        BlocProvider(create: (context) => RegisterBloc(registerUserUseCase: registerUserUseCase)),
        BlocProvider(
          create: (context) => SettingsBloc(
            sendEmergencyEmailUseCase: sendEmergencyEmailUseCase,
          ),
        ),
        // 💡 PEDIDO MANAGER BLOC CON LA INYECCIÓN ACTUALIZADA
        BlocProvider(
          create: (context) => PedidoManagerBloc(
            createPedidoUseCase: createPedidoUseCase,
            // 💡 El BLoC avanzado que definimos requiere esta dependencia.
            managerUpdatePedidoUseCase: managerUpdatePedidoUseCase,
            pedidoRepository: pedidoRepository,
          ),
        ),
        BlocProvider(
          create: (context) => RepartidorRankingBloc(
            pedidoRepository: pedidoRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Delivery App',
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        // Usamos darkTheme, por lo que este 'theme' se ignora.
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,

        // ASIGNAMOS LA FUNCIÓN GENERADORA DE RUTAS (es un método de instancia)
        onGenerateRoute: generateRoute,

        // 'home' sigue siendo el AuthGate que decide el flujo principal (BOOT)
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {

            // 1. Estados iniciales y de carga
            if (state is AuthInitial || state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Verificando sesión...", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              );
            }

            // 2. Estado de Desautenticación
            if (state is AuthUnauthenticated) {
              return const WelcomeScreen();
            }

            // 3. Estado Autenticado (FLUJO DE INICIO DE SESIÓN EXITOSO)
            if (state is AuthAuthenticated) {
              // Convertimos el rol a minúsculas para una comparación robusta
              final roleLower = state.userRole.toLowerCase();

              // Verificación robusta para Repartidor/Courier (acepta 'repartidor' o 'courier')
              final isCourierRole = roleLower == UserRole.repartidor.nameLower || roleLower == 'courier';

              // Si es repartidor: INYECCIÓN LOCAL OBLIGATORIA (necesita el UID)
              if (isCourierRole) {
                return BlocProvider(
                  create: (context) => PedidoCourierBloc(
                    currentCourierUid: state.userUid,
                    getAvailablePedidosUseCase: getPedidosAvailableUseCase,
                    updatePedidoStatusUseCase: updatePedidoStatusUseCase,
                    pedidoRepository: pedidoRepository,
                  ),
                  child: const CourierDashboardScreen(),
                );
              }
              // Si es manager: BLoC ya global
              else if (roleLower == UserRole.manager.nameLower) {
                return const ManagerDashboardScreen();
              }

              // Fallback de seguridad: Usuario autenticado con rol desconocido.
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Error: Usuario autenticado con rol desconocido ("${state.userRole}"). Roles esperados: "${UserRole.repartidor.nameLower}", "courier" o "${UserRole.manager.nameLower}".',
                      style: const TextStyle(color: Colors.yellow, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            // Fallback general
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}