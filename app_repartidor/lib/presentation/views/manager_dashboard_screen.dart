import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/pedido_model.dart';
import '../bloc/pedido_manager/pedido_manager_bloc.dart';
// Asegúrate de importar correctamente tus Eventos y Estados del Manager BLoC
//import '../bloc/pedido_manager/pedido_manager_event.dart';
//import '../bloc/pedido_manager/pedido_manager_state.dart';
import '../../utils/enums.dart'; // Contiene UserRole, EstadoPedido
import '../widgets/custom_drawer.dart'; // Asumido
import '../bloc/auth/auth_bloc.dart'; // Asumido

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authState = context.watch<AuthBloc>().state;
    String? userName;
    String? userEmail;

    if (authState is AuthAuthenticated) {
      userName = 'Manager ID: ${authState.userUid.substring(0, 8)}';
      userEmail = 'manager.logueado@deliveryapp.com';
    }

    // ⚠️ Importante: Usar addPostFrameCallback si el widget es un StatelessWidget
    // para evitar errores al despachar eventos en el método build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidoManagerBloc>().add(LoadAllPedidos());
    });

    // Fallback si la carga inicial falla la primera vez
    // context.read<PedidoManagerBloc>().add(LoadAllPedidos());

    return Scaffold(
      drawer: CustomDrawer(
        role: UserRole.manager,
        userName: userName,
        userEmail: userEmail,
      ),

      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Gestión de Pedidos (Manager)'),

        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.of(context).pushNamed('/ranking'),
            tooltip: 'Ver Ranking de Repartidores',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PedidoManagerBloc>().add(LoadAllPedidos()),
            tooltip: 'Recargar pedidos',
          ),
        ],
      ),
      body: BlocConsumer<PedidoManagerBloc, PedidoManagerState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red.shade700)
            );
            // Si tu BLoC tiene lógica para limpiar el error, úsala aquí.
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.allPedidos.isEmpty) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary));
          }

          if (state.allPedidos.isEmpty && !state.isLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                        'No hay pedidos registrados.',
                        style: theme.textTheme.headlineSmall?.copyWith(color: Colors.black54)
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Utiliza el botón flotante para crear el primer pedido.',
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black45)
                    ),
                  ],
                ),
              ),
            );
          }

          final sortedPedidos = List<PedidoModel>.from(state.allPedidos)
            ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));


          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSummaryCards(sortedPedidos, theme),
              const SizedBox(height: 20),
              _buildSectionTitle('Historial de Pedidos (${sortedPedidos.length})', theme),
              _buildPedidosList(context, sortedPedidos, theme),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePedidoDialog(context),
        label: const Text('Crear Nuevo Pedido'),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<PedidoModel> pedidos, ThemeData theme) {
    final visibles = pedidos.where((p) => p.hidden != true);
    final pendientes = visibles.where((p) => p.estado == EstadoPedido.pendiente).length;
    final enCurso = visibles.where((p) => p.estado == EstadoPedido.en_curso).length;
    final entregados = visibles.where((p) => p.estado == EstadoPedido.entregado).length;
    final cancelados = visibles.where((p) => p.estado == EstadoPedido.cancelado).length;

    final Color primaryLight = Colors.indigo.shade300;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.9,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildCard(theme, 'Pendientes', '$pendientes', Colors.red.shade300, Icons.access_time),
        _buildCard(theme, 'En Curso', '$enCurso', primaryLight, Icons.two_wheeler),
        _buildCard(theme, 'Entregados', '$entregados', Colors.green.shade300, Icons.check_circle),
        _buildCard(theme, 'Cancelados', '$cancelados', Colors.orange.shade300, Icons.cancel),
      ],
    );
  }

  Widget _buildCard(ThemeData theme, String title, String count, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25, color: Colors.white),
            const SizedBox(height: 5),
            Text(count, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(title, textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  String _getStatusText(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente: return 'Pendiente';
      case EstadoPedido.en_curso: return 'En Curso';
      case EstadoPedido.entregado: return 'Entregado';
      case EstadoPedido.cancelado: return 'Cancelado';
    }
  }

  Color _getStatusColor(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente: return Colors.red;
      case EstadoPedido.en_curso: return Colors.blue.shade600;
      case EstadoPedido.entregado: return Colors.green;
      case EstadoPedido.cancelado: return Colors.orange;
    }
  }

  Widget _buildPedidosList(BuildContext context, List<PedidoModel> pedidos, ThemeData theme) {
    // Definimos el color de tarjeta oscuro para el estilo unificado
    final cardBackgroundColor = Colors.grey.shade900;

    return Column(
      children: pedidos.map((pedido) {
        final String idNotNullable = pedido.id ?? '';
        final String displayId = idNotNullable.length >= 8
            ? idNotNullable.substring(0, 8)
            : idNotNullable.isEmpty ? 'N/A' : idNotNullable;

        final String courierUid = pedido.repartidorUid ?? '';
        final String displayCourierUid = courierUid.length >= 8
            ? courierUid.substring(0, 8)
            : courierUid.isEmpty ? 'N/A' : courierUid;

        // Lógica de estado y visibilidad
        final isArchived = pedido.hidden == true;
        final isFinalState = pedido.estado == EstadoPedido.cancelado || pedido.estado == EstadoPedido.entregado;

        // 💡 COLOR DE LA TARJETA BASADO EN EL ESTADO Y ARCHIVADO
        // Usamos el color oscuro, pero si está archivado, bajamos la opacidad.
        Color finalCardColor = isArchived ? cardBackgroundColor.withOpacity(0.5) : cardBackgroundColor;

        // Colores de texto unificados para el fondo oscuro
        final Color titleColor = isArchived ? Colors.grey : Colors.white;
        final Color subtitleColor = isArchived ? Colors.grey.shade600 : Colors.amber.shade300;


        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          color: finalCardColor, // Aplicamos el color oscuro
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(pedido.estado).withOpacity(isArchived ? 0.2 : 0.4),
              child: isArchived
                  ? const Icon(Icons.archive, color: Colors.grey)
                  : Icon(Icons.local_shipping, color: Colors.white), // Icono blanco para fondo oscuro
            ),
            title: Text(
              '#$displayId - \$${pedido.valorTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isArchived ? TextDecoration.lineThrough : TextDecoration.none,
                color: titleColor, // Color blanco/gris
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pedido.clienteNombre} | Dir: ${pedido.direccionEntrega}',
                  style: TextStyle(color: subtitleColor), // Color ámbar/gris
                ),
                Text(
                  'Asignado: $displayCourierUid',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                    fontWeight: courierUid.isEmpty ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
                Text(
                  isArchived ? 'ARCHIVADO' : _getStatusText(pedido.estado),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isArchived ? Colors.grey.shade700 : _getStatusColor(pedido.estado), // Mantener color de estado
                  ),
                ),
              ],
            ),
            trailing: SizedBox(
              width: 50,
              child: _buildOptionsMenu(
                context,
                pedido,
                isFinalState,
                isArchived,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 💡 FUNCIÓN MODIFICADA: Ahora usa el diálogo avanzado
  Widget _buildOptionsMenu(
      BuildContext context,
      PedidoModel pedido,
      bool isFinalState,
      bool isArchived) {

    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (result == 'advanced_change') {
          _showAdvancedStatusDialog(context, pedido);
        } else if (result == 'hide') {
          // Ocultar (hidden = true)
          _confirmHideDialog(context, pedido.id!, true);
        } else if (result == 'unhide') {
          // Desarchivar (hidden = false)
          _confirmHideDialog(context, pedido.id!, false);
        }
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> items = [];

        // 1. Opción de Gestión Avanzada (Siempre visible)
        items.add(
          const PopupMenuItem<String>(
            value: 'advanced_change',
            child: Row(
              children: [
                Icon(Icons.edit_square, color: Colors.blue),
                SizedBox(width: 8),
                Text('Cambiar Estado / Visibilidad...'),
              ],
            ),
          ),
        );
        items.add(const PopupMenuDivider());

        // 2. Ocultar (Si es estado final Y no está archivado)
        if (isFinalState && !isArchived) {
          items.add(
            const PopupMenuItem<String>(
              value: 'hide',
              child: Row(
                children: [
                  Icon(Icons.visibility_off, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Ocultar (Archivar)'),
                ],
              ),
            ),
          );
        }

        // 3. Desarchivar (Si está Archivado)
        if (isArchived) {
          items.add(
            const PopupMenuItem<String>(
              value: 'unhide',
              child: Row(
                children: [
                  Icon(Icons.unarchive, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Reactivar Visibilidad'),
                ],
              ),
            ),
          );
        }

        return items;
      },
      icon: Icon(
        Icons.more_vert,
        size: 20,
        // Color del ícono ajustado para el fondo oscuro
        color: isArchived ? Colors.grey : Colors.white70,
      ),
    );
  }

  // --- Diálogo de Gestión Avanzada ---
  void _showAdvancedStatusDialog(BuildContext context, PedidoModel pedido) {
    EstadoPedido selectedState = pedido.estado;
    bool isHidden = pedido.hidden ?? false;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setStateLocal) {
            return AlertDialog(
              title: const Text('Gestión Avanzada de Pedido'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de Estado
                  const Text('Nuevo Estado del Pedido:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<EstadoPedido>(
                    value: selectedState,
                    isExpanded: true,
                    items: EstadoPedido.values.map((EstadoPedido estado) {
                      return DropdownMenuItem<EstadoPedido>(
                        value: estado,
                        child: Text(_getStatusText(estado), style: TextStyle(color: _getStatusColor(estado))),
                      );
                    }).toList(),
                    onChanged: (EstadoPedido? newValue) {
                      if (newValue != null) {
                        setStateLocal(() {
                          selectedState = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Selector de Visibilidad (Archivado)
                  const Text('Visibilidad (Archivado):', style: TextStyle(fontWeight: FontWeight.bold)),
                  SwitchListTile(
                    title: Text(isHidden ? 'Archivado (Oculto)' : 'Visible'),
                    dense: true,
                    value: isHidden,
                    onChanged: (bool newValue) {
                      setStateLocal(() {
                        isHidden = newValue;
                      });
                    },
                    activeColor: theme.colorScheme.error,
                  ),
                  Text(
                    isHidden
                        ? 'El pedido NO será visible.'
                        : 'El pedido será visible.',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                ElevatedButton(
                  child: const Text('Aplicar Cambios', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // 🚀 DESPACHAR EL EVENTO COMBINADO ManagerUpdatePedido
                    context.read<PedidoManagerBloc>().add(
                      ManagerUpdatePedido(
                        pedidoId: pedido.id!,
                        nuevoEstado: selectedState,
                        hiddenStatus: isHidden,
                      ),
                    );
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Diálogo de Confirmación Simple (Ocultar/Desarchivar) ---
  void _confirmHideDialog(BuildContext context, String pedidoId, bool hiddenStatus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hiddenStatus ? 'Confirmar Ocultar' : 'Confirmar Reactivación'),
        content: Text(
            hiddenStatus
                ? '¿Está seguro de que desea ocultar este pedido? Dejará de verse en el historial.'
                : '¿Está seguro de que desea reactivar y mostrar este pedido en el historial?'
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text(hiddenStatus ? 'Ocultar' : 'Reactivar', style: const TextStyle(color: Colors.white)),
            onPressed: () {
              context.read<PedidoManagerBloc>().add(
                  HidePedido(pedidoId, hiddenStatus)
              );
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: hiddenStatus ? Colors.red : Colors.blue),
          ),
        ],
      ),
    );
  }


  void _showCreatePedidoDialog(BuildContext context) {
    final nombreController = TextEditingController();
    final direccionController = TextEditingController();
    final valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear Nuevo Pedido'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
              ),
              TextField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: 'Dirección de Entrega'),
              ),
              TextField(
                controller: valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor Total (\$)'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Crear'),
            onPressed: () {
              final nombre = nombreController.text;
              final direccion = direccionController.text;
              final valor = double.tryParse(valorController.text) ?? 0.0;

              if (nombre.isNotEmpty && direccion.isNotEmpty && valor > 0) {
                context.read<PedidoManagerBloc>().add(
                  CreateNewPedido(
                    clienteNombre: nombre,
                    direccionEntrega: direccion,
                    valorTotal: valor,
                  ),
                );
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos correctamente.'), backgroundColor: Colors.orange)
                );
              }
            },
          ),
        ],
      ),
    );
  }
}