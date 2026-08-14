/// Una pregunta de multiplicación individual.
///
/// [displayLeft] y [displayRight] son los dos factores en el orden en
/// que se muestran en pantalla (el orden puede variar al azar por
/// variedad visual), pero la respuesta correcta es siempre el producto
/// de ambos, sin importar el orden.
class Question {
  Question({required this.displayLeft, required this.displayRight});

  final int displayLeft;
  final int displayRight;

  int get correctAnswer => displayLeft * displayRight;

  /// Clave que identifica de forma única esta multiplicación sin
  /// importar el orden de los factores (para evitar preguntas
  /// duplicadas dentro de un mismo examen, ej. "3×8" y "8×3" cuentan
  /// como la misma multiplicación).
  String get unorderedKey {
    final int a = displayLeft <= displayRight ? displayLeft : displayRight;
    final int b = displayLeft <= displayRight ? displayRight : displayLeft;
    return '${a}x$b';
  }
}

/// Resultado de haber respondido (o no) una pregunta durante el examen.
class AnsweredQuestion {
  AnsweredQuestion({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });

  final Question question;

  /// Null si la pregunta quedó sin responder porque se acabó el tiempo.
  final int? userAnswer;
  final bool isCorrect;
}
