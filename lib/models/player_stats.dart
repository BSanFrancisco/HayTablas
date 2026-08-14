/// Estadísticas acumuladas del jugador (o de los jugadores, ya que la
/// app no tiene cuentas: todo se guarda a nivel dispositivo). Es la
/// "libreta" sobre la que se evalúan los 100 logros. No incluye los
/// mejores tiempos por combinación de tablas: eso ya lo guarda
/// [RecordsRepository] por separado, y los logros que dependen de
/// récords se evalúan combinando ambas fuentes.
class PlayerStats {
  PlayerStats({
    this.visitedExamen = false,
    this.visitedPracticar = false,
    this.visitedVersus = false,
    this.visitedAprender = false,
    this.answeredFirstQuestion = false,
    this.answeredFirstCorrect = false,
    this.hadFirstTimeout = false,
    this.everCancelled = false,
    this.hadExamUnder3Correct = false,
    Set<int>? tablesEverUsed,
    this.totalExamsPlayed = 0,
    this.hasScored5of10 = false,
    this.hasScored7of10 = false,
    this.hasScored8of10 = false,
    this.hasScored9of10 = false,
    this.hasScored18of20 = false,
    this.hasPlayed20QuestionExam = false,
    this.hasPracticedAllNineAtOnce = false,
    Set<int>? singleTable7PlusTables,
    this.hasDoubleTableExam = false,
    this.hasTripleTableExam = false,
    this.hasQuadTableExam = false,
    this.hasAllNineTables8Plus = false,
    this.hasBigTables8Plus = false,
    this.fastest10QuestionSeconds,
    this.fastest20QuestionSeconds,
    this.currentPerfectStreak = 0,
    this.maxPerfectStreak = 0,
    this.currentNoTimeoutStreak = 0,
    this.maxNoTimeoutStreak = 0,
    this.countOfPerfect10Exams = 0,
    this.countOfPerfect20Exams = 0,
    this.currentPerfect20Streak = 0,
    this.maxPerfect20Streak = 0,
    this.lastPerfect10Date,
    this.perfect10CountOnLastDate = 0,
    this.recordsImprovedCount = 0,
    this.totalPracticeQuestionsAnswered = 0,
    this.currentPracticeCorrectStreak = 0,
    this.maxPracticeCorrectStreak = 0,
    this.maxPracticeSessionSeconds = 0,
    this.totalVersusMatches = 0,
    this.totalVersusWins = 0,
    this.currentVersusWinStreak = 0,
    this.maxVersusWinStreak = 0,
    this.maxVersusScoreInAWin = 0,
    this.maxVersusScoreEver = 0,
    this.hasVersusWinNoWrongAnswers = false,
    this.hasVersusWinDoubleOpponent = false,
    this.versusWinsLeavingRivalUnder5 = 0,
    Map<int, int>? learnedTableViewCounts,
    Set<String>? usageDates,
  })  : tablesEverUsed = tablesEverUsed ?? <int>{},
        singleTable7PlusTables = singleTable7PlusTables ?? <int>{},
        learnedTableViewCounts = learnedTableViewCounts ?? <int, int>{},
        usageDates = usageDates ?? <String>{};

  // Primeros pasos / exploración.
  bool visitedExamen;
  bool visitedPracticar;
  bool visitedVersus;
  bool visitedAprender;
  bool answeredFirstQuestion;
  bool answeredFirstCorrect;
  bool hadFirstTimeout;
  bool everCancelled;
  bool hadExamUnder3Correct;
  final Set<int> tablesEverUsed;

  // Exámenes.
  int totalExamsPlayed;
  bool hasScored5of10;
  bool hasScored7of10;
  bool hasScored8of10;
  bool hasScored9of10;
  bool hasScored18of20;
  bool hasPlayed20QuestionExam;
  bool hasPracticedAllNineAtOnce;
  final Set<int> singleTable7PlusTables;
  bool hasDoubleTableExam;
  bool hasTripleTableExam;
  bool hasQuadTableExam;
  bool hasAllNineTables8Plus;
  bool hasBigTables8Plus;
  double? fastest10QuestionSeconds;
  double? fastest20QuestionSeconds;
  int currentPerfectStreak;
  int maxPerfectStreak;
  int currentNoTimeoutStreak;
  int maxNoTimeoutStreak;
  int countOfPerfect10Exams;
  int countOfPerfect20Exams;
  int currentPerfect20Streak;
  int maxPerfect20Streak;
  String? lastPerfect10Date;
  int perfect10CountOnLastDate;
  int recordsImprovedCount;

  // Practicar.
  int totalPracticeQuestionsAnswered;
  int currentPracticeCorrectStreak;
  int maxPracticeCorrectStreak;
  int maxPracticeSessionSeconds;

  // Versus.
  int totalVersusMatches;
  int totalVersusWins;
  int currentVersusWinStreak;
  int maxVersusWinStreak;
  int maxVersusScoreInAWin;
  int maxVersusScoreEver;
  bool hasVersusWinNoWrongAnswers;
  bool hasVersusWinDoubleOpponent;
  int versusWinsLeavingRivalUnder5;

  // Aprender.
  final Map<int, int> learnedTableViewCounts;

  // Uso general.
  final Set<String> usageDates;

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    Set<int> intSetFrom(String key) => (json[key] as List<dynamic>? ?? const [])
        .map((dynamic e) => e as int)
        .toSet();

    Map<int, int> intMapFrom(String key) {
      final Map<String, dynamic> raw =
          (json[key] as Map<String, dynamic>?) ?? const <String, dynamic>{};
      return raw.map((String k, dynamic v) => MapEntry(int.parse(k), v as int));
    }

    Set<String> stringSetFrom(String key) =>
        (json[key] as List<dynamic>? ?? const []).map((dynamic e) => e as String).toSet();

    return PlayerStats(
      visitedExamen: json['visitedExamen'] as bool? ?? false,
      visitedPracticar: json['visitedPracticar'] as bool? ?? false,
      visitedVersus: json['visitedVersus'] as bool? ?? false,
      visitedAprender: json['visitedAprender'] as bool? ?? false,
      answeredFirstQuestion: json['answeredFirstQuestion'] as bool? ?? false,
      answeredFirstCorrect: json['answeredFirstCorrect'] as bool? ?? false,
      hadFirstTimeout: json['hadFirstTimeout'] as bool? ?? false,
      everCancelled: json['everCancelled'] as bool? ?? false,
      hadExamUnder3Correct: json['hadExamUnder3Correct'] as bool? ?? false,
      tablesEverUsed: intSetFrom('tablesEverUsed'),
      totalExamsPlayed: json['totalExamsPlayed'] as int? ?? 0,
      hasScored5of10: json['hasScored5of10'] as bool? ?? false,
      hasScored7of10: json['hasScored7of10'] as bool? ?? false,
      hasScored8of10: json['hasScored8of10'] as bool? ?? false,
      hasScored9of10: json['hasScored9of10'] as bool? ?? false,
      hasScored18of20: json['hasScored18of20'] as bool? ?? false,
      hasPlayed20QuestionExam: json['hasPlayed20QuestionExam'] as bool? ?? false,
      hasPracticedAllNineAtOnce:
          json['hasPracticedAllNineAtOnce'] as bool? ?? false,
      singleTable7PlusTables: intSetFrom('singleTable7PlusTables'),
      hasDoubleTableExam: json['hasDoubleTableExam'] as bool? ?? false,
      hasTripleTableExam: json['hasTripleTableExam'] as bool? ?? false,
      hasQuadTableExam: json['hasQuadTableExam'] as bool? ?? false,
      hasAllNineTables8Plus: json['hasAllNineTables8Plus'] as bool? ?? false,
      hasBigTables8Plus: json['hasBigTables8Plus'] as bool? ?? false,
      fastest10QuestionSeconds: (json['fastest10QuestionSeconds'] as num?)?.toDouble(),
      fastest20QuestionSeconds: (json['fastest20QuestionSeconds'] as num?)?.toDouble(),
      currentPerfectStreak: json['currentPerfectStreak'] as int? ?? 0,
      maxPerfectStreak: json['maxPerfectStreak'] as int? ?? 0,
      currentNoTimeoutStreak: json['currentNoTimeoutStreak'] as int? ?? 0,
      maxNoTimeoutStreak: json['maxNoTimeoutStreak'] as int? ?? 0,
      countOfPerfect10Exams: json['countOfPerfect10Exams'] as int? ?? 0,
      countOfPerfect20Exams: json['countOfPerfect20Exams'] as int? ?? 0,
      currentPerfect20Streak: json['currentPerfect20Streak'] as int? ?? 0,
      maxPerfect20Streak: json['maxPerfect20Streak'] as int? ?? 0,
      lastPerfect10Date: json['lastPerfect10Date'] as String?,
      perfect10CountOnLastDate: json['perfect10CountOnLastDate'] as int? ?? 0,
      recordsImprovedCount: json['recordsImprovedCount'] as int? ?? 0,
      totalPracticeQuestionsAnswered:
          json['totalPracticeQuestionsAnswered'] as int? ?? 0,
      currentPracticeCorrectStreak:
          json['currentPracticeCorrectStreak'] as int? ?? 0,
      maxPracticeCorrectStreak: json['maxPracticeCorrectStreak'] as int? ?? 0,
      maxPracticeSessionSeconds: json['maxPracticeSessionSeconds'] as int? ?? 0,
      totalVersusMatches: json['totalVersusMatches'] as int? ?? 0,
      totalVersusWins: json['totalVersusWins'] as int? ?? 0,
      currentVersusWinStreak: json['currentVersusWinStreak'] as int? ?? 0,
      maxVersusWinStreak: json['maxVersusWinStreak'] as int? ?? 0,
      maxVersusScoreInAWin: json['maxVersusScoreInAWin'] as int? ?? 0,
      maxVersusScoreEver: json['maxVersusScoreEver'] as int? ?? 0,
      hasVersusWinNoWrongAnswers: json['hasVersusWinNoWrongAnswers'] as bool? ?? false,
      hasVersusWinDoubleOpponent: json['hasVersusWinDoubleOpponent'] as bool? ?? false,
      versusWinsLeavingRivalUnder5: json['versusWinsLeavingRivalUnder5'] as int? ?? 0,
      learnedTableViewCounts: intMapFrom('learnedTableViewCounts'),
      usageDates: stringSetFrom('usageDates'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'visitedExamen': visitedExamen,
      'visitedPracticar': visitedPracticar,
      'visitedVersus': visitedVersus,
      'visitedAprender': visitedAprender,
      'answeredFirstQuestion': answeredFirstQuestion,
      'answeredFirstCorrect': answeredFirstCorrect,
      'hadFirstTimeout': hadFirstTimeout,
      'everCancelled': everCancelled,
      'hadExamUnder3Correct': hadExamUnder3Correct,
      'tablesEverUsed': tablesEverUsed.toList(),
      'totalExamsPlayed': totalExamsPlayed,
      'hasScored5of10': hasScored5of10,
      'hasScored7of10': hasScored7of10,
      'hasScored8of10': hasScored8of10,
      'hasScored9of10': hasScored9of10,
      'hasScored18of20': hasScored18of20,
      'hasPlayed20QuestionExam': hasPlayed20QuestionExam,
      'hasPracticedAllNineAtOnce': hasPracticedAllNineAtOnce,
      'singleTable7PlusTables': singleTable7PlusTables.toList(),
      'hasDoubleTableExam': hasDoubleTableExam,
      'hasTripleTableExam': hasTripleTableExam,
      'hasQuadTableExam': hasQuadTableExam,
      'hasAllNineTables8Plus': hasAllNineTables8Plus,
      'hasBigTables8Plus': hasBigTables8Plus,
      'fastest10QuestionSeconds': fastest10QuestionSeconds,
      'fastest20QuestionSeconds': fastest20QuestionSeconds,
      'currentPerfectStreak': currentPerfectStreak,
      'maxPerfectStreak': maxPerfectStreak,
      'currentNoTimeoutStreak': currentNoTimeoutStreak,
      'maxNoTimeoutStreak': maxNoTimeoutStreak,
      'countOfPerfect10Exams': countOfPerfect10Exams,
      'countOfPerfect20Exams': countOfPerfect20Exams,
      'currentPerfect20Streak': currentPerfect20Streak,
      'maxPerfect20Streak': maxPerfect20Streak,
      'lastPerfect10Date': lastPerfect10Date,
      'perfect10CountOnLastDate': perfect10CountOnLastDate,
      'recordsImprovedCount': recordsImprovedCount,
      'totalPracticeQuestionsAnswered': totalPracticeQuestionsAnswered,
      'currentPracticeCorrectStreak': currentPracticeCorrectStreak,
      'maxPracticeCorrectStreak': maxPracticeCorrectStreak,
      'maxPracticeSessionSeconds': maxPracticeSessionSeconds,
      'totalVersusMatches': totalVersusMatches,
      'totalVersusWins': totalVersusWins,
      'currentVersusWinStreak': currentVersusWinStreak,
      'maxVersusWinStreak': maxVersusWinStreak,
      'maxVersusScoreInAWin': maxVersusScoreInAWin,
      'maxVersusScoreEver': maxVersusScoreEver,
      'hasVersusWinNoWrongAnswers': hasVersusWinNoWrongAnswers,
      'hasVersusWinDoubleOpponent': hasVersusWinDoubleOpponent,
      'versusWinsLeavingRivalUnder5': versusWinsLeavingRivalUnder5,
      'learnedTableViewCounts':
          learnedTableViewCounts.map((int k, int v) => MapEntry('$k', v)),
      'usageDates': usageDates.toList(),
    };
  }
}
