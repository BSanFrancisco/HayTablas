import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exam_result.dart';
import '../models/player_stats.dart';

/// Secciones principales de la app, usadas para el logro "Turista"
/// (visitar las 4 secciones al menos una vez).
enum AppSection { examen, practicar, versus, aprender }

/// Guarda y actualiza la "libreta de estadísticas" del jugador de
/// forma local (SharedPreferences), igual que los récords: sin
/// internet, sin cuentas. Sobre estas estadísticas (combinadas con
/// los récords de [RecordsRepository]) se evalúan los 100 logros.
class StatsRepository {
  static const String _storageKey = 'tablas_multiplicar.player_stats.v1';

  Future<PlayerStats> getStats() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return PlayerStats();
    }
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return PlayerStats.fromJson(decoded);
    } catch (_) {
      // Si los datos guardados están corruptos, se ignora en lugar de
      // romper la aplicación.
      return PlayerStats();
    }
  }

  /// Borra toda la libreta de estadísticas (no borra los récords de
  /// Mejores Tiempos, que se manejan aparte). No se puede deshacer.
  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _write(PlayerStats stats) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(stats.toJson()));
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  /// Marca una sección como visitada (para el logro "Turista") y
  /// registra el día de uso actual (para los logros de días de uso).
  Future<void> markVisited(AppSection section) async {
    final PlayerStats stats = await getStats();
    bool changed = false;

    switch (section) {
      case AppSection.examen:
        if (!stats.visitedExamen) {
          stats.visitedExamen = true;
          changed = true;
        }
        break;
      case AppSection.practicar:
        if (!stats.visitedPracticar) {
          stats.visitedPracticar = true;
          changed = true;
        }
        break;
      case AppSection.versus:
        if (!stats.visitedVersus) {
          stats.visitedVersus = true;
          changed = true;
        }
        break;
      case AppSection.aprender:
        if (!stats.visitedAprender) {
          stats.visitedAprender = true;
          changed = true;
        }
        break;
    }

    final String today = _todayKey();
    if (!stats.usageDates.contains(today)) {
      stats.usageDates.add(today);
      changed = true;
    }

    if (changed) {
      await _write(stats);
    }
  }

  /// Suma [tables] al conjunto de tablas que el jugador usó alguna
  /// vez, sin importar si la partida se terminó o se canceló.
  Future<void> markTablesUsed(List<int> tables) async {
    final PlayerStats stats = await getStats();
    final int before = stats.tablesEverUsed.length;
    stats.tablesEverUsed.addAll(tables);
    if (stats.tablesEverUsed.length != before) {
      await _write(stats);
    }
  }

  /// Marca que se canceló al menos un examen o una práctica.
  Future<void> markCancelled() async {
    final PlayerStats stats = await getStats();
    if (!stats.everCancelled) {
      stats.everCancelled = true;
      await _write(stats);
    }
  }

  /// Registra un examen recién finalizado (Examen, no Practicar ni
  /// Versus) y actualiza todos los contadores relacionados.
  Future<void> recordExam(ExamResult result) async {
    final PlayerStats stats = await getStats();
    final List<int> tables = result.config.tables;
    final int correct = result.correctCount;
    final int total = result.totalCount;
    final bool isPerfect = correct == total && total > 0;

    stats.totalExamsPlayed++;

    if (!stats.answeredFirstQuestion && result.answers.isNotEmpty) {
      stats.answeredFirstQuestion = true;
    }
    if (!stats.answeredFirstCorrect && correct > 0) {
      stats.answeredFirstCorrect = true;
    }
    if (result.finishedByTimeout) {
      stats.hadFirstTimeout = true;
    }
    if (correct < 3) {
      stats.hadExamUnder3Correct = true;
    }

    stats.tablesEverUsed.addAll(tables);

    if (total == 10) {
      if (correct >= 5) stats.hasScored5of10 = true;
      if (correct >= 7) stats.hasScored7of10 = true;
      if (correct >= 8) stats.hasScored8of10 = true;
      if (correct >= 9) stats.hasScored9of10 = true;
    } else if (total == 20) {
      stats.hasPlayed20QuestionExam = true;
      if (correct >= 18) stats.hasScored18of20 = true;
    }

    if (tables.length == 1 && total == 10 && correct >= 7) {
      stats.singleTable7PlusTables.add(tables.first);
    }

    if (tables.length == 2) stats.hasDoubleTableExam = true;
    if (tables.length == 3) stats.hasTripleTableExam = true;
    if (tables.length == 4) stats.hasQuadTableExam = true;

    final bool isAllNine = tables.length == 9;
    final bool isBigFour =
        tables.length == 4 && tables.toSet().containsAll(<int>{7, 8, 9, 10});

    if (isAllNine && total == 10 && correct >= 8) {
      stats.hasAllNineTables8Plus = true;
    }
    if (isBigFour && total == 10 && correct >= 8) {
      stats.hasBigTables8Plus = true;
    }

    if (!result.finishedByTimeout) {
      final double seconds = result.elapsedMilliseconds / 1000.0;
      if (total == 10) {
        if (stats.fastest10QuestionSeconds == null ||
            seconds < stats.fastest10QuestionSeconds!) {
          stats.fastest10QuestionSeconds = seconds;
        }
      } else if (total == 20) {
        if (stats.fastest20QuestionSeconds == null ||
            seconds < stats.fastest20QuestionSeconds!) {
          stats.fastest20QuestionSeconds = seconds;
        }
      }
    }

    // Racha de exámenes perfectos (cualquier combinación de tablas o
    // cantidad de preguntas).
    if (isPerfect) {
      stats.currentPerfectStreak++;
      if (stats.currentPerfectStreak > stats.maxPerfectStreak) {
        stats.maxPerfectStreak = stats.currentPerfectStreak;
      }
    } else {
      stats.currentPerfectStreak = 0;
    }

    // Racha de exámenes sin que se acabe el tiempo.
    if (!result.finishedByTimeout) {
      stats.currentNoTimeoutStreak++;
      if (stats.currentNoTimeoutStreak > stats.maxNoTimeoutStreak) {
        stats.maxNoTimeoutStreak = stats.currentNoTimeoutStreak;
      }
    } else {
      stats.currentNoTimeoutStreak = 0;
    }

    // Cantidad total de 10/10, y cuántos el mismo día.
    if (total == 10 && isPerfect) {
      stats.countOfPerfect10Exams++;
      final String today = _todayKey();
      if (stats.lastPerfect10Date == today) {
        stats.perfect10CountOnLastDate++;
      } else {
        stats.lastPerfect10Date = today;
        stats.perfect10CountOnLastDate = 1;
      }
    }

    // Racha de 20/20 consecutivos (solo entre exámenes de 20 preguntas).
    if (total == 20) {
      if (isPerfect) {
        stats.countOfPerfect20Exams++;
        stats.currentPerfect20Streak++;
        if (stats.currentPerfect20Streak > stats.maxPerfect20Streak) {
          stats.maxPerfect20Streak = stats.currentPerfect20Streak;
        }
      } else {
        stats.currentPerfect20Streak = 0;
      }
    }

    await _write(stats);
  }

  /// Marca que arrancó una sesión de Practicar con exactamente las 9
  /// tablas seleccionadas a la vez.
  Future<void> markPracticeStarted(List<int> tables) async {
    if (tables.length != 9) {
      return;
    }
    final PlayerStats stats = await getStats();
    if (!stats.hasPracticedAllNineAtOnce) {
      stats.hasPracticedAllNineAtOnce = true;
      await _write(stats);
    }
  }

  /// Registra que se batió un récord PROPIO ya existente (no la
  /// primera vez que se establece un récord para una combinación,
  /// sino una mejora sobre uno que ya estaba guardado).
  Future<void> recordBeatOwnRecord() async {
    final PlayerStats stats = await getStats();
    stats.recordsImprovedCount++;
    await _write(stats);
  }

  /// Registra una respuesta en modo Practicar (sin cronómetro ni
  /// puntaje, pero cuenta para las rachas de aciertos seguidos).
  Future<void> recordPracticeAnswer({required bool isCorrect}) async {
    final PlayerStats stats = await getStats();
    stats.totalPracticeQuestionsAnswered++;
    if (isCorrect) {
      stats.currentPracticeCorrectStreak++;
      if (stats.currentPracticeCorrectStreak > stats.maxPracticeCorrectStreak) {
        stats.maxPracticeCorrectStreak = stats.currentPracticeCorrectStreak;
      }
    } else {
      stats.currentPracticeCorrectStreak = 0;
    }
    await _write(stats);
  }

  /// Registra cuánto duró una sesión de Practicar (en segundos), para
  /// quedarse con la más larga.
  Future<void> recordPracticeSessionSeconds(int seconds) async {
    final PlayerStats stats = await getStats();
    if (seconds > stats.maxPracticeSessionSeconds) {
      stats.maxPracticeSessionSeconds = seconds;
      await _write(stats);
    }
  }

  /// Registra el resultado de una partida de Versus recién
  /// finalizada. Como la app no tiene cuentas ni identifica quién es
  /// cada jugador de una vez a la otra, los logros de Versus son
  /// compartidos por el dispositivo (no por jugador).
  Future<void> recordVersusMatch({
    required int bottomScore,
    required int topScore,
    required bool bottomHadWrongAnswer,
    required bool topHadWrongAnswer,
  }) async {
    final PlayerStats stats = await getStats();
    stats.totalVersusMatches++;

    final int maxScore = bottomScore > topScore ? bottomScore : topScore;
    if (maxScore > stats.maxVersusScoreEver) {
      stats.maxVersusScoreEver = maxScore;
    }

    final bool isTie = bottomScore == topScore;
    if (!isTie) {
      final bool bottomWins = bottomScore > topScore;
      final int winnerScore = bottomWins ? bottomScore : topScore;
      final int loserScore = bottomWins ? topScore : bottomScore;
      final bool winnerHadNoWrong =
          bottomWins ? !bottomHadWrongAnswer : !topHadWrongAnswer;

      stats.totalVersusWins++;
      stats.currentVersusWinStreak++;
      if (stats.currentVersusWinStreak > stats.maxVersusWinStreak) {
        stats.maxVersusWinStreak = stats.currentVersusWinStreak;
      }
      if (winnerScore > stats.maxVersusScoreInAWin) {
        stats.maxVersusScoreInAWin = winnerScore;
      }
      if (winnerHadNoWrong) {
        stats.hasVersusWinNoWrongAnswers = true;
      }
      final bool doubledOpponent =
          loserScore == 0 ? winnerScore > 0 : winnerScore >= loserScore * 2;
      if (doubledOpponent) {
        stats.hasVersusWinDoubleOpponent = true;
      }
      if (loserScore < 5) {
        stats.versusWinsLeavingRivalUnder5++;
      }
    } else {
      stats.currentVersusWinStreak = 0;
    }

    await _write(stats);
  }

  /// Registra que se vio el listado completo de una tabla en el modo
  /// Aprender.
  Future<void> recordTableLearned(int table) async {
    final PlayerStats stats = await getStats();
    final int current = stats.learnedTableViewCounts[table] ?? 0;
    stats.learnedTableViewCounts[table] = current + 1;
    await _write(stats);
  }
}
