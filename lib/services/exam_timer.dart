import 'dart:async';

/// Controla el cronómetro del examen usando un [Stopwatch], que mide el
/// tiempo real transcurrido en vez de simplemente restar 1 cada
/// segundo. Esto evita desincronización: el examen siempre termina
/// exactamente al tiempo configurado, sin importar la frecuencia con
/// la que se refresque la UI.
class ExamTimer {
  ExamTimer({
    required this.onTick,
    required this.onTimeUp,
    this.totalSeconds = 60,
  });

  final int totalSeconds;

  /// Se llama periódicamente con los segundos restantes (redondeados
  /// hacia arriba) para actualizar la UI.
  final void Function(int secondsRemaining) onTick;

  /// Se llama una única vez, exactamente cuando se cumplen los
  /// [totalSeconds].
  final VoidCallback onTimeUp;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _timeUpFired = false;

  int get _totalMilliseconds => totalSeconds * 1000;

  bool get isRunning => _stopwatch.isRunning;

  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  void start() {
    _stopwatch
      ..reset()
      ..start();
    _timeUpFired = false;
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _handleTick();
    });
    // Emitir el primer tick inmediatamente para mostrar 60 desde el inicio.
    _handleTick();
  }

  void _handleTick() {
    final int elapsedMs = _stopwatch.elapsedMilliseconds;
    final int remainingMs = _totalMilliseconds - elapsedMs;

    if (remainingMs <= 0) {
      onTick(0);
      if (!_timeUpFired) {
        _timeUpFired = true;
        stop();
        onTimeUp();
      }
      return;
    }

    final int secondsRemaining = (remainingMs / 1000).ceil();
    onTick(secondsRemaining);
  }

  /// Detiene el cronómetro inmediatamente (por ejemplo, al responder
  /// la décima pregunta antes de que se acabe el tiempo).
  void stop() {
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
  }

  void dispose() {
    stop();
  }
}

typedef VoidCallback = void Function();
