import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';
import '../bloc/auth/auth_bloc.dart'; // Importación necesaria para comunicar el login exitoso

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Nota: Cambié los valores por defecto para evitar problemas en producción,
  // pero mantengo tus valores para debug.
  final TextEditingController _mailController = TextEditingController(text: 'emiluna@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
        LoginRequested(
          email: _mailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Iniciar Sesión'),
        backgroundColor: theme.colorScheme.secondary,
        // Usamos el color onPrimary (Negro) para el texto e iconos para que se vean bien sobre el amarillo
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: BlocListener<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  // 1. Informar al AuthBloc que un usuario ha ingresado
                  context.read<AuthBloc>().add(
                    UserLoggedIn(userUid: state.userUid, role: state.rol),
                  );

                  // 2. Navegación explícita (temporal hasta que el AuthBloc tome el control)
                  if (state.rol == 'manager') {
                    Navigator.of(context).pushReplacementNamed('/manager_dashboard');
                  } else if (state.rol == 'courier' || state.rol == 'repartidor') {
                    // *** CORRECCIÓN CLAVE: Pasamos el userUid requerido por generateRoute ***
                    Navigator.of(context).pushReplacementNamed(
                      '/courier_dashboard',
                      arguments: {'userUid': state.userUid},
                    );
                  }
                } else if (state is LoginFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.error}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red.shade800));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DELIVERY APP',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _mailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) => value!.isEmpty ? 'Ingresa tu correo' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) => value!.isEmpty ? 'Ingresa tu contraseña' : null,
                  ),
                  const SizedBox(height: 30),

                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is LoginLoading ? null : () => _onLoginPressed(context),
                          child: state is LoginLoading
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                          )
                              : const Text('INICIAR SESIÓN', style: TextStyle(fontSize: 18)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}