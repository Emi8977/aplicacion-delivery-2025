import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Importamos la definición de roles
import 'package:app_repartidor/data/models/usuario_model.dart';
// Importamos el BLoC
import 'package:app_repartidor/presentation/bloc/register/register_bloc.dart';
// AÑADIDO: Importamos los eventos del BLoC
import 'package:app_repartidor/presentation/bloc/register/register_event.dart';
// AÑADIDO: Importamos los estados del BLoC, que contienen RegisterState y RegisterStatus
import 'package:app_repartidor/presentation/bloc/register/register_state.dart';

// --- Extensión para el BLoC (necesaria si no está en el BLoC original) ---
// Asumo que RegisterStatus, RegisterState, y RegisterRequested (Event)
// están definidos en 'package:app_repartidor/presentation/bloc/register/register_bloc.dart'

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // El valor inicial es el nuevo rol predeterminado: courier.
  UsuarioRole _selectedRole = UsuarioRole.courier;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      // Usamos el evento RegisterRequested que debe estar en tu BLoC
      context.read<RegisterBloc>().add(
        RegisterRequested(
          nombre: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
        ),
      );
    }
  }

  // Lista de opciones para el Dropdown (solo courier y manager)
  List<DropdownMenuItem<UsuarioRole>> _buildRegistrationRoles() {
    return [
      DropdownMenuItem(
        value: UsuarioRole.courier,
        child: const Text('Repartidor'),
      ),
      DropdownMenuItem(
        value: UsuarioRole.manager,
        child: const Text('Manager'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        // CAMBIO A COLOR PRIMARIO (ÁMBAR)
        backgroundColor: theme.colorScheme.primary,
        // Aseguramos que el texto e iconos sean negros sobre el ámbar
        foregroundColor: theme.colorScheme.onPrimary,
        // Establecemos un poco de elevación para que se vea más definida
        elevation: 4,
      ),
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          // Asumo que tu RegisterState tiene un campo 'status' y un campo 'error'
          if (state.status == RegisterStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('¡Registro exitoso! Por favor inicia sesión.')),
            );
            Navigator.of(context).pop();
          } else if (state.status == RegisterStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error de registro: ${state.error ?? "Desconocido"}')),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Crea tu cuenta',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Ingresa un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Dropdown actualizado
                    DropdownButtonFormField<UsuarioRole>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Cuenta',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                      value: _selectedRole,
                      items: _buildRegistrationRoles(),
                      onChanged: (UsuarioRole? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedRole = newValue;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 32),
                    BlocBuilder<RegisterBloc, RegisterState>(
                      builder: (context, state) {
                        // Accedemos al estado de carga usando la propiedad 'status'
                        final isLoading = state.status == RegisterStatus.loading;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onRegister,
                            child: isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.0),
                            )
                                : const Text('REGISTRARSE'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ya tengo una cuenta, iniciar sesión',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}