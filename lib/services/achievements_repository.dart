import '../data/achievements_data.dart';
import '../models/achievement.dart';
import '../models/player_stats.dart';
import '../models/table_record.dart';
import 'records_repository.dart';
import 'stats_repository.dart';

/// Resultado de evaluar los 100 logros contra el estado actual del
/// jugador: la lista completa (en orden), y cuáles están desbloqueados.
class AchievementsSnapshot {
  const AchievementsSnapshot({
    required this.achievements,
    required this.context,
    required this.unlockedIds,
  });

  final List<Achievement> achievements;
  final AchievementContext context;
  final Set<int> unlockedIds;

  bool isUnlocked(Achievement achievement) =>
      unlockedIds.contains(achievement.id);

  int get unlockedCount => unlockedIds.length;

  int get totalCount => achievements.length;
}

/// Junta las estadísticas ([StatsRepository]) y los récords
/// ([RecordsRepository]) guardados localmente, y evalúa los 100 logros.
/// Los logros 98 y 100 son especiales: dependen de cuántos de los
/// demás logros ya están desbloqueados, así que se arman acá en vez de
/// en la lista base.
class AchievementsRepository {
  final RecordsRepository _recordsRepository = RecordsRepository();
  final StatsRepository _statsRepository = StatsRepository();

  Future<AchievementsSnapshot> evaluate() async {
    final PlayerStats stats = await _statsRepository.getStats();
    final List<TableRecord> records = await _recordsRepository.getAllRecords();
    final AchievementContext context =
        AchievementContext(stats: stats, records: records);

    final List<Achievement> base = buildBaseAchievements();
    final Set<int> unlockedIds = <int>{};
    for (final Achievement achievement in base) {
      if (achievement.isUnlocked(context)) {
        unlockedIds.add(achievement.id);
      }
    }

    final bool unlocked98 = List<int>.generate(97, (int i) => i + 1)
        .every(unlockedIds.contains);
    final Achievement achievement98 = Achievement(
      id: 98,
      rank: AchievementRank.legendario,
      name: 'El maestro de los maestros',
      description: 'Desbloqueá los 97 logros anteriores.',
      isUnlocked: (_) => unlocked98,
    );
    if (unlocked98) {
      unlockedIds.add(98);
    }

    final bool unlocked100 = unlocked98 && unlockedIds.contains(99);
    final Achievement achievement100 = Achievement(
      id: 100,
      rank: AchievementRank.legendario,
      name: 'LEGENDARIO',
      description: 'Desbloqueá los 99 logros anteriores.',
      isUnlocked: (_) => unlocked100,
    );
    if (unlocked100) {
      unlockedIds.add(100);
    }

    final List<Achievement> all = <Achievement>[
      ...base,
      achievement98,
      achievement100,
    ]..sort((Achievement a, Achievement b) => a.id.compareTo(b.id));

    return AchievementsSnapshot(
      achievements: all,
      context: context,
      unlockedIds: unlockedIds,
    );
  }
}
