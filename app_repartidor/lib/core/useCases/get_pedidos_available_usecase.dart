import '../../data/models/pedido_model.dart';
import '../../data/repositories/pedido_repository.dart';

class GetPedidosAvailableUseCase {
  // El Use Case solo conoce el contrato (la interfaz).
  final PedidoRepository repository;

  GetPedidosAvailableUseCase(this.repository);

  // El método 'call' ejecuta la lógica principal del caso de uso.
  Future<List<PedidoModel>> call() async {
    // Llama al método de la interfaz. La implementación concreta (e.g., PedidoRepositoryImpl)
    // es la responsable de la lógica optimizada de consulta a la base de datos.
    return await repository.getAvailablePedidos();
  }
}