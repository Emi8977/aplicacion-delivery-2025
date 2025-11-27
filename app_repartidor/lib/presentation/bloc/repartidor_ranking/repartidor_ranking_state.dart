part of 'repartidor_ranking_bloc.dart';

@immutable
class RepartidorRankingState {
  final List<RankingEntry> ranking;
  final Timeframe selectedTimeframe;
  final bool isLoading;
  final String? error;

  const RepartidorRankingState({
    required this.ranking,
    required this.selectedTimeframe,
    required this.isLoading,
    this.error,
  });

  factory RepartidorRankingState.initial() {
    return const RepartidorRankingState(
      ranking: [],
      selectedTimeframe: Timeframe.week, // Valor inicial por defecto
      isLoading: false,
      error: null,
    );
  }

  RepartidorRankingState copyWith({
    List<RankingEntry>? ranking,
    Timeframe? selectedTimeframe,
    bool? isLoading,
    String? error,
  }) {
    return RepartidorRankingState(
      ranking: ranking ?? this.ranking,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      isLoading: isLoading ?? this.isLoading,
      // Si el error es null, se limpia el error existente.
      error: error,
    );
  }
}

