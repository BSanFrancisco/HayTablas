import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exam_config.dart';
import '../models/question.dart';
import '../services/stats_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

/// Modo "Practicar": preguntas ilimitadas, sin cronómetro, sin
/// puntaje y sin récords. El niño responde una multiplicación a la
/// vez con ENTER y ve inmediatamente si acertó, antes de pasar a la
/// siguiente pregunta. El teclado numérico permanece abierto todo el
/// tiempo.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.config});

  final ExamConfig config;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

enum _Feedback { none, correct, incorrect }

class _PracticeScreenState extends State<PracticeScreen> {
  final Random _random = Random();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final StatsRepository _statsRepository = StatsRepository();
  final Stopwatch _sessionStopwatch = Stopwatch();

  late Question _currentQuestion;
  _Feedback _feedback = _Feedback.none;
  bool _canSubmit = true;
  int? _lastCorrectAnswer;

  @override
  void initState() {
    super.initState();
    _currentQuestion = _generateQuestion();
    _sessionStopwatch.start();
    unawaited(_statsRepository.markPracticeStarted(widget.config.tables));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  Question _generateQuestion() {
    final List<int> tables = widget.config.tables;
    final int table = tables[_random.nextInt(tables.length)];
    final int multiplier = 1 + _random.nextInt(10);
    if (_random.nextBool()) {
      return Question(displayLeft: table, displayRight: multiplier);
    }
    return Question(displayLeft: multiplier, displayRight: table);
  }

  void _submitAnswer(String rawValue) {
    if (!_canSubmit) {
      return;
    }
    final String trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      _refocus();
      return;
    }

    final int? parsed = int.tryParse(trimmed);
    final bool isCorrect =
        parsed != null && parsed == _currentQuestion.correctAnswer;

    setState(() {
      _feedback = isCorrect ? _Feedback.correct : _Feedback.incorrect;
      _lastCorrectAnswer = _currentQuestion.correctAnswer;
      _canSubmit = false;
    });

    unawaited(_statsRepository.recordPracticeAnswer(isCorrect: isCorrect));

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentQuestion = _generateQuestion();
        _feedback = _Feedback.none;
        _canSubmit = true;
        _answerController.clear();
      });
      _refocus();
    });
  }

  void _refocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  Future<void> _onCancelPressed() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('¿Querés terminar la práctica?'),
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

    if (confirmed == true && mounted) {
      _sessionStopwatch.stop();
      unawaited(_statsRepository.markCancelled());
      unawaited(
        _statsRepository
            .recordPracticeSessionSeconds(_sessionStopwatch.elapsed.inSeconds),
      );
      // Vuelve a la pantalla principal (no al flujo de examen): no
      // hay nada que guardar en este modo.
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color feedbackColor = _feedback == _Feedback.correct
        ? AppColors.leafGreenDark
        : _feedback == _Feedback.incorrect
            ? AppColors.errorRed
            : AppColors.textDark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AppBackground(
          child: Column(
            children: <Widget>[
              const Text(
                '🎓 MODO PRÁCTICA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${_currentQuestion.displayLeft} × '
                        '${_currentQuestion.displayRight} =',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: _answerController,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          textAlign: TextAlign.center,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlueDark,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            hintText: '?',
                          ),
                          onSubmitted: _submitAnswer,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton.icon(
                          onPressed: _onCancelPressed,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.errorRed,
                          ),
                          label: const Text(
                            'CANCELAR',
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: _feedback == _Feedback.none
                            ? const SizedBox.shrink()
                            : Text(
                                _feedback == _Feedback.correct
                                    ? '¡Correcto! 😊'
                                    : 'Incorrecto 😅 era $_lastCorrectAnswer',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: feedbackColor,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
