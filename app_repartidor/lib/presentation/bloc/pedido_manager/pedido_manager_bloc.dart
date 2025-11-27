// Archivo: pedido_manager/pedido_manager_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
// Asegúrate de que los imports de UseCases son correctos
import '../../../core/useCases/create_pedido_usecase.dart';
import '../../../core/useCases/manager_update_pedido_usecase.dart'; // 💡 ASUMO QUE ESTE ES EL NUEVO CASO DE USO AVANZADO
import '../../../data/models/pedido_model.dart';
import '../../../data/repositories/pedido_repository.dart';

import 'package:equatable/equatable.dart'; // 💡 Debe estar aquí
// ...

part 'pedido_manager_event.dart';
part 'pedido_manager_state.dart'; // 💡 Asegúrate que el nombre es exacto

class PedidoManagerBloc extends Bloc<PedidoManagerEvent, PedidoManagerState> {
  final CreatePedidoUseCase createPedidoUseCase;
  final ManagerUpdatePedidoUseCase managerUpdatePedidoUseCase;
  final PedidoRepository pedidoRepository;

  StreamSubscription<List<PedidoModel>>? _pedidosSubscription;

  PedidoManagerBloc({
    required this.createPedidoUseCase,
    required this.managerUpdatePedidoUseCase,
    required this.pedidoRepository,
  }) : super(PedidoManagerState.initial()) {

    // --- REGISTRO DE HANDLERS ---
    on<LoadAllPedidos>(_onLoadAllPedidos);
    on<PedidosUpdated>(_onPedidosUpdated);
    on<CreateNewPedido>(_onCreateNewPedido);
    on<UpdatePedidoStatus>(_onUpdatePedidoStatus);
    on<HidePedido>(_onHidePedido);
    on<ManagerUpdatePedido>(_onManagerUpdatePedido);
  }

  // --- HANDLERS IMPLEMENTADOS ---

  void _onLoadAllPedidos(LoadAllPedidos event, Emitter<PedidoManagerState> emit) async {
    await _pedidosSubscription?.cancel();

    emit(state.copyWith(isLoading: true, error: null));

    try {
      _pedidosSubscription = pedidoRepository.getAllPedidosStream().listen(
              (pedidos) {
            add(PedidosUpdated(pedidos));
          },
          onError: (error) {
            emit(state.copyWith(error: 'Error en el stream de pedidos: ${error.toString()}', isLoading: false));
          }
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Fallo al iniciar la escucha de pedidos: ${e.toString()}',
      ));
    }
  }

  void _onPedidosUpdated(PedidosUpdated event, Emitter<PedidoManagerState> emit) {
    emit(state.copyWith(
      allPedidos: event.pedidos,
      isLoading: false,
      error: null,
    ));
  }

  void _onCreateNewPedido(CreateNewPedido event, Emitter<PedidoManagerState> emit) async {
    emit(state.copyWith(error: null));
    const String managerId = 'MGR001_Test';

    try {
      await createPedidoUseCase(
        managerUid: managerId,
        clienteNombre: event.clienteNombre,
        direccionEntrega: event.direccionEntrega,
        valorTotal: event.valorTotal,
      );
    } catch (e) {
      emit(state.copyWith(
        error: 'Fallo al crear el pedido: ${e.toString()}',
      ));
    }
  }

  void _onUpdatePedidoStatus(
      UpdatePedidoStatus event,
      Emitter<PedidoManagerState> emit,
      ) async {
    emit(state.copyWith(error: null));
    try {
      await pedidoRepository.updatePedido(
        pedidoId: event.pedidoId,
        estado: event.nuevoEstado,
        repartidorUid: event.nuevoRepartidorUid,
      );
    } catch (e) {
      emit(state.copyWith(
        error: 'Error al actualizar el estado del pedido: ${e.toString()}',
      ));
    }
  }

  // ----------------------------------------------------
  // 💡 HANDLER DE OCULTAR/MOSTRAR (SIN RECARGA MANUAL)
  // ----------------------------------------------------
  void _onHidePedido(
      HidePedido event,
      Emitter<PedidoManagerState> emit,
      ) async {
    emit(state.copyWith(error: null));
    try {
      await managerUpdatePedidoUseCase(
        pedidoId: event.pedidoId,
        hiddenStatus: event.hiddenStatus,
      );
      // El stream del repositorio notificará el cambio (no se necesita add(LoadAllPedidos()))
    } catch (e) {
      emit(state.copyWith(
        error: 'Error al ocultar/mostrar el pedido: ${e.toString()}',
      ));
    }
  }

  // ----------------------------------------------------
  // 💡 HANDLER DE GESTIÓN AVANZADA (SIN RECARGA MANUAL)
  // ----------------------------------------------------
  Future<void> _onManagerUpdatePedido(
      ManagerUpdatePedido event,
      Emitter<PedidoManagerState> emit,
      ) async {
    emit(state.copyWith(error: null));
    try {
      await managerUpdatePedidoUseCase(
        pedidoId: event.pedidoId,
        nuevoEstado: event.nuevoEstado,
        hiddenStatus: event.hiddenStatus,
      );
      // El stream del repositorio notificará el cambio (no se necesita add(LoadAllPedidos()))
    } catch (e) {
      emit(state.copyWith(
        error: 'Error de gestión avanzada: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    _pedidosSubscription?.cancel();
    return super.close();
  }
}
