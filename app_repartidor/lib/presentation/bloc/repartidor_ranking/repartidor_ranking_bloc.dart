import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'dart:developer' as developer;
// Asegúrate de que estas importaciones apunten a las ubicaciones correctas
import '../../../data/repositories/pedido_repository.dart';
import '../../../utils/enums.dart'; // Importa Timeframe
import '../../../data/models/ranking_entry_model.dart'; // Importa RankingEntry

part 'repartidor_ranking_event.dart';
part 'repartidor_ranking_state.dart';

class RepartidorRankingBloc extends Bloc<RepartidorRankingEvent, RepartidorRankingState> {
  final PedidoRepository pedidoRepository;

  RepartidorRankingBloc({required this.pedidoRepository})
      : super(RepartidorRankingState.initial()) {

    on<LoadRepartidorRanking>(_onLoadRepartidorRanking);
  }

  void _onLoadRepartidorRanking(
      LoadRepartidorRanking event,
      Emitter<RepartidorRankingState> emit
      ) async {
    // 1. Emitir estado de carga y actualizar el marco de tiempo seleccionado
    emit(state.copyWith(
        isLoading: true,
        selectedTimeframe: event.timeframe,
        error: null // Limpiamos errores anteriores
    ));

    try {
      // 2. Llamar al repositorio para obtener los datos de ranking
      final ranking = await pedidoRepository.getRankingRepartidores(event.timeframe);

      developer.log('Ranking cargado exitosamente para ${event.timeframe}', name: 'RankingBloc');

      // 3. Emitir estado exitoso con los datos
      emit(state.copyWith(
        ranking: ranking,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      developer.log('Error en _onLoadRepartidorRanking: $e', name: 'RankingBloc ERROR');
      // 4. Emitir estado de error
      emit(state.copyWith(
        isLoading: false,
        // Limpiamos la lista para mostrar un estado claro de error
        ranking: [],
        error: 'No se pudo cargar el ranking. Intente de nuevo: ${e.toString()}',
      ));
    }
  }
}