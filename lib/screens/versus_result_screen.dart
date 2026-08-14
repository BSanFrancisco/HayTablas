import 'package:flutter/material.dart';

import '../models/exam_config.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/primary_button.dart';
import 'countdown_screen.dart';
import 'versus_battle_screen.dart';

/// Pantalla de resultado del modo VERSUS: anuncia a pantalla completa
/// quién ganó la partida, comparando los puntos de cada jugadora.
class VersusResultScreen extends StatelessWidget {
  const VersusResultScreen({
    super.key,
    required this.tables,
    required this.bottomScore,
    required this.topScore,
  });

  final List<int> tables;
  final int bottomScore;
  final int topScore;

  bool get _isTie => bottomScore == topScore;
  bool get _bottomWins => bottomScore > topScore;

  void _onPlayAgain(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CountdownScreen(
          config: ExamConfig(tables: tables),
          nextScreenBuilder: (_) => VersusBattleScreen(tables: tables),
        ),
      ),
    );
  }

  void _onGoHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final String title = _isTie
        ? '🤝\n¡EMPATE!'
        : _bottomWins
            ? '🏆\n¡GANÓ JUGADOR 1!'
            : '🏆\n¡GANÓ JUGADOR 2!';

    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ScoreCard(
                    label: 'Jugador 1',
                    score: bottomScore,
                    color: AppColors.primaryBlue,
                    highlighted: _bottomWins && !_isTie,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ScoreCard(
                    label: 'Jugador 2',
                    score: topScore,
                    color: AppColors.candyPink,
                    highlighted: !_bottomWins && !_isTie,
                  ),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(
              label: 'JUGAR DE NUEVO',
              icon: Icons.refresh_rounded,
              backgroundColor: AppColors.leafGreen,
              onPressed: () => _onPlayAgain(context),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'VOLVER AL INICIO',
              icon: Icons.home_rounded,
              onPressed: () => _onGoHome(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.color,
    required this.highlighted,
  });

  final String label;
  final int score;
  final Color color;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: highlighted
            ? Border.all(color: AppColors.trophyGold, width: 4)
            : null,
      ),
      child: Column(
        children: <Widget>[
          if (highlighted)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text('👑', style: TextStyle(fontSize: 28)),
            ),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
