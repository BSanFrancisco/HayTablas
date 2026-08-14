import 'package:flutter/material.dart';

import '../models/exam_config.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/primary_button.dart';
import 'countdown_screen.dart';

/// Pantalla de preparación: resume qué se va a evaluar antes de
/// empezar el examen y permite elegir la cantidad de preguntas
/// (10 o 20), de la cual se deriva automáticamente el tiempo máximo.
class PreparationScreen extends StatefulWidget {
  const PreparationScreen({super.key, required this.config});

  final ExamConfig config;

  @override
  State<PreparationScreen> createState() => _PreparationScreenState();
}

class _PreparationScreenState extends State<PreparationScreen> {
  late int _questionCount = widget.config.questionCount;

  int get _durationSeconds => ExamConfig.durationForQuestionCount(_questionCount);

  void _onSelectQuestionCount(int count) {
    if (_questionCount == count) {
      return;
    }
    setState(() {
      _questionCount = count;
    });
  }

  void _onStartPressed(BuildContext context) {
    final ExamConfig config = ExamConfig(
      tables: widget.config.tables,
      questionCount: _questionCount,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CountdownScreen(config: config),
      ),
    );
  }

  void _onTablasPressed(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 30),
              color: AppColors.textDark,
            ),
            const SizedBox(height: 4),
            const Text(
              'PREPARADO PARA\nEL EXAMEN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1.1,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 28),
            // El cuadro de "Tablas" funciona además como botón: toca
            // acá para volver a la pantalla principal y elegir otras
            // tablas (reemplaza al botón "TABLAS" que estaba arriba).
            _InfoCard(
              icon: Icons.grid_view_rounded,
              iconColor: AppColors.primaryBlue,
              label: 'Tablas',
              value: widget.config.displayJoined,
              onTap: () => _onTablasPressed(context),
            ),
            const SizedBox(height: 18),
            _QuestionCountSelector(
              selected: _questionCount,
              onSelected: _onSelectQuestionCount,
            ),
            const SizedBox(height: 18),
            _InfoCard(
              icon: Icons.timer_rounded,
              iconColor: AppColors.candyPink,
              label: 'Tiempo máximo',
              value: '$_durationSeconds segundos',
            ),
            const Spacer(),
            PrimaryButton(
              label: 'INICIAR',
              icon: Icons.play_arrow_rounded,
              backgroundColor: AppColors.leafGreen,
              onPressed: () => _onStartPressed(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _QuestionCountSelector extends StatelessWidget {
  const _QuestionCountSelector({
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.leafGreenDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.list_alt_rounded,
              color: AppColors.leafGreenDark,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Cantidad de\npreguntas',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          _CountChip(
            label: '10',
            isSelected: selected == 10,
            onTap: () => onSelected(10),
          ),
          const SizedBox(width: 8),
          _CountChip(
            label: '20',
            isSelected: selected == 20,
            onTap: () => onSelected(20),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.leafGreen : AppColors.skyBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  /// Si se especifica, todo el cuadro se vuelve tocable (se usa en
  /// "Tablas" para volver a la pantalla principal).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isTappable = onTap != null;
    final BorderRadius borderRadius = BorderRadius.circular(24);

    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: borderRadius,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          if (isTappable)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted.withValues(alpha: 0.6),
              size: 28,
            ),
        ],
      ),
    );

    if (!isTappable) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
