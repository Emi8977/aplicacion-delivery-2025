import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../data/models/pedido_model.dart';
import '../bloc/pedido_courier/pedido_courier_bloc.dart';
import '../bloc/pedido_courier/pedido_courier_event.dart';
import '../bloc/pedido_courier/pedido_courier_state.dart';
import '../widgets/custom_drawer.dart';
import '../../utils/enums.dart'; // Asegúrate de que esta ruta sea correcta para UserRole y EstadoPedido
import '../bloc/auth/auth_bloc.dart';
import '../widgets/stopwatch_timer.dart';

class CourierDashboardScreen extends StatefulWidget {
  const CourierDashboardScreen({super.key});

  @override
  State<CourierDashboardScreen> createState() => _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends State<CourierDashboardScreen> {

  @override
  void initState() {
    super.initState();
    // Llama al evento de carga inicial una sola vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidoCourierBloc>().add(LoadPedidosInitial());
    });
  }

  // ❌ Eliminada la función _showCompletionDialog

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Obtener el estado de autenticación para los datos del Drawer
    final authState = context.watch<AuthBloc>().state;
    String? userName;
    String? userEmail;
    UserRole userRole = UserRole.public;

    if (authState is AuthAuthenticated) {
      userRole = stringToUserRole(authState.userRole);
      userName = 'Courier ID: ${authState.userUid.substring(0, min(8, authState.userUid.length))}';
      userEmail = 'courier.logueado@deliveryapp.com';
    }

    return Scaffold(
      drawer: CustomDrawer(
        role: userRole,
        userName: userName,
        userEmail: userEmail,
      ),

      appBar: AppBar(
        title: const Text('Repartidor - Gestión de Pedidos'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.of(context).pushNamed('/ranking'),
            tooltip: 'Ver Ranking de Repartidores',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PedidoCourierBloc>().add(LoadPedidosInitial()),
          ),
        ],
      ),
      // 💡 Usamos BlocBuilder
      body: BlocBuilder<PedidoCourierBloc, PedidoCourierState>(
        builder: (context, state) {

          // ⚠️ Manejo de errores: Se muestra el SnackBar de forma segura
          if (state.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red.shade700)
              );
              // Limpiar el error después de mostrarlo (opcional, pero buena práctica)
              if (context.read<PedidoCourierBloc>().state.error != null) {
                context.read<PedidoCourierBloc>().emit(state.copyWith(error: null, clearError: true));
              }
            });
          }

          if (state.isLoading && state.availablePedidos.isEmpty && state.myPedidos.isEmpty && state.deliveredPedidos.isEmpty) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- MIS PEDIDOS ACTUALES (Pendiente/En Curso) ---
              _buildSectionTitle('Mis Pedidos Actuales (${state.myPedidos.length})', theme),
              _buildMyPedidosList(context, state.myPedidos, theme),

              const SizedBox(height: 30),

              // --- PEDIDOS DISPONIBLES ---
              _buildSectionTitle('Pedidos Disponibles (${state.availablePedidos.length})', theme),
              _buildAvailablePedidosList(context, state.availablePedidos, theme),

              const SizedBox(height: 30),

              // --- HISTORIAL ENTREGADOS (NUEVO) ---
              _buildSectionTitle('Historial Entregados (${state.deliveredPedidos.length})', theme),
              _buildDeliveredPedidosList(context, state.deliveredPedidos, theme),
            ],
          );
        },
      ),
    );
  }

  // Helper para mostrar el estado del pedido de forma legible
  String _getStatusText(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return 'En Depósito (Pendiente)';
      case EstadoPedido.en_curso:
        return 'En Camino 🛵';
      case EstadoPedido.entregado:
        return 'ENTREGADO ✅';
      case EstadoPedido.cancelado:
        return 'DEVUELTO (Incompletado) 📦';
      default:
        return 'Estado Desconocido';
    }
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMyPedidosList(BuildContext context, List<PedidoModel> pedidos, ThemeData theme) {
    if (pedidos.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No tienes pedidos asignados.', style: TextStyle(color: Colors.grey)),
      ));
    }

    return Column(
      children: pedidos.map((pedido) {
        final isEnCamino = pedido.estado == EstadoPedido.en_curso;
        final isCompleted = pedido.estado == EstadoPedido.entregado ||
            pedido.estado == EstadoPedido.cancelado; // Pedido finalizado

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ListTile(
                  title: Text('Pedido #${pedido.id?.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Cliente: ${pedido.clienteNombre}\nDirección: ${pedido.direccionEntrega}'),
                  trailing: Text(
                    _getStatusText(pedido.estado),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.green
                          : (isEnCamino ? theme.colorScheme.primary : Colors.orange),
                    ),
                  ),
                ),

                // --- INTEGRACIÓN DEL CRONÓMETRO ---
                if (pedido.arrayCronometro.isNotEmpty) ...[
                  const Divider(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StopwatchTimer(
                      arrayCronometro: pedido.arrayCronometro,
                      isCompleted: isCompleted,
                    ),
                  ),
                ],
                // ------------------------------------

                // Mostrar botones de acción SOLO si el pedido está en curso
                if (isEnCamino) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Botón para Devolver a Depósito (Incompletado)
                      ElevatedButton.icon( // Cambiado a ElevatedButton para color de fondo
                        icon: const Icon(Icons.undo, size: 20),
                        label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0), // Aumenta la altura
                            child: Text('Devolver a Depósito', style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        onPressed: () {
                          context.read<PedidoCourierBloc>().add(
                            ReturnPedidoToWarehouseRequested(pedido.id!),
                          );
                        },
                        // 💡 ESTILO ROJO COMPLETO CON TEXTO BLANCO
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700, // Fondo Rojo
                          foregroundColor: Colors.white, // Texto e icono Blanco
                          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Asegura que quepa bien
                        ),
                      ),

                      // Botón para Marcar como Entregado
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 20),
                        label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0), // Aumenta la altura
                            child: Text('Entregado', style: TextStyle(fontWeight: FontWeight.bold)) // Texto Negrita
                        ),
                        onPressed: () {
                          context.read<PedidoCourierBloc>().add(
                            UpdateStatusRequested(
                              pedido.id!,
                              EstadoPedido.entregado,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailablePedidosList(BuildContext context, List<PedidoModel> pedidos, ThemeData theme) {
    if (pedidos.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay pedidos disponibles.', style: TextStyle(color: Colors.grey)),
      ));
    }

    return Column(
      children: pedidos.map((pedido) => Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Text('Pedido #${pedido.id?.substring(0, 8)} - \$${pedido.valorTotal.toStringAsFixed(2)}'),
          subtitle: Text('Entrega en: ${pedido.direccionEntrega}'),
          trailing: ElevatedButton.icon(
            icon: const Icon(Icons.delivery_dining, size: 20),
            label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text('Tomar', style: TextStyle(fontWeight: FontWeight.bold))
            ),
            onPressed: () {
              context.read<PedidoCourierBloc>().add(
                ClaimPedidoRequested(pedido.id!),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              // 💡 CAMBIO CLAVE: Reducimos el padding horizontal para compactar el botón
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
            ),
          ),
        ),
      )).toList(),
    );
  }
  // 💡 MÉTODO MODIFICADO: Lista de Pedidos Entregados con Estilo Oscuro
  Widget _buildDeliveredPedidosList(BuildContext context, List<PedidoModel> pedidos, ThemeData theme) {
    if (pedidos.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay pedidos entregados recientemente.', style: TextStyle(color: Colors.grey)),
      ));
    }

    // Opcional: Mostrar solo los 5 más recientes
    final recentPedidos = pedidos.take(5).toList();

    // Color de tarjeta gris oscuro mate
    final cardColor = Colors.grey.shade900;

    return Column(
      children: recentPedidos.map((pedido) => Card(
        // Fondo gris oscuro mate
        color: cardColor,
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ListTile(
                // Título: Blanco para contraste en fondo oscuro
                title: Text(
                  'Pedido #${pedido.id?.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                // Subtítulo: Color Ámbar para los detalles (consistente con el estilo)
                subtitle: Text(
                    'Cliente: ${pedido.clienteNombre}\nDestino: ${pedido.direccionEntrega}',
                    style: TextStyle(color: Colors.amber.shade300)
                ),
                // Icono: Verde de acento
                trailing: const Icon(Icons.check_circle, color: Colors.greenAccent),
                contentPadding: EdgeInsets.zero,
              ),

              // --- INTEGRACIÓN DEL CRONÓMETRO (tiempo final) ---
              if (pedido.arrayCronometro.isNotEmpty && pedido.arrayCronometro.length >= 2) ...[
                const Divider(height: 10, color: Colors.grey), // Divisor gris para fondo oscuro
                Align(
                  alignment: Alignment.centerLeft,
                  // Usamos el StopwatchTimer con isCompleted: true para calcular la duración total
                  child: StopwatchTimer(
                    arrayCronometro: pedido.arrayCronometro,
                    isCompleted: true, // Indica que debe mostrar el tiempo final
                  ),
                ),
              ],
              // ----------------------------------------------------
            ],
          ),
        ),
      )).toList(),
    );
  }
}