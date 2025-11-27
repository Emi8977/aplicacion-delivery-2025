class RankingEntry {
  final String repartidorUid;
  final int pedidosCompletados;

  // Podrías añadir más datos aquí si los tienes (nombre, foto, etc.)
  final String? nombreRepartidor;

  RankingEntry({
    required this.repartidorUid,
    required this.pedidosCompletados,
    this.nombreRepartidor,
  });

  // Método de conveniencia para ordenar
  static int compare(RankingEntry a, RankingEntry b) {
    // Orden descendente (más pedidos primero)
    return b.pedidosCompletados.compareTo(a.pedidosCompletados);
  }
}