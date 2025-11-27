import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:rxdart/rxdart.dart';

// ⚠️ AJUSTA ESTOS IMPORTS A TUS RUTAS REALES
import '../../data/models/pedido_model.dart';
import '../../utils/enums.dart'; // Contiene Timeframe, EstadoPedido
import '../models/ranking_entry_model.dart';
import '../repositories/pedido_repository.dart'; // Tu abstract class

class PedidoRepositoryImpl implements PedidoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pedidos';

  // ===================================================================
  // IMPLEMENTACIONES CRUD BÁSICAS
  // ===================================================================

  @override
  Stream<List<PedidoModel>> getAllPedidosStream() {
    // Implementación para el Manager con de-duplicación
    final visiblePedidosStream = _firestore.collection(_collection)
        .where('hidden', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PedidoModel.fromJson(doc.data()!, doc.id)).toList());

    final nullPedidosStream = _firestore.collection(_collection)
        .where('hidden', isEqualTo: null)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PedidoModel.fromJson(doc.data()!, doc.id)).toList());

    return CombineLatestStream.list<List<PedidoModel>>([
      visiblePedidosStream,
      nullPedidosStream,
    ]).map((listOfLists) {
      final allPedidos = listOfLists.expand((list) => list).toList();
      final Map<String, PedidoModel> uniquePedidosMap = {};
      for (var pedido in allPedidos) {
        uniquePedidosMap[pedido.id!] = pedido;
      }
      return uniquePedidosMap.values.toList();
    });
  }

  @override
  Future<List<PedidoModel>> getAll() async {
    // Implementación para el Manager (Future) con de-duplicación
    try {
      final futureVisible = _firestore.collection(_collection)
          .where('hidden', isEqualTo: false)
          .get();

      final futureNull = _firestore.collection(_collection)
          .where('hidden', isEqualTo: null)
          .get();

      final results = await Future.wait([futureVisible, futureNull]);
      final combinedDocs = results.expand((snapshot) => snapshot.docs).toList();

      final Map<String, PedidoModel> uniquePedidosMap = {};
      for (var doc in combinedDocs) {
        final pedido = PedidoModel.fromJson(doc.data()!, doc.id);
        uniquePedidosMap[pedido.id!] = pedido;
      }
      return uniquePedidosMap.values.toList();
    } catch (e) {
      developer.log('ERROR al obtener todos los pedidos (Future): $e', name: 'Firestore ERROR');
      rethrow;
    }
  }

  @override
  Future<PedidoModel> crearPedido(PedidoModel pedido) async {
    // 💡 Implementación faltante: crearPedido
    final docRef = await _firestore.collection(_collection).add(pedido.toJson()..['hidden'] = false);
    return pedido.copyWith(id: docRef.id);
  }

  @override
  Future<PedidoModel?> getById(String id) async {
    // 💡 Implementación faltante: getById
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return PedidoModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<PedidoModel> update(PedidoModel pedido) async {
    // 💡 Implementación faltante: update
    if (pedido.id == null) {
      throw Exception("El PedidoModel debe tener un ID para ser actualizado.");
    }
    await _firestore.collection(_collection).doc(pedido.id!).set(
        pedido.toJson(),
        SetOptions(merge: true)
    );
    return pedido;
  }

  @override
  Future<void> eliminarPedido(String id) async {
    // 💡 Implementación faltante: eliminarPedido (Hard Delete)
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<void> hidePedido(String id, {required bool hiddenStatus}) async {
    // 💡 Implementación faltante: hidePedido (Soft Delete)
    await _firestore.collection(_collection).doc(id).update({
      'hidden': hiddenStatus,
    });
  }

  // ===================================================================
  // IMPLEMENTACIONES ESPECÍFICAS DE REPARTIDOR/MANAGER
  // ===================================================================

  // 💡 NUEVA IMPLEMENTACIÓN: Trae TODOS los pedidos del repartidor (para el BLoC/Historial)
  @override
  Future<List<PedidoModel>> getAllCourierOrders(String repartidorUid) async {
    try {
      // ❌ NO usamos whereNotIn. Solo filtramos por el repartidorUid y 'hidden'.
      final futureVisible = _firestore.collection(_collection)
          .where('repartidorUid', isEqualTo: repartidorUid)
          .where('hidden', isEqualTo: false)
          .get();

      final futureNull = _firestore.collection(_collection)
          .where('repartidorUid', isEqualTo: repartidorUid)
          .where('hidden', isEqualTo: null)
          .get();

      final results = await Future.wait([futureVisible, futureNull]);
      final combinedDocs = results.expand((snapshot) => snapshot.docs).toList();

      final Map<String, PedidoModel> uniquePedidosMap = {};
      for (var doc in combinedDocs) {
        final pedido = PedidoModel.fromJson(doc.data()!, doc.id);
        uniquePedidosMap[pedido.id!] = pedido;
      }
      return uniquePedidosMap.values.toList();
    } catch (e) {
      developer.log('ERROR al obtener TODOS los pedidos del courier: $e', name: 'Firestore ERROR');
      rethrow;
    }
  }


  @override
  Future<List<PedidoModel>> getPedidosAsignados(String repartidorUid) async {
    // ⚠️ IMPLEMENTACIÓN ORIGINAL: Esta función ES LA QUE DEBE FILTRAR
    // Solo trae pedidos ACTIVO (pendiente/en_curso) para la lista principal.
    try {
      final estadoEntregado = EstadoPedido.entregado.toString().split('.').last;
      final estadoCancelado = EstadoPedido.cancelado.toString().split('.').last;
      final excludeStates = [estadoEntregado, estadoCancelado]; // Excluye los finalizados

      final futureVisible = _firestore.collection(_collection)
          .where('repartidorUid', isEqualTo: repartidorUid)
          .where('hidden', isEqualTo: false)
          .where('estado', whereNotIn: excludeStates) // 👈 Filtro clave (Mantiene solo activos)
          .get();

      final futureNull = _firestore.collection(_collection)
          .where('repartidorUid', isEqualTo: repartidorUid)
          .where('hidden', isEqualTo: null)
          .where('estado', whereNotIn: excludeStates)
          .get();

      final results = await Future.wait([futureVisible, futureNull]);
      final combinedDocs = results.expand((snapshot) => snapshot.docs).toList();

      final Map<String, PedidoModel> uniquePedidosMap = {};
      for (var doc in combinedDocs) {
        final pedido = PedidoModel.fromJson(doc.data()!, doc.id);
        uniquePedidosMap[pedido.id!] = pedido;
      }
      return uniquePedidosMap.values.toList();
    } catch (e) {
      developer.log('ERROR al obtener pedidos asignados (activos): $e', name: 'Firestore ERROR');
      rethrow;
    }
  }

  @override
  Future<List<PedidoModel>> getAvailablePedidos() async {
    // Implementación de Courier
    try {
      final estadoPendiente = EstadoPedido.pendiente.toString().split('.').last;

      final futureVisible = _firestore.collection(_collection)
          .where('repartidorUid', isEqualTo: null)
          .where('estado', isEqualTo: estadoPendiente)
          .where('hidden', isEqualTo: false)
          .get();

      final futureNull = _firestore.collection(_collection)
          .where('repartidorUid', isEqualTo: null)
          .where('estado', isEqualTo: estadoPendiente)
          .where('hidden', isEqualTo: null)
          .get();

      final results = await Future.wait([futureVisible, futureNull]);
      final combinedDocs = results.expand((snapshot) => snapshot.docs).toList();

      final Map<String, PedidoModel> uniquePedidosMap = {};
      for (var doc in combinedDocs) {
        final pedido = PedidoModel.fromJson(doc.data()!, doc.id);
        uniquePedidosMap[pedido.id!] = pedido;
      }
      return uniquePedidosMap.values.toList();
    } catch (e) {
      developer.log('ERROR al obtener pedidos disponibles: $e', name: 'Firestore ERROR');
      rethrow;
    }
  }

  @override
  Future<void> assignCourier(String pedidoId, String repartidorUid) async {
    // 💡 Implementación faltante: assignCourier (Inicia cronómetro)
    final int inicioMilisegundos = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection(_collection).doc(pedidoId).update({
      'repartidorUid': repartidorUid,
      'estado': EstadoPedido.en_curso.toString().split('.').last,
      'arrayCronometro': FieldValue.arrayUnion([inicioMilisegundos]),
    });
  }

  @override
  Future<void> updatePedidoStatus(String pedidoId, EstadoPedido nuevoEstado) async {
    // 💡 Implementación faltante: updatePedidoStatus
    await _firestore.collection(_collection).doc(pedidoId).update({
      'estado': nuevoEstado.toString().split('.').last,
    });
  }

  @override
  Future<void> returnToWarehouse(String pedidoId) async {
    // 💡 Implementación faltante: returnToWarehouse (Estado cancelado y quita courier)
    await _firestore.collection(_collection).doc(pedidoId).update({
      'estado': EstadoPedido.cancelado.toString().split('.').last,
      'repartidorUid': FieldValue.delete(),
    });
  }

  @override
  Future<void> completeDelivery(String pedidoId) async {
    // 💡 Implementación faltante: completeDelivery (Finaliza cronómetro)
    final int finMilisegundos = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection(_collection).doc(pedidoId).update({
      'estado': EstadoPedido.entregado.toString().split('.').last,
      'arrayCronometro': FieldValue.arrayUnion([finMilisegundos]),
    });
  }

  @override
  Future<void> updatePedido({
    required String pedidoId,
    EstadoPedido? estado,
    String? repartidorUid,
  }) async {
    // 💡 Implementación faltante: updatePedido (General, para Manager o Courier)
    final Map<String, dynamic> updates = {};

    if (estado != null) {
      updates['estado'] = estado.toString().split('.').last;
    }

    if (repartidorUid != null) {
      updates['repartidorUid'] = repartidorUid;
    } else if (estado == EstadoPedido.pendiente) {
      updates['repartidorUid'] = FieldValue.delete();
    }

    if (updates.isEmpty) return;

    try {
      await _firestore.collection(_collection).doc(pedidoId).update(updates);
    } catch (e) {
      developer.log('ERROR al actualizar pedido $pedidoId: $e', name: 'Firestore ERROR');
      rethrow;
    }
  }

  @override
  Future<void> managerUpdatePedido({
    required String pedidoId,
    EstadoPedido? estado,
    bool? hidden,
    String? repartidorUid, // Se incluye para coincidir con la implementación
  }) async {
    // 💡 Implementación faltante: managerUpdatePedido
    final Map<String, dynamic> updates = {};

    if (estado != null) {
      updates['estado'] = estado.toString().split('.').last;

      if (estado == EstadoPedido.pendiente) {
        updates['repartidorUid'] = FieldValue.delete();
      }
    }

    if (hidden != null) {
      updates['hidden'] = hidden;
    }

    if (updates.isEmpty) return;
    await _firestore.collection('pedidos').doc(pedidoId).update(updates);
  }

  @override
  Future<List<RankingEntry>> getRankingRepartidores(Timeframe timeframe) async {
    // 💡 Implementación faltante: getRankingRepartidores
    final startDate = _getStartDate(timeframe);
    final estadoEntregado = EstadoPedido.entregado.toString().split('.').last;

    try {
      final querySnapshot = await _firestore.collection(_collection)
          .where('estado', isEqualTo: estadoEntregado)
          .where('fechaCreacion', isGreaterThanOrEqualTo: startDate)
          .get();

      final Map<String, int> counts = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final repartidorUid = data['repartidorUid'] as String?;
        if (repartidorUid != null && repartidorUid.isNotEmpty) {
          counts[repartidorUid] = (counts[repartidorUid] ?? 0) + 1;
        }
      }

      final List<RankingEntry> ranking = counts.entries.map((entry) {
        return RankingEntry(
          repartidorUid: entry.key,
          pedidosCompletados: entry.value,
        );
      }).toList();

      ranking.sort((a, b) => b.pedidosCompletados.compareTo(a.pedidosCompletados));
      return ranking;
    } catch (e) {
      developer.log('ERROR al obtener el ranking de repartidores: $e', name: 'Firestore ERROR');
      rethrow;
    }
  }

  // --- AUXILIARES ---
  DateTime _getStartDate(Timeframe timeframe) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeframe) {
      case Timeframe.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case Timeframe.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case Timeframe.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }
    return startDate;
  }
}