import 'exam_config.dart';
import 'question.dart';

/// Resultado final de un examen ya finalizado.
class ExamResult {
  ExamResult({
    required this.config,
    required this.answers,
    required this.elapsedMilliseconds,
    required this.finishedByTimeout,
  });

  final ExamConfig config;
  final List<AnsweredQuestion> answers;

  /// Tiempo real transcurrido, en milisegundos, con precisión suficiente
  /// para comparar récords. Si el examen terminó porque se acabó el
  /// tiempo, este valor es exactamente 60000 (60 segundos).
  final int elapsedMilliseconds;

  /// true si el examen terminó porque se agotaron los 60 segundos,
  /// false si terminó porque el usuario respondió las 10 preguntas.
  final bool finishedByTimeout;

  int get correctCount => answers.where((a) => a.isCorrect).length;

  int get incorrectCount => answers.length - correctCount;

  /// Cantidad total de preguntas consideradas (según la cantidad
  /// configurada, 10 o 20; las preguntas no alcanzadas por falta de
  /// tiempo cuentan como incorrectas y ya están incluidas en
  /// [answers]).
  int get totalCount => config.questionCount;

  /// Tiempo utilizado, redondeado a segundos enteros para mostrar al
  /// usuario. Si el examen terminó por tiempo agotado, es siempre el
  /// tiempo máximo configurado (60 o 90 segundos).
  int get timeUsedSeconds {
    if (finishedByTimeout) {
      return config.examDurationSeconds;
    }
    return (elapsedMilliseconds / 1000).round();
  }

  /// Solo un examen perfecto (todas las preguntas correctas, ya sean
  /// 10 o 20 según la configuración) puede establecer o mejorar un
  /// récord.
  bool get isEligibleForRecord => correctCount == config.questionCount;
}
