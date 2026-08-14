import 'dart:math';

import '../models/exam_config.dart';
import '../models/question.dart';

/// Genera las preguntas aleatorias de un examen, respetando las tablas
/// seleccionadas y evitando repetir la misma multiplicación dos veces
/// dentro del mismo examen mientras existan suficientes combinaciones
/// disponibles.
class QuestionGenerator {
  QuestionGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const int _minMultiplier = 1;
  static const int _maxMultiplier = 10;

  /// Genera exactamente [ExamConfig.questionCount] preguntas usando
  /// exclusivamente las tablas de [config].
  ///
  /// Cada multiplicación (sin importar el orden de sus factores) se
  /// usa primero una única vez. Si la cantidad de preguntas pedida es
  /// mayor a la cantidad de multiplicaciones únicas disponibles (por
  /// ejemplo, 20 preguntas con muy pocas tablas seleccionadas), se
  /// completa repitiendo multiplicaciones ya usadas para siempre
  /// llegar a la cantidad exacta pedida. El orden en el que se
  /// muestran los dos factores se sortea al azar por variedad visual.
  List<Question> generate(ExamConfig config) {
    final Map<String, Question> uniqueByKey = <String, Question>{};

    for (final int table in config.tables) {
      for (int multiplier = _minMultiplier;
          multiplier <= _maxMultiplier;
          multiplier++) {
        final Question candidate =
            Question(displayLeft: table, displayRight: multiplier);
        // Si ya existe una pregunta con la misma multiplicación
        // (posiblemente generada desde otra tabla), no se duplica.
        uniqueByKey.putIfAbsent(candidate.unorderedKey, () => candidate);
      }
    }

    final List<Question> pool = uniqueByKey.values.toList()..shuffle(_random);
    final int targetCount = config.questionCount;

    final List<Question> selected = <Question>[];
    if (pool.length >= targetCount) {
      selected.addAll(pool.take(targetCount));
    } else {
      // No alcanzan las multiplicaciones únicas disponibles: se usan
      // todas primero y después se completa repitiendo, para
      // garantizar siempre la cantidad exacta de preguntas pedida.
      selected.addAll(pool);
      while (selected.length < targetCount) {
        final List<Question> refill = List<Question>.from(pool)
          ..shuffle(_random);
        for (final Question question in refill) {
          if (selected.length >= targetCount) {
            break;
          }
          selected.add(question);
        }
      }
    }

    // Sortear el orden de despliegue de cada pregunta.
    return selected.map(_withRandomDisplayOrder).toList();
  }

  Question _withRandomDisplayOrder(Question question) {
    if (_random.nextBool()) {
      return Question(
        displayLeft: question.displayRight,
        displayRight: question.displayLeft,
      );
    }
    return question;
  }
}
