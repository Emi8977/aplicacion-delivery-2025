import '../../data/models/pedido_model.dart';
import '../../data/repositories/pedido_repository.dart';
// Asegúrate de que EstadoPedido se puede importar aquí (ej: a través de PedidoModel.dart)

class UpdatePedidoStatusUseCase {
  final PedidoRepository repository;

  UpdatePedidoStatusUseCase(this.repository);

  // 1. MÉTODO: CLAIM (Tomar Pedido)
  // Lógica: Asigna repartidor y cambia estado a EN_CURSO.
  // IMPORTANTE: repository.assignCourier() ya inicia el cronómetro.
  Future<PedidoModel> claimPedido(String pedidoId, String courierUid) async {
    final pedido = await repository.getById(pedidoId);

    if (pedido == null) {
      throw Exception("Pedido no encontrado.");
    }

    if (pedido.repartidorUid != null) {
      throw Exception("Este pedido ya fue tomado por otro repartidor.");
    }

    // Llama al método atómico del repositorio: assignCourier(), que registra el TIEMPO DE INICIO.
    await repository.assignCourier(pedidoId, courierUid);

    // Obtenemos el pedido actualizado para devolver el modelo
    final updatedPedido = await repository.getById(pedidoId);
    return updatedPedido!;
  }

  // 2. MÉTODO DE ESTADO
  // Lógica: Actualiza el estado, con manejo especial para Entrega (Fin de Cronómetro)
  Future<PedidoModel> updateStatus({
    required String pedidoId,
    required EstadoPedido nuevoEstado,
  }) async {
    final pedido = await repository.getById(pedidoId);

    if (pedido == null) {
      throw Exception("Pedido no encontrado.");
    }

    // Previene el cambio si el estado es el mismo
    if (pedido.estado == nuevoEstado) {
      return pedido;
    }

    // --- LÓGICA DEL CRONÓMETRO Y ESTADO FINAL ---
    if (nuevoEstado == EstadoPedido.entregado) {
      // **NUEVO:** Llama al método especializado que registra el TIEMPO DE FIN.
      await repository.completeDelivery(pedidoId);
    } else if (nuevoEstado == EstadoPedido.cancelado) {
      // Si el estado es cancelado (Devolver a Depósito), usa la lógica de devolución
      await repository.returnToWarehouse(pedidoId);
    } else {
      // Para otros estados que no registran tiempo (ej: si se implementara "espera")
      await repository.updatePedidoStatus(pedidoId, nuevoEstado);
    }
    // ----------------------------------------------

    // Obtenemos el pedido actualizado para devolver el modelo
    final updatedPedido = await repository.getById(pedidoId);
    return updatedPedido!;
  }
}