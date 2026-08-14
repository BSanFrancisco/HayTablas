/// Un récord (mejor tiempo) guardado para una combinación exacta de
/// tablas de multiplicar Y una cantidad de preguntas (10 o 20): son
/// dos historiales de récords totalmente independientes.
class TableRecord {
  const TableRecord({
    required this.recordKey,
    required this.tables,
    required this.questionCount,
    required this.bestTimeMilliseconds,
  });

  /// Ej. "2-3-4-5_q10"
  final String recordKey;

  /// Ej. [2, 3, 4, 5]
  final List<int> tables;

  /// Cantidad de preguntas del examen que generó este récord: 10 o 20.
  final int questionCount;

  final int bestTimeMilliseconds;

  int get bestTimeSeconds => (bestTimeMilliseconds / 1000).round();

  String get displayLabel {
    if (tables.length == 1) {
      return 'Tabla ${tables.first}';
    }
    return 'Tablas ${tables.join(' - ')}';
  }

  factory TableRecord.fromJson(Map<String, dynamic> json) {
    final List<int> tables = (json['tables'] as List<dynamic>)
        .map((dynamic e) => e as int)
        .toList();
    return TableRecord(
      recordKey: json['recordKey'] as String,
      tables: tables,
      // Los récords guardados antes de existir el modo de 20
      // preguntas no tienen este campo: se asumen de 10 preguntas
      // para no perder el historial existente.
      questionCount: json['questionCount'] as int? ?? 10,
      bestTimeMilliseconds: json['bestTimeMilliseconds'] as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'recordKey': recordKey,
        'tables': tables,
        'questionCount': questionCount,
        'bestTimeMilliseconds': bestTimeMilliseconds,
      };
}
