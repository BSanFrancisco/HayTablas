import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../services/achievements_repository.dart';
import '../services/records_repository.dart';
import '../services/stats_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

/// Pantalla de Logros: muestra los 100 logros agrupados por rango,
/// con los desbloqueados marcados con trofeo y los pendientes con
/// candado (mostrando igualmente cómo se consiguen, para que sirvan
/// de guía y motivación).
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementsRepository _repository = AchievementsRepository();
  final StatsRepository _statsRepository = StatsRepository();
  final RecordsRepository _recordsRepository = RecordsRepository();

  bool _loading = true;
  bool _deleting = false;
  AchievementsSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final AchievementsSnapshot snapshot = await _repository.evaluate();
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  Future<void> _onDeleteAllPressed() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('¿Eliminar todos los logros?'),
          content: const Text(
            'Se va a reiniciar todo el progreso de logros y, además, '
            'se van a borrar los récords guardados en Mejores Tiempos '
            '(varios logros dependen de esos récords). Esta acción no '
            'se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'ELIMINAR TODO',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deleting = true;
    });

    await _statsRepository.clearAll();
    await _recordsRepository.clearAll();

    if (!mounted) {
      return;
    }

    setState(() {
      _deleting = false;
    });

    await _load();

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se eliminaron todos los logros y los récords.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AchievementsSnapshot? snapshot = _snapshot;

    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 28),
                  color: AppColors.textDark,
                ),
                const Expanded(
                  child: Text(
                    '🏅 LOGROS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading || snapshot == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...<Widget>[
              _ProgressHeader(
                unlocked: snapshot.unlockedCount,
                total: snapshot.totalCount,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: <Widget>[
                    ...AchievementRank.values.map((AchievementRank rank) {
                      final List<Achievement> inRank = snapshot.achievements
                          .where((Achievement a) => a.rank == rank)
                          .toList();
                      final int unlockedInRank = inRank
                          .where((Achievement a) => snapshot.isUnlocked(a))
                          .length;
                      return _RankSection(
                        rank: rank,
                        achievements: inRank,
                        unlockedInRank: unlockedInRank,
                        isUnlocked: snapshot.isUnlocked,
                      );
                    }),
                    const SizedBox(height: 28),
                    _DeleteAllButton(
                      loading: _deleting,
                      onPressed: _deleting ? null : _onDeleteAllPressed,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.unlocked, required this.total});

  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '$unlocked / $total logros desbloqueados',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.skyBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.trophyGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankSection extends StatelessWidget {
  const _RankSection({
    required this.rank,
    required this.achievements,
    required this.unlockedInRank,
    required this.isUnlocked,
  });

  final AchievementRank rank;
  final List<Achievement> achievements;
  final int unlockedInRank;
  final bool Function(Achievement achievement) isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(rank.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                rank.displayName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                '$unlockedInRank/${achievements.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...achievements.map(
            (Achievement achievement) => _AchievementTile(
              achievement: achievement,
              unlocked: isUnlocked(achievement),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón al final de la lista de logros para reiniciar todo el
/// progreso (estadísticas y récords de Mejores Tiempos).
class _DeleteAllButton extends StatelessWidget {
  const _DeleteAllButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.errorRed,
        side: const BorderSide(color: AppColors.errorRed),
      ),
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.errorRed,
              ),
            )
          : const Icon(Icons.delete_forever_rounded),
      label: Text(
        loading ? 'ELIMINANDO...' : 'ELIMINAR TODOS LOS LOGROS',
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.unlocked});

  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.cardWhite
            : AppColors.cardWhite.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: unlocked
            ? Border.all(color: AppColors.trophyGold, width: 1.5)
            : null,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            unlocked ? Icons.emoji_events_rounded : Icons.lock_rounded,
            color: unlocked ? AppColors.trophyGold : AppColors.textMuted,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: unlocked
                        ? AppColors.textDark
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
