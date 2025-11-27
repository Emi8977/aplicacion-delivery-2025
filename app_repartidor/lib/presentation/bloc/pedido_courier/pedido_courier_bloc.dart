import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_repartidor/data/repositories/pedido_repository.dart';
import 'package:app_repartidor/core/useCases/update_pedido_status_usecase.dart';
import 'package:app_repartidor/core/useCases/get_pedidos_available_usecase.dart';

import '../../../data/models/pedido_model.dart';
// Asegúrate de que esta sea la ruta correcta para el enum EstadoPedido
import '../../../utils/enums.dart';

import 'pedido_courier_event.dart';
import 'pedido_courier_state.dart';


class PedidoCourierBloc extends Bloc<PedidoCourierEvent, PedidoCourierState> {
  final GetPedidosAvailableUseCase getAvailablePedidosUseCase;
  final UpdatePedidoStatusUseCase updatePedidoStatusUseCase;
  final PedidoRepository pedidoRepository;
  final String currentCourierUid;

  PedidoCourierBloc({
    required this.getAvailablePedidosUseCase,
    required this.updatePedidoStatusUseCase,
    required this.pedidoRepository,
    required this.currentCourierUid,
  }) : super(const PedidoCourierState()) {
    on<LoadPedidosInitial>(_onLoadPedidosInitial);
    on<ClaimPedidoRequested>(_onClaimPedidoRequested);
    on<UpdateStatusRequested>(_onUpdateStatusRequested);
    on<ReturnPedidoToWarehouseRequested>(_onReturnPedidoToWarehouseRequested);
  }

  // --- Lógica de Carga Inicial (Separando Activos y Entregados) ---

  Future<void> _onLoadPedidosInitial(
      LoadPedidosInitial event,
      Emitter<PedidoCourierState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // 💡 CAMBIO CRÍTICO: Usamos getAllCourierOrders para traer TODOS (activos + entregados/cancelados)
      final allCourierOrders = await pedidoRepository.getAllCourierOrders(currentCourierUid);
      final available = await getAvailablePedidosUseCase.call();

      // 1. Separar pedidos activos (pendiente y en_curso)
      final myActivePedidos = allCourierOrders.where((p) {
        return p.estado != EstadoPedido.entregado && p.estado != EstadoPedido.cancelado;
      }).toList();

      // 2. Separar pedidos entregados (para el historial)
      final myDeliveredPedidos = allCourierOrders.where((p) {
        return p.estado == EstadoPedido.entregado;
      }).toList();


      emit(state.copyWith(
        availablePedidos: available,
        myPedidos: myActivePedidos,
        deliveredPedidos: myDeliveredPedidos,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar pedidos: ${e.toString()}',
      ));
    }
  }

  // --- Lógica para Tomar Pedido ---

  Future<void> _onClaimPedidoRequested(
      ClaimPedidoRequested event,
      Emitter<PedidoCourierState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, error: null));

    if (currentCourierUid == 'anonymous_user') {
      emit(state.copyWith(
        isLoading: false,
        error: 'Debe iniciar sesión para tomar pedidos.',
      ));
      return;
    }

    try {
      await updatePedidoStatusUseCase.claimPedido(
        event.pedidoId,
        currentCourierUid,
      );

      // Recargar para mover el pedido de "Disponibles" a "Mis Pedidos"
      add(LoadPedidosInitial());

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al tomar el pedido: ${e.toString()}',
      ));
    }
  }

  // --- Lógica para Actualizar Estado (Sin Aviso Emergente) ---

  Future<void> _onUpdateStatusRequested(
      UpdateStatusRequested event,
      Emitter<PedidoCourierState> emit,
      ) async {
    // Usamos isLoading: true para bloquear la UI mientras se actualiza la BD
    emit(state.copyWith(isLoading: true, error: null));
    try {

      if (event.nuevoEstado == EstadoPedido.entregado) {
        // Al entregar, usamos el método especializado del Repositorio para registrar el tiempo de FIN.
        await pedidoRepository.completeDelivery(event.pedidoId);
      } else {
        // Para cualquier otro cambio de estado.
        await updatePedidoStatusUseCase.updateStatus(
          pedidoId: event.pedidoId,
          nuevoEstado: event.nuevoEstado,
        );
      }

      // Recargar para que el pedido entregado se mueva de 'myPedidos' a 'deliveredPedidos'
      add(LoadPedidosInitial());

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al actualizar el estado: ${e.toString()}',
      ));
    }
  }

  // --- Lógica para Devolver a Depósito ---

  Future<void> _onReturnPedidoToWarehouseRequested(
      ReturnPedidoToWarehouseRequested event,
      Emitter<PedidoCourierState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Establecer el estado a cancelado y desasignar el repartidor
      await updatePedidoStatusUseCase.updateStatus(
        pedidoId: event.pedidoId,
        nuevoEstado: EstadoPedido.cancelado,
      );

      // Recargar para que el pedido desaparezca de la lista activa
      add(LoadPedidosInitial());

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al devolver el pedido: ${e.toString()}',
      ));
    }
  }
}