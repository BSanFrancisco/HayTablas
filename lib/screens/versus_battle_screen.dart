import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/exam_timer.dart';
import '../services/stats_repository.dart';
import '../theme/app_colors.dart';
import 'versus_result_screen.dart';

/// Genera una pregunta de multiplicación al azar usando las tablas
/// elegidas para la partida.
Question _generateVersusQuestion(List<int> tables, Random random) {
  final int table = tables[random.nextInt(tables.length)];
  final int multiplier = 1 + random.nextInt(10);
  if (random.nextBool()) {
    return Question(displayLeft: table, displayRight: multiplier);
  }
  return Question(displayLeft: multiplier, displayRight: table);
}

/// Genera 3 opciones de respuesta (la correcta + 2 incorrectas
/// cercanas), en orden aleatorio, para el modo multiple choice.
List<int> _generateVersusOptions(int correctAnswer, Random random) {
  final Set<int> wrongOptions = <int>{};
  int attempts = 0;
  while (wrongOptions.length < 2 && attempts < 50) {
    attempts++;
    final int offset = (random.nextInt(10) + 1) * (random.nextBool() ? 1 : -1);
    final int candidate = correctAnswer + offset;
    if (candidate > 0 && candidate != correctAnswer) {
      wrongOptions.add(candidate);
    }
  }
  // Red de seguridad, por si el azar no encontró 2 candidatos válidos.
  int fallback = 1;
  while (wrongOptions.length < 2) {
    if (fallback != correctAnswer && !wrongOptions.contains(fallback)) {
      wrongOptions.add(fallback);
    }
    fallback++;
  }

  final List<int> options = <int>[correctAnswer, ...wrongOptions];
  options.shuffle(random);
  return options;
}

/// Pantalla de batalla del modo VERSUS: pantalla dividida en dos
/// mitades con fondos de distinto color. La mitad de abajo se lee
/// normal (Jugador 1); la de arriba está invertida 180° (Jugador 2),
/// para que cada una pueda leerla sentada del lado opuesto de la
/// mesa. Ambas responden preguntas de multiple choice de forma
/// independiente y simultánea contra un cronómetro compartido de
/// 1 minuto. Gana quien sume más puntos.
class VersusBattleScreen extends StatefulWidget {
  const VersusBattleScreen({super.key, required this.tables});

  final List<int> tables;

  @override
  State<VersusBattleScreen> createState() => _VersusBattleScreenState();
}

class _VersusBattleScreenState extends State<VersusBattleScreen> {
  static const int _totalSeconds = 60;
  static const Duration _feedbackDelay = Duration(milliseconds: 350);

  final Random _random = Random();
  final StatsRepository _statsRepository = StatsRepository();
  late final ExamTimer _timer;

  int _secondsRemaining = _totalSeconds;
  bool _finished = false;

  late Question _bottomQuestion;
  late List<int> _bottomOptions;
  int _bottomScore = 0;
  int? _bottomSelected;
  bool _bottomLocked = false;
  bool _bottomHadWrongAnswer = false;

  late Question _topQuestion;
  late List<int> _topOptions;
  int _topScore = 0;
  int? _topSelected;
  bool _topLocked = false;
  bool _topHadWrongAnswer = false;

  @override
  void initState() {
    super.initState();
    _bottomQuestion = _generateVersusQuestion(widget.tables, _random);
    _bottomOptions = _generateVersusOptions(_bottomQuestion.correctAnswer, _random);
    _topQuestion = _generateVersusQuestion(widget.tables, _random);
    _topOptions = _generateVersusOptions(_topQuestion.correctAnswer, _random);

    _timer = ExamTimer(
      totalSeconds: _totalSeconds,
      onTick: _handleTick,
      onTimeUp: _finishMatch,
    );
    _timer.start();
  }

  void _handleTick(int secondsRemaining) {
    if (!mounted || _finished) {
      return;
    }
    setState(() {
      _secondsRemaining = secondsRemaining;
    });
  }

  void _onSelectOption({required bool isTop, required int option}) {
    if (_finished) {
      return;
    }
    if (isTop) {
      if (_topLocked) {
        return;
      }
      final bool correct = option == _topQuestion.correctAnswer;
      setState(() {
        _topLocked = true;
        _topSelected = option;
        if (correct) {
          _topScore++;
        } else {
          _topHadWrongAnswer = true;
        }
      });
    } else {
      if (_bottomLocked) {
        return;
      }
      final bool correct = option == _bottomQuestion.correctAnswer;
      setState(() {
        _bottomLocked = true;
        _bottomSelected = option;
        if (correct) {
          _bottomScore++;
        } else {
          _bottomHadWrongAnswer = true;
        }
      });
    }

    Future<void>.delayed(_feedbackDelay, () {
      if (!mounted || _finished) {
        return;
      }
      setState(() {
        if (isTop) {
          _topQuestion = _generateVersusQuestion(widget.tables, _random);
          _topOptions = _generateVersusOptions(_topQuestion.correctAnswer, _random);
          _topLocked = false;
          _topSelected = null;
        } else {
          _bottomQuestion = _generateVersusQuestion(widget.tables, _random);
          _bottomOptions =
              _generateVersusOptions(_bottomQuestion.correctAnswer, _random);
          _bottomLocked = false;
          _bottomSelected = null;
        }
      });
    });
  }

  void _finishMatch() {
    if (_finished) {
      return;
    }
    _finished = true;
    _timer.stop();
    unawaited(
      _statsRepository.recordVersusMatch(
        bottomScore: _bottomScore,
        topScore: _topScore,
        bottomHadWrongAnswer: _bottomHadWrongAnswer,
        topHadWrongAnswer: _topHadWrongAnswer,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => VersusResultScreen(
          tables: widget.tables,
          bottomScore: _bottomScore,
          topScore: _topScore,
        ),
      ),
    );
  }

  Future<void> _onCancelPressed() async {
    if (_finished) {
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('¿Terminar la partida?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('SEGUIR'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted && !_finished) {
      _finished = true;
      _timer.stop();
      unawaited(_statsRepository.markCancelled());
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int minutes = _secondsRemaining ~/ 60;
    final int seconds = _secondsRemaining % 60;
    final String timeLabel = '$minutes:${seconds.toString().padLeft(2, '0')}';
    final bool isUrgent = _secondsRemaining <= 15;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Transform.rotate(
                  angle: pi,
                  child: _PlayerHalf(
                    backgroundColor: AppColors.candyPink,
                    playerLabel: 'Jugador 2',
                    score: _topScore,
                    question: _topQuestion,
                    options: _topOptions,
                    selectedOption: _topSelected,
                    locked: _topLocked,
                    onSelect: (int option) =>
                        _onSelectOption(isTop: true, option: option),
                  ),
                ),
              ),
              _MiddleDivider(
                timeLabel: timeLabel,
                isUrgent: isUrgent,
                onCancelPressed: _onCancelPressed,
              ),
              Expanded(
                child: _PlayerHalf(
                  backgroundColor: AppColors.primaryBlue,
                  playerLabel: 'Jugador 1',
                  score: _bottomScore,
                  question: _bottomQuestion,
                  options: _bottomOptions,
                  selectedOption: _bottomSelected,
                  locked: _bottomLocked,
                  onSelect: (int option) =>
                      _onSelectOption(isTop: false, option: option),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiddleDivider extends StatelessWidget {
  const _MiddleDivider({
    required this.timeLabel,
    required this.isUrgent,
    required this.onCancelPressed,
  });

  final String timeLabel;
  final bool isUrgent;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final Color color = isUrgent ? AppColors.errorRed : AppColors.textDark;

    return Container(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Copia del cronómetro invertida 180°: para quien juega
          // arriba (con toda su interfaz al revés), esta copia se ve
          // derecha desde su lado de la mesa.
          Transform.rotate(
            angle: pi,
            child: _TimeChip(label: timeLabel, color: color),
          ),
          IconButton(
            onPressed: onCancelPressed,
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          // Copia normal, para quien juega abajo.
          _TimeChip(label: timeLabel, color: color),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.timer_rounded, color: color, size: 18),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PlayerHalf extends StatelessWidget {
  const _PlayerHalf({
    required this.backgroundColor,
    required this.playerLabel,
    required this.score,
    required this.question,
    required this.options,
    required this.selectedOption,
    required this.locked,
    required this.onSelect,
  });

  final Color backgroundColor;
  final String playerLabel;
  final int score;
  final Question question;
  final List<int> options;
  final int? selectedOption;
  final bool locked;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$playerLabel  ·  $score pts',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${question.displayLeft} × ${question.displayRight} =',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: options.map((int option) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _OptionButton(
                  value: option,
                  isSelected: selectedOption == option,
                  isCorrect: option == question.correctAnswer,
                  locked: locked,
                  onTap: () => onSelect(option),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.value,
    required this.isSelected,
    required this.isCorrect,
    required this.locked,
    required this.onTap,
  });

  final int value;
  final bool isSelected;
  final bool isCorrect;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color foreground = AppColors.textDark;

    if (locked) {
      if (isCorrect) {
        background = AppColors.leafGreen;
        foreground = Colors.white;
      } else if (isSelected) {
        background = AppColors.errorRed;
        foreground = Colors.white;
      } else {
        background = Colors.white.withValues(alpha: 0.5);
      }
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: locked ? null : onTap,
        child: Container(
          width: 64,
          height: 56,
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
