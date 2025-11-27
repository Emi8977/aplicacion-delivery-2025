// Archivo: pedido_manager/pedido_manager_state.dart

part of 'pedido_manager_bloc.dart';

class PedidoManagerState extends Equatable {
  final List<PedidoModel> allPedidos;
  final bool isLoading;
  final String? error;

  const PedidoManagerState({
    required this.allPedidos,
    this.isLoading = false,
    this.error,
  });

  factory PedidoManagerState.initial() {
    return const PedidoManagerState(allPedidos: []);
  }

  PedidoManagerState copyWith({
    List<PedidoModel>? allPedidos,
    bool? isLoading,
    // Usamos 'error' como String? para que puedas pasar null y limpiar el error.
    String? error,
  }) {
    return PedidoManagerState(
      allPedidos: allPedidos ?? this.allPedidos,
      isLoading: isLoading ?? this.isLoading,
      // Si se pasa 'error: null', se limpia. Si se pasa un String, se actualiza.
      error: error,
    );
  }

  @override
  List<Object?> get props => [allPedidos, isLoading, error];
}