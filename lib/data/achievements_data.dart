import '../models/achievement.dart';
import '../models/table_record.dart';

const List<int> _allNineTables = <int>[2, 3, 4, 5, 6, 7, 8, 9, 10];
const List<int> _bigFourTables = <int>[7, 8, 9, 10];

bool _hasRecordForEitherMode(AchievementContext ctx, int table) {
  return ctx.hasRecordFor(tables: <int>[table], questionCount: 10) ||
      ctx.hasRecordFor(tables: <int>[table], questionCount: 20);
}

bool _hasRecordForBothModes(AchievementContext ctx, int table) {
  return ctx.hasRecordFor(tables: <int>[table], questionCount: 10) &&
      ctx.hasRecordFor(tables: <int>[table], questionCount: 20);
}

bool _allSingleTables(AchievementContext ctx, bool Function(AchievementContext, int) check) {
  for (final int table in _allNineTables) {
    if (!check(ctx, table)) {
      return false;
    }
  }
  return true;
}

bool _hasComboWithBothModes(AchievementContext ctx) {
  for (final TableRecord record in ctx.records) {
    if (record.questionCount != 10) {
      continue;
    }
    if (ctx.hasRecordFor(tables: record.tables, questionCount: 20)) {
      return true;
    }
  }
  return false;
}

/// Los 98 logros "de base" (todos menos los dos meta-logros finales,
/// #98 y #100, que dependen de cuántos de los demás ya se
/// desbloquearon y se arman aparte en [AchievementsRepository]).
List<Achievement> buildBaseAchievements() {
  return <Achievement>[
    // ───────────────────────── 🫏 BURRO ─────────────────────────
    Achievement(
      id: 1,
      rank: AchievementRank.burro,
      name: 'Aprendiendo a caminar',
      description: 'Completá tu primer examen.',
      isUnlocked: (ctx) => ctx.stats.totalExamsPlayed >= 1,
    ),
    Achievement(
      id: 2,
      rank: AchievementRank.burro,
      name: 'Al menos lo intentaste',
      description: 'Respondé tu primera pregunta.',
      isUnlocked: (ctx) => ctx.stats.answeredFirstQuestion,
    ),
    Achievement(
      id: 3,
      rank: AchievementRank.burro,
      name: 'Un acierto es un acierto',
      description: 'Conseguí tu primera respuesta correcta.',
      isUnlocked: (ctx) => ctx.stats.answeredFirstCorrect,
    ),
    Achievement(
      id: 4,
      rank: AchievementRank.burro,
      name: 'Turista',
      description: 'Entrá al menos una vez a Examen, Practicar, Versus y Aprender.',
      isUnlocked: (ctx) =>
          ctx.stats.visitedExamen &&
          ctx.stats.visitedPracticar &&
          ctx.stats.visitedVersus &&
          ctx.stats.visitedAprender,
    ),
    Achievement(
      id: 5,
      rank: AchievementRank.burro,
      name: 'Cero heroísmo',
      description: 'Terminá un examen con menos de 3 aciertos.',
      isUnlocked: (ctx) => ctx.stats.hadExamUnder3Correct,
    ),
    Achievement(
      id: 6,
      rank: AchievementRank.burro,
      name: 'Ni ganó ni perdió',
      description: 'Terminá tu primera partida de Versus.',
      isUnlocked: (ctx) => ctx.stats.totalVersusMatches >= 1,
    ),
    Achievement(
      id: 7,
      rank: AchievementRank.burro,
      name: 'Ojeando la tabla',
      description: 'Abrí el modo Aprender por primera vez.',
      isUnlocked: (ctx) => ctx.stats.visitedAprender,
    ),
    Achievement(
      id: 8,
      rank: AchievementRank.burro,
      name: 'Se fue el tiempo',
      description: 'Dejá que se acabe el tiempo en un examen sin terminarlo.',
      isUnlocked: (ctx) => ctx.stats.hadFirstTimeout,
    ),
    Achievement(
      id: 9,
      rank: AchievementRank.burro,
      name: 'Probando el botón rojo',
      description: 'Cancelá un examen o una práctica al menos una vez.',
      isUnlocked: (ctx) => ctx.stats.everCancelled,
    ),
    Achievement(
      id: 10,
      rank: AchievementRank.burro,
      name: 'El primer 2',
      description: 'Jugá con la tabla del 2 por primera vez.',
      isUnlocked: (ctx) => ctx.stats.tablesEverUsed.contains(2),
    ),

    // ───────────────────────── 🐣 NOVATO ─────────────────────────
    Achievement(
      id: 11,
      rank: AchievementRank.novato,
      name: 'Cinco de diez',
      description: 'Sacá 5/10 o más en un examen.',
      isUnlocked: (ctx) => ctx.stats.hasScored5of10,
    ),
    Achievement(
      id: 12,
      rank: AchievementRank.novato,
      name: 'Práctica hace al maestro (a veces)',
      description: 'Respondé 20 preguntas en total en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.totalPracticeQuestionsAnswered >= 20,
    ),
    Achievement(
      id: 13,
      rank: AchievementRank.novato,
      name: 'Aprendiz de la del 2',
      description: '7/10 o más en un examen usando solo la tabla del 2.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(2),
    ),
    Achievement(
      id: 14,
      rank: AchievementRank.novato,
      name: 'Aprendiz de la del 3',
      description: '7/10 o más en un examen usando solo la tabla del 3.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(3),
    ),
    Achievement(
      id: 15,
      rank: AchievementRank.novato,
      name: 'Aprendiz de la del 4',
      description: '7/10 o más en un examen usando solo la tabla del 4.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(4),
    ),
    Achievement(
      id: 16,
      rank: AchievementRank.novato,
      name: 'Aprendiz de la del 5',
      description: '7/10 o más en un examen usando solo la tabla del 5.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(5),
    ),
    Achievement(
      id: 17,
      rank: AchievementRank.novato,
      name: 'Doble tabla',
      description: 'Jugá un examen combinando 2 tablas a la vez.',
      isUnlocked: (ctx) => ctx.stats.hasDoubleTableExam,
    ),
    Achievement(
      id: 18,
      rank: AchievementRank.novato,
      name: 'Primer combate',
      description: 'Jugá 2 partidas completas de Versus.',
      isUnlocked: (ctx) => ctx.stats.totalVersusMatches >= 2,
    ),
    Achievement(
      id: 19,
      rank: AchievementRank.novato,
      name: 'Estudioso',
      description: 'Mirá el listado completo de 3 tablas distintas en Aprender.',
      isUnlocked: (ctx) => ctx.stats.learnedTableViewCounts.length >= 3,
    ),
    Achievement(
      id: 20,
      rank: AchievementRank.novato,
      name: 'Sin apuro',
      description: 'Jugá al menos 2 minutos seguidos en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.maxPracticeSessionSeconds >= 120,
    ),

    // ───────────────────────── 🙂 AFICIONADO ─────────────────────────
    Achievement(
      id: 21,
      rank: AchievementRank.aficionado,
      name: 'Siete es buena nota',
      description: 'Sacá 7/10 o más en un examen.',
      isUnlocked: (ctx) => ctx.stats.hasScored7of10,
    ),
    Achievement(
      id: 22,
      rank: AchievementRank.aficionado,
      name: 'Triple combo',
      description: 'Jugá un examen combinando 3 tablas a la vez.',
      isUnlocked: (ctx) => ctx.stats.hasTripleTableExam,
    ),
    Achievement(
      id: 23,
      rank: AchievementRank.aficionado,
      name: 'La del 6, dominada',
      description: '7/10 o más en un examen usando solo la tabla del 6.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(6),
    ),
    Achievement(
      id: 24,
      rank: AchievementRank.aficionado,
      name: 'La del 7, dominada',
      description: '7/10 o más en un examen usando solo la tabla del 7.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(7),
    ),
    Achievement(
      id: 25,
      rank: AchievementRank.aficionado,
      name: 'Bajo los 50 segundos',
      description: 'Terminá un examen de 10 preguntas en menos de 50 segundos.',
      isUnlocked: (ctx) =>
          (ctx.stats.fastest10QuestionSeconds ?? 999) < 50,
    ),
    Achievement(
      id: 26,
      rank: AchievementRank.aficionado,
      name: 'Primer podio',
      description: 'Establecé tu primer récord en Mejores Tiempos.',
      isUnlocked: (ctx) => ctx.records.isNotEmpty,
    ),
    Achievement(
      id: 27,
      rank: AchievementRank.aficionado,
      name: 'Ganador',
      description: 'Ganá tu primera partida de Versus.',
      isUnlocked: (ctx) => ctx.stats.totalVersusWins >= 1,
    ),
    Achievement(
      id: 28,
      rank: AchievementRank.aficionado,
      name: '20 preguntas, sin miedo',
      description: 'Jugá tu primer examen en la modalidad de 20 preguntas.',
      isUnlocked: (ctx) => ctx.stats.hasPlayed20QuestionExam,
    ),
    Achievement(
      id: 29,
      rank: AchievementRank.aficionado,
      name: 'Racha de tres',
      description: 'Contestá 3 preguntas seguidas bien en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.maxPracticeCorrectStreak >= 3,
    ),
    Achievement(
      id: 30,
      rank: AchievementRank.aficionado,
      name: 'Explorador de tablas',
      description: 'Mirá el listado completo de las 9 tablas en Aprender.',
      isUnlocked: (ctx) => ctx.stats.learnedTableViewCounts.length >= 9,
    ),

    // ───────────────────────── 💪 COMPETENTE ─────────────────────────
    Achievement(
      id: 31,
      rank: AchievementRank.competente,
      name: 'Ocho de diez',
      description: 'Sacá 8/10 o más en un examen.',
      isUnlocked: (ctx) => ctx.stats.hasScored8of10,
    ),
    Achievement(
      id: 32,
      rank: AchievementRank.competente,
      name: 'La del 8, dominada',
      description: '7/10 o más en un examen usando solo la tabla del 8.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(8),
    ),
    Achievement(
      id: 33,
      rank: AchievementRank.competente,
      name: 'La del 9, dominada',
      description: '7/10 o más en un examen usando solo la tabla del 9.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(9),
    ),
    Achievement(
      id: 34,
      rank: AchievementRank.competente,
      name: 'La del 10, dominada',
      description: '7/10 o más en un examen usando solo la tabla del 10.',
      isUnlocked: (ctx) => ctx.stats.singleTable7PlusTables.contains(10),
    ),
    Achievement(
      id: 35,
      rank: AchievementRank.competente,
      name: 'Bajo los 40 segundos',
      description: 'Terminá un examen de 10 preguntas en menos de 40 segundos.',
      isUnlocked: (ctx) => (ctx.stats.fastest10QuestionSeconds ?? 999) < 40,
    ),
    Achievement(
      id: 36,
      rank: AchievementRank.competente,
      name: 'Racha de diez',
      description: 'Contestá 10 preguntas seguidas bien en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.maxPracticeCorrectStreak >= 10,
    ),
    Achievement(
      id: 37,
      rank: AchievementRank.competente,
      name: 'Dos de dos',
      description: 'Ganá 2 partidas de Versus seguidas.',
      isUnlocked: (ctx) => ctx.stats.maxVersusWinStreak >= 2,
    ),
    Achievement(
      id: 38,
      rank: AchievementRank.competente,
      name: 'Cuarteto',
      description: 'Jugá un examen combinando 4 tablas a la vez.',
      isUnlocked: (ctx) => ctx.stats.hasQuadTableExam,
    ),
    Achievement(
      id: 39,
      rank: AchievementRank.competente,
      name: 'Todo el abanico',
      description: 'Practicá con las 9 tablas seleccionadas a la vez.',
      isUnlocked: (ctx) => ctx.stats.hasPracticedAllNineAtOnce,
    ),
    Achievement(
      id: 40,
      rank: AchievementRank.competente,
      name: 'Sin errores por 15',
      description: '15 preguntas seguidas sin ningún error en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.maxPracticeCorrectStreak >= 15,
    ),

    // ───────────────────────── 🚀 AVANZADO ─────────────────────────
    Achievement(
      id: 41,
      rank: AchievementRank.avanzado,
      name: 'Nueve de diez',
      description: 'Sacá 9/10 o más en un examen.',
      isUnlocked: (ctx) => ctx.stats.hasScored9of10,
    ),
    Achievement(
      id: 42,
      rank: AchievementRank.avanzado,
      name: 'Perfecto de 10',
      description: 'Conseguí tu primer 10/10 en un examen de 10 preguntas.',
      isUnlocked: (ctx) => ctx.stats.countOfPerfect10Exams >= 1,
    ),
    Achievement(
      id: 43,
      rank: AchievementRank.avanzado,
      name: 'Bajo los 30 segundos',
      description: 'Terminá un examen de 10 preguntas en menos de 30 segundos.',
      isUnlocked: (ctx) => (ctx.stats.fastest10QuestionSeconds ?? 999) < 30,
    ),
    Achievement(
      id: 44,
      rank: AchievementRank.avanzado,
      name: 'Las grandes, sin miedo',
      description: '8/10 o más usando solo las tablas 7, 8, 9 y 10 juntas.',
      isUnlocked: (ctx) => ctx.stats.hasBigTables8Plus,
    ),
    Achievement(
      id: 45,
      rank: AchievementRank.avanzado,
      name: '20 sobre 20... casi',
      description: 'Sacá 18/20 o más en un examen de 20 preguntas.',
      isUnlocked: (ctx) => ctx.stats.hasScored18of20,
    ),
    Achievement(
      id: 46,
      rank: AchievementRank.avanzado,
      name: 'Tres seguidas',
      description: 'Ganá 3 partidas de Versus seguidas.',
      isUnlocked: (ctx) => ctx.stats.maxVersusWinStreak >= 3,
    ),
    Achievement(
      id: 47,
      rank: AchievementRank.avanzado,
      name: 'Maratonista',
      description: 'Jugá 10 exámenes en total.',
      isUnlocked: (ctx) => ctx.stats.totalExamsPlayed >= 10,
    ),
    Achievement(
      id: 48,
      rank: AchievementRank.avanzado,
      name: 'Coleccionista de récords',
      description: 'Tené 5 récords guardados en Mejores Tiempos.',
      isUnlocked: (ctx) => ctx.records.length >= 5,
    ),
    Achievement(
      id: 49,
      rank: AchievementRank.avanzado,
      name: 'Rápido y furioso',
      description: 'Ganá una partida de Versus con 15 puntos o más.',
      isUnlocked: (ctx) => ctx.stats.maxVersusScoreInAWin >= 15,
    ),
    Achievement(
      id: 50,
      rank: AchievementRank.avanzado,
      name: 'Ni un segundo de más',
      description: 'Terminá un examen de 20 preguntas en menos de 70 segundos.',
      isUnlocked: (ctx) => (ctx.stats.fastest20QuestionSeconds ?? 999) < 70,
    ),

    // ───────────────────────── 🎯 EXPERTO ─────────────────────────
    Achievement(
      id: 51,
      rank: AchievementRank.experto,
      name: 'Perfecto de 20',
      description: 'Conseguí tu primer 20/20 en un examen de 20 preguntas.',
      isUnlocked: (ctx) => ctx.stats.countOfPerfect20Exams >= 1,
    ),
    Achievement(
      id: 52,
      rank: AchievementRank.experto,
      name: 'Bajo los 25 segundos',
      description: 'Terminá un examen de 10 preguntas en menos de 25 segundos.',
      isUnlocked: (ctx) => (ctx.stats.fastest10QuestionSeconds ?? 999) < 25,
    ),
    Achievement(
      id: 53,
      rank: AchievementRank.experto,
      name: 'Las grandes, perfectas',
      description: '10/10 usando solo las tablas 7, 8, 9 y 10 juntas.',
      isUnlocked: (ctx) =>
          ctx.hasRecordFor(tables: _bigFourTables, questionCount: 10),
    ),
    Achievement(
      id: 54,
      rank: AchievementRank.experto,
      name: 'Doble perfecto',
      description: 'Dos 10/10 en exámenes distintos el mismo día.',
      isUnlocked: (ctx) => ctx.stats.perfect10CountOnLastDate >= 2,
    ),
    Achievement(
      id: 55,
      rank: AchievementRank.experto,
      name: '20 puntos en Versus',
      description: 'Terminá una partida de Versus con 20 puntos o más.',
      isUnlocked: (ctx) => ctx.stats.maxVersusScoreEver >= 20,
    ),
    Achievement(
      id: 56,
      rank: AchievementRank.experto,
      name: 'Cinco seguidas',
      description: 'Ganá 5 partidas de Versus seguidas.',
      isUnlocked: (ctx) => ctx.stats.maxVersusWinStreak >= 5,
    ),
    Achievement(
      id: 57,
      rank: AchievementRank.experto,
      name: 'Nueve tablas, un solo examen',
      description: '8/10 o más combinando las 9 tablas juntas.',
      isUnlocked: (ctx) => ctx.stats.hasAllNineTables8Plus,
    ),
    Achievement(
      id: 58,
      rank: AchievementRank.experto,
      name: 'Sin timeouts',
      description: '10 exámenes seguidos sin que se acabe el tiempo en ninguno.',
      isUnlocked: (ctx) => ctx.stats.maxNoTimeoutStreak >= 10,
    ),
    Achievement(
      id: 59,
      rank: AchievementRank.experto,
      name: 'Coleccionista mayor',
      description: 'Tené 10 récords guardados en Mejores Tiempos.',
      isUnlocked: (ctx) => ctx.records.length >= 10,
    ),
    Achievement(
      id: 60,
      rank: AchievementRank.experto,
      name: 'Doble modalidad',
      description:
          'Tené récord en la modalidad de 10 y de 20 preguntas para la misma combinación de tablas.',
      isUnlocked: (ctx) => _hasComboWithBothModes(ctx),
    ),

    // ───────────────────────── 🏅 MAESTRO ─────────────────────────
    Achievement(
      id: 61,
      rank: AchievementRank.maestro,
      name: 'Bajo los 20 segundos',
      description: 'Terminá un examen de 10 preguntas en menos de 20 segundos.',
      isUnlocked: (ctx) => (ctx.stats.fastest10QuestionSeconds ?? 999) < 20,
    ),
    Achievement(
      id: 62,
      rank: AchievementRank.maestro,
      name: 'Perfecto en menos de 45',
      description: 'Sacá 20/20 en menos de 45 segundos (cualquier combinación de tablas).',
      isUnlocked: (ctx) => _fastestPerfect(ctx, 20) < 45,
    ),
    Achievement(
      id: 63,
      rank: AchievementRank.maestro,
      name: 'Las nueve, perfectas',
      description: '10/10 usando las 9 tablas juntas.',
      isUnlocked: (ctx) =>
          ctx.hasRecordFor(tables: _allNineTables, questionCount: 10),
    ),
    Achievement(
      id: 64,
      rank: AchievementRank.maestro,
      name: 'Racha de veinticinco',
      description: '25 preguntas seguidas bien en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.maxPracticeCorrectStreak >= 25,
    ),
    Achievement(
      id: 65,
      rank: AchievementRank.maestro,
      name: 'Diez seguidas en Versus',
      description: 'Ganá 10 partidas de Versus seguidas.',
      isUnlocked: (ctx) => ctx.stats.maxVersusWinStreak >= 10,
    ),
    Achievement(
      id: 66,
      rank: AchievementRank.maestro,
      name: 'Nada de errores',
      description: 'Ganá una partida de Versus sin ninguna respuesta incorrecta.',
      isUnlocked: (ctx) => ctx.stats.hasVersusWinNoWrongAnswers,
    ),
    Achievement(
      id: 67,
      rank: AchievementRank.maestro,
      name: 'Un mes de práctica',
      description: 'Usá la app en 15 días distintos.',
      isUnlocked: (ctx) => ctx.stats.usageDates.length >= 15,
    ),
    Achievement(
      id: 68,
      rank: AchievementRank.maestro,
      name: 'Perfeccionista serial',
      description: 'Sacá 10/10 en 10 exámenes distintos (no necesariamente seguidos).',
      isUnlocked: (ctx) => ctx.stats.countOfPerfect10Exams >= 10,
    ),
    Achievement(
      id: 69,
      rank: AchievementRank.maestro,
      name: 'Doble perfecto grande',
      description: '20/20 usando las 9 tablas juntas.',
      isUnlocked: (ctx) =>
          ctx.hasRecordFor(tables: _allNineTables, questionCount: 20),
    ),
    Achievement(
      id: 70,
      rank: AchievementRank.maestro,
      name: 'Instructor',
      description: 'Mirá el listado completo de las 9 tablas, 3 veces cada una.',
      isUnlocked: (ctx) =>
          ctx.stats.learnedTableViewCounts.length == 9 &&
          ctx.stats.learnedTableViewCounts.values.every((v) => v >= 3),
    ),

    // ───────────────────────── ⚡ ÉPICO ─────────────────────────
    Achievement(
      id: 71,
      rank: AchievementRank.epico,
      name: 'Bajo los 15 segundos',
      description: 'Terminá un examen de 10 preguntas en menos de 15 segundos.',
      isUnlocked: (ctx) => (ctx.stats.fastest10QuestionSeconds ?? 999) < 15,
    ),
    Achievement(
      id: 72,
      rank: AchievementRank.epico,
      name: 'Perfecto relámpago',
      description: '10/10 con las 9 tablas juntas en menos de 20 segundos.',
      isUnlocked: (ctx) =>
          (ctx.fastestSecondsFor(tables: _allNineTables, questionCount: 10) ??
                  999) <
              20,
    ),
    Achievement(
      id: 73,
      rank: AchievementRank.epico,
      name: 'Veinte perfectos seguidos',
      description: '20/20 en tres exámenes de 20 preguntas seguidos.',
      isUnlocked: (ctx) => ctx.stats.maxPerfect20Streak >= 3,
    ),
    Achievement(
      id: 74,
      rank: AchievementRank.epico,
      name: 'Arrasador',
      description: 'Ganá una partida de Versus con el doble de puntos que tu rival (o más).',
      isUnlocked: (ctx) => ctx.stats.hasVersusWinDoubleOpponent,
    ),
    Achievement(
      id: 75,
      rank: AchievementRank.epico,
      name: 'Sin descanso',
      description: 'Jugá 30 exámenes en total.',
      isUnlocked: (ctx) => ctx.stats.totalExamsPlayed >= 30,
    ),
    Achievement(
      id: 76,
      rank: AchievementRank.epico,
      name: 'Racha de cincuenta',
      description: '50 preguntas seguidas bien en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.maxPracticeCorrectStreak >= 50,
    ),
    Achievement(
      id: 77,
      rank: AchievementRank.epico,
      name: 'Veinte seguidas en Versus',
      description: 'Ganá 20 partidas de Versus seguidas.',
      isUnlocked: (ctx) => ctx.stats.maxVersusWinStreak >= 20,
    ),
    Achievement(
      id: 78,
      rank: AchievementRank.epico,
      name: 'Maestro del reloj',
      description: 'Tené un récord de menos de 20 segundos en 5 combinaciones distintas.',
      isUnlocked: (ctx) =>
          ctx.records.where((r) => r.bestTimeSeconds < 20).length >= 5,
    ),
    Achievement(
      id: 79,
      rank: AchievementRank.epico,
      name: 'Nunca falla',
      description: '20 exámenes seguidos con el 100% de aciertos.',
      isUnlocked: (ctx) => ctx.stats.maxPerfectStreak >= 20,
    ),
    Achievement(
      id: 80,
      rank: AchievementRank.epico,
      name: 'El más rápido de la casa',
      description: 'Batí un récord propio ya establecido, al menos 5 veces.',
      isUnlocked: (ctx) => ctx.stats.recordsImprovedCount >= 5,
    ),

    // ───────────────────────── 👑 LEYENDA ─────────────────────────
    Achievement(
      id: 81,
      rank: AchievementRank.leyenda,
      name: 'Bajo los 10 segundos',
      description: 'Terminá un examen de 10 preguntas en menos de 10 segundos.',
      isUnlocked: (ctx) => (ctx.stats.fastest10QuestionSeconds ?? 999) < 10,
    ),
    Achievement(
      id: 82,
      rank: AchievementRank.leyenda,
      name: 'Perfecto imposible',
      description: '20/20 con las 9 tablas juntas en menos de 35 segundos.',
      isUnlocked: (ctx) =>
          (ctx.fastestSecondsFor(tables: _allNineTables, questionCount: 20) ??
                  999) <
              35,
    ),
    Achievement(
      id: 83,
      rank: AchievementRank.leyenda,
      name: 'Cien preguntas perfectas',
      description: '100 preguntas seguidas bien en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.maxPracticeCorrectStreak >= 100,
    ),
    Achievement(
      id: 84,
      rank: AchievementRank.leyenda,
      name: 'Invicto',
      description: 'Ganá 30 partidas de Versus seguidas.',
      isUnlocked: (ctx) => ctx.stats.maxVersusWinStreak >= 30,
    ),
    Achievement(
      id: 85,
      rank: AchievementRank.leyenda,
      name: 'Cien exámenes',
      description: 'Jugá 100 exámenes en total.',
      isUnlocked: (ctx) => ctx.stats.totalExamsPlayed >= 100,
    ),
    Achievement(
      id: 86,
      rank: AchievementRank.leyenda,
      name: 'Todo perfecto',
      description: '10/10 o 20/20 en cada una de las 9 tablas individuales.',
      isUnlocked: (ctx) => _allSingleTables(ctx, _hasRecordForEitherMode),
    ),
    Achievement(
      id: 87,
      rank: AchievementRank.leyenda,
      name: 'Doble todo perfecto',
      description: '10/10 y 20/20 en cada una de las 9 tablas individuales.',
      isUnlocked: (ctx) => _allSingleTables(ctx, _hasRecordForBothModes),
    ),
    Achievement(
      id: 88,
      rank: AchievementRank.leyenda,
      name: 'Sin piedad',
      description: 'Ganá 10 partidas de Versus dejando a tu rival con menos de 5 puntos.',
      isUnlocked: (ctx) => ctx.stats.versusWinsLeavingRivalUnder5 >= 10,
    ),
    Achievement(
      id: 89,
      rank: AchievementRank.leyenda,
      name: 'Velocidad de leyenda',
      description: 'Tené un récord de menos de 15 segundos en 10 combinaciones distintas.',
      isUnlocked: (ctx) =>
          ctx.records.where((r) => r.bestTimeSeconds < 15).length >= 10,
    ),
    Achievement(
      id: 90,
      rank: AchievementRank.leyenda,
      name: 'Cien días',
      description: 'Usá la app en 100 días distintos.',
      isUnlocked: (ctx) => ctx.stats.usageDates.length >= 100,
    ),

    // ───────────────────────── 🐉 LEGENDARIO ─────────────────────────
    Achievement(
      id: 91,
      rank: AchievementRank.legendario,
      name: 'El más rápido del mundo',
      description: 'Terminá un examen de 10 preguntas en menos de 8 segundos.',
      isUnlocked: (ctx) => (ctx.stats.fastest10QuestionSeconds ?? 999) < 8,
    ),
    Achievement(
      id: 92,
      rank: AchievementRank.legendario,
      name: 'Perfección absoluta',
      description: '20/20 con las 9 tablas juntas en menos de 25 segundos.',
      isUnlocked: (ctx) =>
          (ctx.fastestSecondsFor(tables: _allNineTables, questionCount: 20) ??
                  999) <
              25,
    ),
    Achievement(
      id: 93,
      rank: AchievementRank.legendario,
      name: 'Rey de las tablas',
      description: 'Tené 15 récords guardados en Mejores Tiempos.',
      isUnlocked: (ctx) => ctx.records.length >= 15,
    ),
    Achievement(
      id: 94,
      rank: AchievementRank.legendario,
      name: 'Quinientas preguntas',
      description: '500 preguntas seguidas bien en modo Practicar.',
      isUnlocked: (ctx) => ctx.stats.maxPracticeCorrectStreak >= 500,
    ),
    Achievement(
      id: 95,
      rank: AchievementRank.legendario,
      name: 'El emperador del Versus',
      description: 'Ganá 50 partidas de Versus seguidas.',
      isUnlocked: (ctx) => ctx.stats.maxVersusWinStreak >= 50,
    ),
    Achievement(
      id: 96,
      rank: AchievementRank.legendario,
      name: 'Mil exámenes',
      description: 'Jugá 1000 exámenes en total.',
      isUnlocked: (ctx) => ctx.stats.totalExamsPlayed >= 1000,
    ),
    Achievement(
      id: 97,
      rank: AchievementRank.legendario,
      name: 'Nunca perdiste',
      description: 'Jugá 50 partidas de Versus sin perder ninguna en toda tu historia.',
      isUnlocked: (ctx) =>
          ctx.stats.totalVersusMatches >= 50 &&
          ctx.stats.totalVersusWins == ctx.stats.totalVersusMatches,
    ),
    // Los ids 98 y 100 son meta-logros (dependen de los demás logros)
    // y se agregan aparte en AchievementsRepository.
    Achievement(
      id: 99,
      rank: AchievementRank.legendario,
      name: 'Sin límites',
      description: 'Usá la app en 365 días distintos.',
      isUnlocked: (ctx) => ctx.stats.usageDates.length >= 365,
    ),
  ];
}

double _fastestPerfect(AchievementContext ctx, int questionCount) {
  double best = double.infinity;
  for (final TableRecord record in ctx.records) {
    if (record.questionCount != questionCount) {
      continue;
    }
    final double seconds = record.bestTimeMilliseconds / 1000.0;
    if (seconds < best) {
      best = seconds;
    }
  }
  return best;
}
