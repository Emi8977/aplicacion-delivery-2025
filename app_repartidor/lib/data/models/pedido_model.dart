import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoPedido {
  pendiente,
  en_curso,
  entregado,
  cancelado,
}

class PedidoModel {
  final String? id;
  final String clienteUid;
  final String clienteNombre;
  final String direccionEntrega;
  final DateTime fechaCreacion;

  final String? repartidorUid;
  final EstadoPedido estado;
  final double valorTotal;
  final List<int> arrayCronometro;
  // 💡 CAMPO NUEVO PARA EL SOFT-DELETE
  final bool? hidden;

  PedidoModel({
    this.id,
    required this.clienteUid,
    required this.clienteNombre,
    required this.direccionEntrega,
    required this.fechaCreacion,
    this.repartidorUid,
    required this.estado,
    required this.valorTotal,
    required this.arrayCronometro,
    this.hidden, // 💡 CAMPO NUEVO EN EL CONSTRUCTOR
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json, String id) {
    EstadoPedido parseEstado(String? estadoStr) {
      if (estadoStr == null) return EstadoPedido.pendiente;
      try {
        return EstadoPedido.values.firstWhere(
                (e) => e.toString().split('.').last == estadoStr,
            orElse: () => EstadoPedido.pendiente);
      } catch (e) {
        return EstadoPedido.pendiente;
      }
    }

    final rawArray = json['arrayCronometro'];
    final arrayCronometro = (rawArray is List)
        ? rawArray.map((e) => (e is int) ? e : 0).toList().cast<int>()
        : <int>[];

    return PedidoModel(
      id: id,
      clienteUid: json['clienteUid'] as String? ?? 'unknown',
      clienteNombre: json['clienteNombre'] as String? ?? 'Desconocido',
      direccionEntrega: json['direccionEntrega'] as String? ?? 'N/A',
      fechaCreacion: (json['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      repartidorUid: json['repartidorUid'] as String?,
      estado: parseEstado(json['estado'] as String?),
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0.0,
      arrayCronometro: arrayCronometro,
      // 💡 CAMPO NUEVO: Lee el estado 'hidden' (puede ser null, true o false)
      hidden: json['hidden'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final jsonMap = {
      'clienteUid': clienteUid,
      'clienteNombre': clienteNombre,
      'direccionEntrega': direccionEntrega,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'repartidorUid': repartidorUid,
      'estado': estado.toString().split('.').last,
      'valorTotal': valorTotal,
      'arrayCronometro': arrayCronometro,
      // 💡 Incluye 'hidden' en toJson (es importante que el repositorio maneje el valor inicial a false)
      'hidden': hidden,
    };
    // Opcional: Si hidden es null, se puede omitir para mantener la base de datos limpia.
    if (hidden == null) {
      jsonMap.remove('hidden');
    }
    return jsonMap;
  }

  PedidoModel copyWith({
    String? id,
    String? clienteUid,
    String? clienteNombre,
    String? direccionEntrega,
    DateTime? fechaCreacion,
    String? repartidorUid,
    EstadoPedido? estado,
    double? valorTotal,
    List<int>? arrayCronometro,
    bool? hidden, // 💡 CAMPO NUEVO EN copyWith
  }) {
    return PedidoModel(
      id: id ?? this.id,
      clienteUid: clienteUid ?? this.clienteUid,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      direccionEntrega: direccionEntrega ?? this.direccionEntrega,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      repartidorUid: repartidorUid ?? this.repartidorUid,
      estado: estado ?? this.estado,
      valorTotal: valorTotal ?? this.valorTotal,
      arrayCronometro: arrayCronometro ?? this.arrayCronometro,
      hidden: hidden ?? this.hidden, // 💡 Asignación del nuevo campo
    );
  }
}