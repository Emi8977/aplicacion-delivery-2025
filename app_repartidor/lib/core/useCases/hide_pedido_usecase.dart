// Archivo: lib/core/useCases/hide_pedido_usecase.dart

import '../../data/repositories/pedido_repository.dart';

class HidePedidoUseCase {
  final PedidoRepository repository;

  HidePedidoUseCase(this.repository);

  // Oculta el pedido (configura hidden = true)
  Future<void> hide(String pedidoId) async {
    await repository.hidePedido(pedidoId, hiddenStatus: true);
  }

  // Opcional: Reactiva el pedido (configura hidden = false), útil para la UI del manager.
  Future<void> unhide(String pedidoId) async {
    await repository.hidePedido(pedidoId, hiddenStatus: false);
  }
}