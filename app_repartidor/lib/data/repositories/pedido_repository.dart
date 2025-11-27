// Importa la definición del modelo para PedidoModel y EstadoPedido (si está allí)
// DEBES AJUSTAR esta importación para que apunte a donde realmente está definido EstadoPedido.
import '../models/pedido_model.dart';
import '../models/ranking_entry_model.dart';
import '../../utils/enums.dart'; // Importa Timeframe
import 'dart:async'; // Necesario para Stream

// Este es el contrato que debe seguir PedidoRepositoryImpl
abstract class PedidoRepository {

  // ** NUEVO: Obtiene TODOS los pedidos como un Stream para reactividad **
  Stream<List<PedidoModel>> getAllPedidosStream();

  // Métodos CRUD
  Future<List<PedidoModel>> getAll();
  Future<PedidoModel> crearPedido(PedidoModel pedido);
  Future<PedidoModel?> getById(String id);
  Future<PedidoModel> update(PedidoModel pedido);
  Future<void> eliminarPedido(String id);

  // Métodos Específicos de Repartidor/Gestión
  Future<List<PedidoModel>> getPedidosAsignados(String repartidorUid);
  Future<List<PedidoModel>> getAvailablePedidos();
  Future<void> assignCourier(String pedidoId, String repartidorUid);

  // MÉTODO CONFLICTIVO 1: Usamos nombres para mayor claridad, pero la implementación
  // debe coincidir: (String pedidoId, EstadoPedido nuevoEstado)
  Future<void> updatePedidoStatus(String pedidoId, EstadoPedido nuevoEstado);

  Future<void> returnToWarehouse(String pedidoId);

  // MÉTODO CONFLICTIVO 2: La firma con argumentos nombrados (required)
  Future<void> updatePedido({
    required String pedidoId, // <-- La implementación DEBE tener 'required' aquí
    EstadoPedido? estado,
    String? repartidorUid,
  });
/////
  // 👇 AQUÍ DEBE IR EL MÉTODO managerUpdatePedido CON EL PARÁMETRO repartidorUid
  Future<void> managerUpdatePedido({
    required String pedidoId,
    EstadoPedido? estado,
    bool? hidden,
    String? repartidorUid, // 💡 AGREGAR ESTE PARÁMETRO
  });

  // ** NUEVO: Método para el ranking **
  Future<List<RankingEntry>> getRankingRepartidores(Timeframe timeframe);

  // Método para marcar como entregado y registrar el tiempo final
  Future<void> completeDelivery(String pedidoId);

  // NUEVO MÉTODO: Oculta el pedido (Soft Delete)
  Future<void> hidePedido(String id, {required bool hiddenStatus});

  // 💡 NUEVO MÉTODO: Obtiene TODOS los pedidos (activos, entregados, cancelados) del courier.
  Future<List<PedidoModel>> getAllCourierOrders(String repartidorUid);

}