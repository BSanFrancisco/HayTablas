/// Configuración de un examen: el conjunto de tablas de multiplicar
/// que pueden aparecer en las preguntas, y la cantidad de preguntas
/// elegida (10 o 20), de la cual se deriva automáticamente el tiempo
/// máximo permitido.
///
/// Esta clase es inmutable: una vez creada, representa una selección
/// fija de tablas y cantidad de preguntas ya validada.
class ExamConfig {
  ExamConfig({required List<int> tables, this.questionCount = defaultQuestionCount})
      : tables = List<int>.unmodifiable(
          (List<int>.from(tables)..sort()),
        );

  /// Tablas efectivas del examen, ordenadas de menor a mayor.
  /// Ejemplo: [2, 3, 4, 5]
  final List<int> tables;

  /// Cantidad de preguntas del examen: 10 o 20.
  final int questionCount;

  static const int defaultQuestionCount = 10;

  /// Mapeo automático y no configurable entre cantidad de preguntas y
  /// tiempo máximo del examen: 10 preguntas → 60 segundos,
  /// 20 preguntas → 90 segundos.
  static int durationForQuestionCount(int questionCount) {
    switch (questionCount) {
      case 20:
        return 90;
      case 10:
      default:
        return 60;
    }
  }

  /// Tiempo máximo del examen, derivado automáticamente de
  /// [questionCount].
  int get examDurationSeconds => durationForQuestionCount(questionCount);

  /// Identificador único y estable de esta combinación de tablas Y
  /// cantidad de preguntas. Se usa como clave para guardar/leer los
  /// récords: la misma combinación de tablas con distinta cantidad de
  /// preguntas tiene un récord completamente independiente.
  /// Ejemplo: "2-3-4-5_q10"
  String get recordKey => '${tables.join('-')}_q$questionCount';

  /// Texto para mostrar la combinación de tablas, ej. "2 · 3 · 4 · 5".
  String get displayJoined => tables.join(' · ');

  /// Texto para la pantalla de mejores tiempos, ej. "Tablas 2 - 3 - 4 - 5"
  /// o "Tabla 5" cuando solo hay una tabla seleccionada.
  String get displayLabel {
    if (tables.length == 1) {
      return 'Tabla ${tables.first}';
    }
    return 'Tablas ${tables.join(' - ')}';
  }
}
