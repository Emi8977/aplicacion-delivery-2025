// Archivo: core/useCases/manager_update_pedido_usecase.dart

import 'package:app_repartidor/data/repositories/pedido_repository.dart'; // Ajusta la ruta a tu repositorio
import 'package:app_repartidor/data/models/pedido_model.dart'; // Importa EstadoPedido

// Este Caso de Uso gestiona la lógica de Manager para cambiar estado y visibilidad
class ManagerUpdatePedidoUseCase {
  final PedidoRepository repository;

  ManagerUpdatePedidoUseCase(this.repository);

  // El método call permite usar el caso de uso como una función: instance(params)
  Future<void> call({
    required String pedidoId,
    EstadoPedido? nuevoEstado,
    bool? hiddenStatus,
  }) async {
    // 💡 Lógica de Negocio Opcional:
    // Aquí podrías agregar validaciones o reglas antes de interactuar con el repositorio.
    // Por ejemplo:
    // if (pedidoId.isEmpty) {
    //   throw Exception('El ID del pedido no puede estar vacío.');
    // }

    // Llama al método del repositorio que implementamos para la gestión avanzada
    await repository.managerUpdatePedido(
      pedidoId: pedidoId,
      estado: nuevoEstado,
      hidden: hiddenStatus,
    );
  }
}