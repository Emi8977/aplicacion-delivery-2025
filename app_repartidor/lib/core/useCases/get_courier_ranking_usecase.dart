import '../../data/models/usuario_model.dart'; // Fuente única para UsuarioModel y UsuarioRole
import '../../data/models/pedido_model.dart'; // Fuente única para PedidoModel y EstadoPedido
import '../../data/repositories/pedido_repository.dart';

// Modelo simple para el ranking
class CourierRankingItem {
  final UsuarioModel courier;
  final int pedidosEntregados;

  CourierRankingItem({required this.courier, required this.pedidosEntregados});
}

class GetCourierRankingUseCase {
  final PedidoRepository pedidoRepository;

  GetCourierRankingUseCase(this.pedidoRepository);

  Future<List<CourierRankingItem>> call() async {
    // 1. Obtener todos los pedidos
    final allPedidos = await pedidoRepository.getAll();

    // 2. Filtrar solo los pedidos ENTREGADOS y que tengan un repartidor asignado
    final deliveredPedidos = allPedidos.where((p) =>
    // CORRECCIÓN 1: Usar el estado enum
    p.estado == EstadoPedido.entregado &&
        // CORRECCIÓN 2: Asegurar que repartidorUid NO sea nulo
        p.repartidorUid != null
    ).toList();

    // 3. Contar los pedidos por cada repartidor (Map<String, int>)
    final Map<String, int> deliveryCounts = {};
    for (var pedido in deliveredPedidos) {
      final uid = pedido.repartidorUid!;
      deliveryCounts[uid] = (deliveryCounts[uid] ?? 0) + 1;
    }

    // 4. Mapear a objetos de ranking
    final rankingList = deliveryCounts.entries.map((entry) {
      // Simulación de obtener datos del usuario.
      // Ya NO necesitamos pasar arrayCronometro.
      final dummyUser = UsuarioModel(
        uid: entry.key,
        nombre: 'Repartidor ${entry.key.substring(0, 4)}...',
        email: 'repartidor_${entry.key}@app.com',
        telefono: 'N/A',
        role: UsuarioRole.courier,
      );

      return CourierRankingItem(
        courier: dummyUser,
        pedidosEntregados: entry.value,
      );
    }).toList();

    // 5. Ordenar por la cantidad de pedidos entregados (descendente)
    rankingList.sort((a, b) => b.pedidosEntregados.compareTo(a.pedidosEntregados));

    return rankingList;
  }
}