// Archivo: pedido_manager/pedido_manager_event.dart

part of 'pedido_manager_bloc.dart';

@immutable
abstract class PedidoManagerEvent {
  const PedidoManagerEvent();
}

// Evento para iniciar la escucha de todos los pedidos
class LoadAllPedidos extends PedidoManagerEvent {}

// Evento interno que el BLoC usa para emitir nuevos estados al recibir datos del stream
class PedidosUpdated extends PedidoManagerEvent {
  final List<PedidoModel> pedidos;
  const PedidosUpdated(this.pedidos);
}

// Evento para crear un nuevo pedido
class CreateNewPedido extends PedidoManagerEvent {
  final String clienteNombre;
  final String direccionEntrega;
  final double valorTotal;
  const CreateNewPedido({
    required this.clienteNombre,
    required this.direccionEntrega,
    required this.valorTotal,
  });
}

// Evento para actualizar estado (usado para Reactivar o cambiar estado)
class UpdatePedidoStatus extends PedidoManagerEvent {
  final String pedidoId;
  final EstadoPedido nuevoEstado;
  final String? nuevoRepartidorUid; // Opcional, solo si queremos reasignar

  const UpdatePedidoStatus({
    required this.pedidoId,
    required this.nuevoEstado,
    this.nuevoRepartidorUid,
  });
}

// 💡 Evento para simple soft-delete/un-delete
class HidePedido extends PedidoManagerEvent {
  final String pedidoId;
  final bool hiddenStatus; // true para archivar, false para desarchivar

  const HidePedido(this.pedidoId, this.hiddenStatus);

  @override
  List<Object> get props => [pedidoId, hiddenStatus];
}

// 💡 Evento de Gestión Avanzada (combina estado funcional y visibilidad)
class ManagerUpdatePedido extends PedidoManagerEvent {
  final String pedidoId;
  final EstadoPedido? nuevoEstado;
  final bool? hiddenStatus; // true para archivar, false para desarchivar

  const ManagerUpdatePedido({
    required this.pedidoId,
    this.nuevoEstado,
    this.hiddenStatus,
  });

  @override
  List<Object?> get props => [pedidoId, nuevoEstado, hiddenStatus];
}

// El evento DeletePedido es redundante y se elimina, ya que HidePedido maneja el soft-delete.