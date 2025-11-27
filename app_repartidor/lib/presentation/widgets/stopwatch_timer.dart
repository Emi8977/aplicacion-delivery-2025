import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer; // Útil para diagnosticar errores de datos

class StopwatchTimer extends StatefulWidget {
  final List<int> arrayCronometro;
  final bool isCompleted;

  const StopwatchTimer({
    super.key,
    required this.arrayCronometro,
    required this.isCompleted,
  });

  @override
  State<StopwatchTimer> createState() => _StopwatchTimerState();
}

class _StopwatchTimerState extends State<StopwatchTimer> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // 1. Calcular la duración inicial y establecer el estado.
    _setDuration( _calculateDuration() );

    // 2. Si NO está completado, iniciar el Timer periódico.
    if (!widget.isCompleted) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant StopwatchTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 3. Recalcular y actualizar el timer si cambian los datos o el estado.
    if (widget.arrayCronometro != oldWidget.arrayCronometro || widget.isCompleted != oldWidget.isCompleted) {

      // Forzamos el cálculo y actualización inmediata
      _setDuration( _calculateDuration() );

      if (widget.isCompleted) {
        // Si ahora está completado, detenemos el contador.
        _timer?.cancel();
        _timer = null;
      } else if (_timer == null) {
        // Si pasa a 'en curso' y no hay timer (ej. si fue cancelado y reasignado), lo iniciamos.
        _startTimer();
      }
    }
  }

  // Calcula la duración (función pura)
  Duration _calculateDuration() {
    if (widget.arrayCronometro.length < 1) {
      return Duration.zero;
    }

    final int startTime = widget.arrayCronometro.first;
    int endTime;

    if (widget.isCompleted) {
      // Caso 'Completado': Debe tener al menos 2 marcas (inicio y fin).
      if (widget.arrayCronometro.length >= 2) {
        endTime = widget.arrayCronometro.last;
      } else {
        // Este es el caso que falla en pedidos viejos: Marcado como entregado pero falta tiempo de fin.
        developer.log('Error de datos: Pedido marcado como ENTREGADO sin tiempo de fin.', name: 'StopwatchTimer');
        return Duration.zero;
      }
    } else {
      // Caso 'En Curso': El tiempo de fin es el momento actual.
      endTime = DateTime.now().millisecondsSinceEpoch;
    }

    final int diffMillis = endTime - startTime;

    if (diffMillis > 0) {
      return Duration(milliseconds: diffMillis);
    } else {
      // Diferencia de tiempo no positiva (error de sincronización de hora).
      return Duration.zero;
    }
  }

  // Establece la duración usando setState, pero solo si es diferente a la actual.
  void _setDuration(Duration newDuration) {
    if (mounted && newDuration != _duration) {
      setState(() {
        _duration = newDuration;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.isCompleted) {
        // Recalculamos la duración y actualizamos el estado.
        _setDuration(_calculateDuration());
      } else {
        // Si por alguna razón el timer sigue corriendo en un estado completado, lo detenemos.
        timer.cancel();
      }
    });
  }

  // Formatea la duración en HH:MM:SS
  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return '00:00:00';

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.arrayCronometro.isEmpty) {
      return const SizedBox.shrink();
    }

    final String timeStr = _formatDuration(_duration);

    if (_duration <= Duration.zero) {
      // Mensaje de diagnóstico para el usuario.
      String message;
      if (widget.isCompleted) {
        message = 'Error: Tiempo de entrega no registrado.';
      } else {
        // Este es el mensaje que aparece brevemente al tomar el pedido hasta que corre el primer segundo.
        message = 'Iniciando cronómetro...';
      }

      return Text(
          message,
          style: TextStyle(fontSize: 12, color: widget.isCompleted ? Colors.red : Colors.grey)
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isCompleted ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.isCompleted ? 'Tiempo Total: $timeStr' : 'Tiempo en Curso: $timeStr',
        style: TextStyle(
          color: widget.isCompleted ? Colors.green.shade800 : Colors.red.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}