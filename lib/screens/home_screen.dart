import 'package:flutter/material.dart';

import '../models/exam_config.dart';
import '../services/achievements_repository.dart';
import '../services/stats_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/table_selector_grid.dart';
import 'achievements_screen.dart';
import 'best_times_screen.dart';
import 'countdown_screen.dart';
import 'learn_table_selection_screen.dart';
import 'practice_screen.dart';
import 'preparation_screen.dart';
import 'reverse_practice_screen.dart';
import 'versus_battle_screen.dart';

/// Pantalla principal: selección de qué tablas de multiplicar se
/// quieren practicar, y acceso a los demás modos de la app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<int> _availableTables = <int>[2, 3, 4, 5, 6, 7, 8, 9, 10];

  final Set<int> _selectedTables = <int>{};
  final StatsRepository _statsRepository = StatsRepository();
  final AchievementsRepository _achievementsRepository =
      AchievementsRepository();

  int? _unlockedAchievements;
  int _totalAchievements = 100;

  @override
  void initState() {
    super.initState();
    _loadAchievementsProgress();
  }

  Future<void> _loadAchievementsProgress() async {
    final AchievementsSnapshot snapshot = await _achievementsRepository.evaluate();
    if (!mounted) {
      return;
    }
    setState(() {
      _unlockedAchievements = snapshot.unlockedCount;
      _totalAchievements = snapshot.totalCount;
    });
  }

  void _toggleTable(int table) {
    setState(() {
      if (_selectedTables.contains(table)) {
        _selectedTables.remove(table);
      } else {
        _selectedTables.add(table);
      }
    });
  }

  void _showSelectTablesWarning() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seleccioná al menos una tabla para comenzar.'),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onContinuePressed() {
    if (_selectedTables.isEmpty) {
      _showSelectTablesWarning();
      return;
    }

    final List<int> tables = _selectedTables.toList();
    _statsRepository.markVisited(AppSection.examen);
    _statsRepository.markTablesUsed(tables);

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => PreparationScreen(
              config: ExamConfig(tables: tables),
            ),
          ),
        )
        .then((_) => _loadAchievementsProgress());
  }

  void _onBestTimesPressed() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(builder: (_) => const BestTimesScreen()),
        )
        .then((_) => _loadAchievementsProgress());
  }

  void _onLearnPressed() {
    _statsRepository.markVisited(AppSection.aprender);
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => const LearnTableSelectionScreen(),
          ),
        )
        .then((_) => _loadAchievementsProgress());
  }

  void _onPracticePressed() {
    if (_selectedTables.isEmpty) {
      _showSelectTablesWarning();
      return;
    }

    final List<int> tables = _selectedTables.toList();
    _statsRepository.markVisited(AppSection.practicar);
    _statsRepository.markTablesUsed(tables);

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => CountdownScreen(
              config: ExamConfig(tables: tables),
              nextScreenBuilder: (_) => PracticeScreen(
                config: ExamConfig(tables: tables),
              ),
            ),
          ),
        )
        .then((_) => _loadAchievementsProgress());
  }

  void _onInversoPressed() {
    if (_selectedTables.isEmpty) {
      _showSelectTablesWarning();
      return;
    }

    final List<int> tables = _selectedTables.toList();
    _statsRepository.markTablesUsed(tables);

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => CountdownScreen(
              config: ExamConfig(tables: tables),
              nextScreenBuilder: (_) => ReversePracticeScreen(
                config: ExamConfig(tables: tables),
              ),
            ),
          ),
        )
        .then((_) => _loadAchievementsProgress());
  }

  void _onVersusPressed() {
    if (_selectedTables.isEmpty) {
      _showSelectTablesWarning();
      return;
    }

    final List<int> tables = _selectedTables.toList();
    _statsRepository.markVisited(AppSection.versus);
    _statsRepository.markTablesUsed(tables);

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => CountdownScreen(
              config: ExamConfig(tables: tables),
              nextScreenBuilder: (_) => VersusBattleScreen(tables: tables),
            ),
          ),
        )
        .then((_) => _loadAchievementsProgress());
  }

  void _onAchievementsPressed() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(builder: (_) => const AchievementsScreen()),
        )
        .then((_) => _loadAchievementsProgress());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        // Sin scroll: todo el contenido tiene que entrar en la
        // pantalla. El título (más abajo) es el único elemento de
        // tamaño variable: absorbe todo el espacio vertical que
        // sobra para que el resto (subtítulo, tablas, botones y
        // firma) siempre quepa sin necesidad de hacer scroll. El
        // chip de logros se superpone con un Stack (no ocupa lugar
        // en el Column) para no afectar ese ajuste de altura.
        child: Stack(
          children: <Widget>[
            Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    'TABLAS DE\nMULTIPLICAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Qué tablas podemos usar?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            TableSelectorGrid(
              availableTables: _availableTables,
              selectedTables: _selectedTables,
              onToggle: _toggleTable,
              compact: true,
              crossAxisCount: 3,
              stretchToWidth: true,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'EXAMEN',
              icon: Icons.arrow_forward_rounded,
              onPressed: _onContinuePressed,
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ModeIconButton(
                    icon: Icons.school_rounded,
                    label: 'PRACTICAR',
                    color: AppColors.leafGreen,
                    onTap: _onPracticePressed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeIconButton(
                    icon: Icons.sync_rounded,
                    label: 'INVERSO',
                    color: AppColors.violetPurple,
                    onTap: _onInversoPressed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeIconButton(
                    icon: Icons.bolt_rounded,
                    label: 'VERSUS',
                    color: AppColors.primaryBlueDark,
                    onTap: _onVersusPressed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeIconButton(
                    icon: Icons.emoji_events_rounded,
                    label: 'MEJORES\nTIEMPOS',
                    color: AppColors.trophyGold,
                    onTap: _onBestTimesPressed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeIconButton(
                    icon: Icons.psychology_rounded,
                    label: 'APRENDER',
                    color: AppColors.candyPink,
                    onTap: _onLearnPressed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'By SebaLima',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
          ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _AchievementsChip(
                unlocked: _unlockedAchievements,
                total: _totalAchievements,
                onTap: _onAchievementsPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón cuadrado con ícono grande y texto pequeño opcional, usado
/// para los accesos a Practicar, Aprender y Mejores Tiempos desde la
/// pantalla principal. Su tamaño coincide con el de los casilleros de
/// tablas reducidos.
class _ModeIconButton extends StatelessWidget {
  const _ModeIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(height: 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip pequeño en la esquina superior derecha que muestra el
/// progreso de logros ("🏅 X/100") y lleva a la pantalla de Logros.
/// Se superpone con [Positioned] para no ocupar espacio en el layout
/// principal, que ya está ajustado al 100% de la pantalla sin scroll.
class _AchievementsChip extends StatelessWidget {
  const _AchievementsChip({
    required this.unlocked,
    required this.total,
    required this.onTap,
  });

  final int? unlocked;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String label = unlocked == null ? '🏅' : '🏅 $unlocked/$total';

    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
