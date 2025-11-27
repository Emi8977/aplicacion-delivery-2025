// Archivo: PedidoCourierState.dart

import '../../../data/models/pedido_model.dart';

class PedidoCourierState {
  final List<PedidoModel> availablePedidos;
  final List<PedidoModel> myPedidos;
  final List<PedidoModel> deliveredPedidos; // 💡 NUEVO CAMPO
  final bool isLoading;
  final String? error;

  const PedidoCourierState({
    this.availablePedidos = const [],
    this.myPedidos = const [],
    this.deliveredPedidos = const [], // 💡 Inicialización
    this.isLoading = false,
    this.error,
  });

  PedidoCourierState copyWith({
    List<PedidoModel>? availablePedidos,
    List<PedidoModel>? myPedidos,
    List<PedidoModel>? deliveredPedidos, // 💡 Incluido en copyWith
    bool? isLoading,
    String? error,
    bool clearError = false, // Opción para limpiar el error explícitamente
  }) {
    final newError = clearError ? null : (error ?? this.error);

    return PedidoCourierState(
      availablePedidos: availablePedidos ?? this.availablePedidos,
      myPedidos: myPedidos ?? this.myPedidos,
      deliveredPedidos: deliveredPedidos ?? this.deliveredPedidos, // 💡 Asignación
      isLoading: isLoading ?? this.isLoading,
      error: newError,
    );
  }
}