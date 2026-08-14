import 'dart:async';

import 'package:flutter/material.dart';

import '../models/exam_result.dart';
import '../models/question.dart';
import '../services/records_repository.dart';
import '../services/stats_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/primary_button.dart';
import 'answer_review_screen.dart';
import 'best_times_screen.dart';
import 'countdown_screen.dart';

/// Pantalla de resultados: calificación X/10, estadísticas, emoji
/// según el desempeño y el estado del récord para esta combinación de
/// tablas.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.result});

  final ExamResult result;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

/// Cómo se debe mostrar la información de récord en pantalla.
enum _RecordMessageType { newRecord, perfectNotBeaten, existingOnly, none }

class _ResultsScreenState extends State<ResultsScreen> {
  final RecordsRepository _repository = RecordsRepository();
  final StatsRepository _statsRepository = StatsRepository();

  bool _loading = true;
  _RecordMessageType _messageType = _RecordMessageType.none;
  int? _bestTimeSeconds;

  @override
  void initState() {
    super.initState();
    _resolveRecord();
  }

  Future<void> _resolveRecord() async {
    final ExamResult result = widget.result;
    final String key = result.config.recordKey;

    if (result.isEligibleForRecord) {
      // Solamente un examen perfecto (10/10) puede establecer o
      // mejorar un récord. Antes de actualizar, vemos si ya existía
      // un récord previo para distinguir "primer récord" de
      // "mejoró un récord propio" (para el logro correspondiente).
      final bool hadExistingRecord =
          await _repository.getRecordFor(key) != null;

      final bool isNewRecord = await _repository.tryUpdateRecord(
        recordKey: key,
        tables: result.config.tables,
        questionCount: result.config.questionCount,
        candidateTimeMilliseconds: result.elapsedMilliseconds,
      );

      if (!mounted) {
        return;
      }

      if (isNewRecord) {
        if (hadExistingRecord) {
          await _statsRepository.recordBeatOwnRecord();
        }
        setState(() {
          _messageType = _RecordMessageType.newRecord;
          _bestTimeSeconds = result.timeUsedSeconds;
          _loading = false;
        });
      } else {
        final record = await _repository.getRecordFor(key);
        if (!mounted) {
          return;
        }
        setState(() {
          _messageType = _RecordMessageType.perfectNotBeaten;
          _bestTimeSeconds = record?.bestTimeSeconds;
          _loading = false;
        });
      }
    } else {
      final record = await _repository.getRecordFor(key);
      if (!mounted) {
        return;
      }
      setState(() {
        _messageType = record != null
            ? _RecordMessageType.existingOnly
            : _RecordMessageType.none;
        _bestTimeSeconds = record?.bestTimeSeconds;
        _loading = false;
      });
    }
  }

  // El emoji se calcula por porcentaje de aciertos para que la misma
  // escala (0-4/10:😭, 5-6/10:😟, 7-9/10:😊, 10/10:🤩👑) se aplique
  // proporcionalmente tanto a exámenes de 10 como de 20 preguntas.
  String get _emoji {
    final int correct = widget.result.correctCount;
    final int total = widget.result.totalCount;
    if (total <= 0) {
      return '😭';
    }
    final double percentage = correct / total * 100;
    if (percentage >= 100) {
      return '🤩👑';
    } else if (percentage >= 70) {
      return '😊';
    } else if (percentage >= 50) {
      return '😟';
    }
    return '😭';
  }

  void _onRestartPressed() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CountdownScreen(config: widget.result.config),
      ),
    );
  }

  void _onBestTimesPressed() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BestTimesScreen()),
    );
  }

  void _onGoHomePressed() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onShowAnswers({required bool correct}) {
    final List<AnsweredQuestion> filtered = widget.result.answers
        .where((AnsweredQuestion a) => a.isCorrect == correct)
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnswerReviewScreen(
          title: correct ? 'Respuestas correctas' : 'Respuestas incorrectas',
          answers: filtered,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExamResult result = widget.result;

    return Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 8),
              Text(
                _emoji,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 96),
              ),
              const SizedBox(height: 8),
              Text(
                '${result.correctCount} / ${result.totalCount}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      label: 'Correctas',
                      value: '${result.correctCount}',
                      color: AppColors.leafGreenDark,
                      onTap: () => _onShowAnswers(correct: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Incorrectas',
                      value: '${result.incorrectCount}',
                      color: AppColors.errorRed,
                      onTap: () => _onShowAnswers(correct: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Tiempo',
                      value: '${result.timeUsedSeconds}s',
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _RecordBanner(
                  type: _messageType,
                  currentTimeSeconds: result.timeUsedSeconds,
                  bestTimeSeconds: _bestTimeSeconds,
                ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'REINICIAR',
                icon: Icons.refresh_rounded,
                backgroundColor: AppColors.leafGreen,
                onPressed: _onRestartPressed,
              ),
              const SizedBox(height: 14),
              SecondaryButton(
                label: 'VER MEJORES TIEMPOS',
                icon: Icons.emoji_events_rounded,
                onPressed: _onBestTimesPressed,
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _onGoHomePressed,
                icon: const Icon(Icons.home_rounded, color: AppColors.textMuted),
                label: const Text(
                  'Elegir otras tablas',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isTappable = onTap != null;

    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: <Widget>[
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              if (isTappable) ...<Widget>[
                const SizedBox(height: 2),
                Icon(
                  Icons.touch_app_rounded,
                  size: 14,
                  color: color.withOpacity(0.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordBanner extends StatelessWidget {
  const _RecordBanner({
    required this.type,
    required this.currentTimeSeconds,
    required this.bestTimeSeconds,
  });

  final _RecordMessageType type;
  final int currentTimeSeconds;
  final int? bestTimeSeconds;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _RecordMessageType.newRecord:
        return _banner(
          background: AppColors.trophyGold,
          foreground: Colors.white,
          child: Column(
            children: <Widget>[
              const Text(
                '🎉 ¡NUEVO RÉCORD! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currentTimeSeconds segundos',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case _RecordMessageType.perfectNotBeaten:
        return _banner(
          background: AppColors.cardWhite,
          foreground: AppColors.textDark,
          child: Column(
            children: <Widget>[
              const Text(
                '¡Excelente!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text('Tu tiempo: $currentTimeSeconds segundos'),
              if (bestTimeSeconds != null)
                Text('Mejor tiempo: $bestTimeSeconds segundos'),
            ],
          ),
        );
      case _RecordMessageType.existingOnly:
        return _banner(
          background: AppColors.cardWhite,
          foreground: AppColors.textDark,
          child: Text(
            '🏆 Mejor tiempo: $bestTimeSeconds segundos',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        );
      case _RecordMessageType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _banner({
    required Color background,
    required Color foreground,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        textAlign: TextAlign.center,
        child: child,
      ),
    );
  }
}
