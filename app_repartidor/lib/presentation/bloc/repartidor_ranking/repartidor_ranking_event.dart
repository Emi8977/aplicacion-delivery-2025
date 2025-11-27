part of 'repartidor_ranking_bloc.dart';

@immutable
abstract class RepartidorRankingEvent {
  const RepartidorRankingEvent();
}

// Evento para cargar el ranking con un marco de tiempo específico
class LoadRepartidorRanking extends RepartidorRankingEvent {
  final Timeframe timeframe;
  const LoadRepartidorRanking(this.timeframe);

  @override
  String toString() => 'LoadRepartidorRanking { timeframe: $timeframe }';
}