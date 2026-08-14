import 'player_stats.dart';
import 'table_record.dart';

/// Los 10 rangos de logros, de menor a mayor dificultad.
enum AchievementRank {
  burro,
  novato,
  aficionado,
  competente,
  avanzado,
  experto,
  maestro,
  epico,
  leyenda,
  legendario,
}

extension AchievementRankInfo on AchievementRank {
  String get displayName {
    switch (this) {
      case AchievementRank.burro:
        return 'Burro';
      case AchievementRank.novato:
        return 'Novato';
      case AchievementRank.aficionado:
        return 'Aficionado';
      case AchievementRank.competente:
        return 'Competente';
      case AchievementRank.avanzado:
        return 'Avanzado';
      case AchievementRank.experto:
        return 'Experto';
      case AchievementRank.maestro:
        return 'Maestro';
      case AchievementRank.epico:
        return 'Épico';
      case AchievementRank.leyenda:
        return 'Leyenda';
      case AchievementRank.legendario:
        return 'Legendario';
    }
  }

  String get emoji {
    switch (this) {
      case AchievementRank.burro:
        return '🫏';
      case AchievementRank.novato:
        return '🐣';
      case AchievementRank.aficionado:
        return '🙂';
      case AchievementRank.competente:
        return '💪';
      case AchievementRank.avanzado:
        return '🚀';
      case AchievementRank.experto:
        return '🎯';
      case AchievementRank.maestro:
        return '🏅';
      case AchievementRank.epico:
        return '⚡';
      case AchievementRank.leyenda:
        return '👑';
      case AchievementRank.legendario:
        return '🐉';
    }
  }
}

/// Toda la información necesaria para evaluar si un logro está
/// desbloqueado: las estadísticas acumuladas y los récords guardados
/// en Mejores Tiempos.
class AchievementContext {
  const AchievementContext({required this.stats, required this.records});

  final PlayerStats stats;
  final List<TableRecord> records;

  /// true si existe un récord guardado para exactamente esa
  /// combinación de tablas y esa cantidad de preguntas (lo que
  /// implica que en algún momento se sacó el puntaje perfecto ahí).
  bool hasRecordFor({required List<int> tables, required int questionCount}) {
    return _findRecord(tables: tables, questionCount: questionCount) != null;
  }

  /// El mejor tiempo (en segundos) para esa combinación exacta de
  /// tablas y cantidad de preguntas, o null si todavía no hay récord.
  double? fastestSecondsFor({
    required List<int> tables,
    required int questionCount,
  }) {
    final TableRecord? record =
        _findRecord(tables: tables, questionCount: questionCount);
    return record == null ? null : record.bestTimeMilliseconds / 1000.0;
  }

  TableRecord? _findRecord({
    required List<int> tables,
    required int questionCount,
  }) {
    final List<int> sorted = List<int>.from(tables)..sort();
    for (final TableRecord record in records) {
      if (record.questionCount != questionCount) {
        continue;
      }
      if (_sameTables(record.tables, sorted)) {
        return record;
      }
    }
    return null;
  }

  bool _sameTables(List<int> a, List<int> sortedB) {
    if (a.length != sortedB.length) {
      return false;
    }
    final List<int> sortedA = List<int>.from(a)..sort();
    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) {
        return false;
      }
    }
    return true;
  }
}

/// Un logro individual: pertenece a un rango, tiene nombre y
/// descripción, y una condición de desbloqueo evaluada contra un
/// [AchievementContext].
class Achievement {
  const Achievement({
    required this.id,
    required this.rank,
    required this.name,
    required this.description,
    required this.isUnlocked,
  });

  final int id;
  final AchievementRank rank;
  final String name;
  final String description;
  final bool Function(AchievementContext context) isUnlocked;
}
