import 'package:equatable/equatable.dart';
// Aseguramos la importación de EstadoPedido, ajusta la ruta si es necesario
import '../../../data/models/pedido_model.dart';

abstract class PedidoCourierEvent extends Equatable {
  const PedidoCourierEvent();

  @override
  List<Object> get props => [];
}

class LoadPedidosInitial extends PedidoCourierEvent {}

class UpdateAssignedPedidos extends PedidoCourierEvent {
  final List<dynamic> assignedPedidos;
  const UpdateAssignedPedidos(this.assignedPedidos);

  @override
  List<Object> get props => [assignedPedidos];
}

class UpdateAvailablePedidos extends PedidoCourierEvent {
  final List<dynamic> availablePedidos;
  const UpdateAvailablePedidos(this.availablePedidos);

  @override
  List<Object> get props => [availablePedidos];
}

class ClaimPedidoRequested extends PedidoCourierEvent {
  final String pedidoId;
  const ClaimPedidoRequested(this.pedidoId);

  @override
  List<Object> get props => [pedidoId];
}

// Usamos el enum EstadoPedido directamente
class UpdateStatusRequested extends PedidoCourierEvent {
  final String pedidoId;
  final EstadoPedido nuevoEstado;
  const UpdateStatusRequested(this.pedidoId, this.nuevoEstado);

  @override
  List<Object> get props => [pedidoId, nuevoEstado];
}

// Solicitud de devolver un pedido al depósito
class ReturnPedidoToWarehouseRequested extends PedidoCourierEvent {
  final String pedidoId;
  const ReturnPedidoToWarehouseRequested(this.pedidoId);

  @override
  List<Object> get props => [pedidoId];
}

// 💡 NUEVO EVENTO: Se usa para limpiar el estado de notificación después de que el listener
// haya mostrado el diálogo de entrega, evitando el bucle de renderizado/congelamiento.
class ClearCompletionState extends PedidoCourierEvent {}