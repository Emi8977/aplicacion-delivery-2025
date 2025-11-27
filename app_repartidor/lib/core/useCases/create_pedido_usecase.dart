import 'package:uuid/uuid.dart';
import '../../data/models/pedido_model.dart';
import '../../data/repositories/pedido_repository.dart';

class CreatePedidoUseCase {
  final PedidoRepository repository;
  final Uuid uuid;

  CreatePedidoUseCase(this.repository, this.uuid);

  Future<PedidoModel> call({
    required String managerUid,
    required String clienteNombre,
    required String direccionEntrega,
    required double valorTotal, // Cambiado de 'total' a 'valorTotal'
  }) async {
    // 1. Crear el PedidoModel con valores iniciales
    final PedidoModel newPedido = PedidoModel(
      // Usamos el UID del Manager como el UID del cliente/creador del registro
      clienteUid: managerUid,
      clienteNombre: clienteNombre,
      direccionEntrega: direccionEntrega,
      fechaCreacion: DateTime.now(),
      repartidorUid: null, // Inicialmente nulo (disponible)
      estado: EstadoPedido.pendiente,
      valorTotal: valorTotal,
      arrayCronometro: [], // Inicialmente vacío
    );

    // 2. Llamar al repositorio para guardar
    return await repository.crearPedido(newPedido);
  }
}