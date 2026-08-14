import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exam_config.dart';
import '../models/exam_result.dart';
import '../models/question.dart';
import '../services/exam_timer.dart';
import '../services/question_generator.dart';
import '../services/stats_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import 'results_screen.dart';

/// Pantalla del examen: muestra una multiplicación a la vez, recibe la
/// respuesta por teclado numérico y avanza automáticamente al
/// presionar ENTER. Termina cuando se responden las 10 preguntas o
/// cuando se agotan los 60 segundos, lo que ocurra primero.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key, required this.config});

  final ExamConfig config;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final List<Question> _questions;
  late final ExamTimer _timer;

  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<AnsweredQuestion> _answers = <AnsweredQuestion>[];
  final StatsRepository _statsRepository = StatsRepository();
  late int _secondsRemaining;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = QuestionGenerator().generate(widget.config);
    _secondsRemaining = widget.config.examDurationSeconds;
    _timer = ExamTimer(
      totalSeconds: widget.config.examDurationSeconds,
      onTick: _handleTick,
      onTimeUp: () => _finishExam(byTimeout: true),
    );
    _timer.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  void _handleTick(int secondsRemaining) {
    if (!mounted || _finished) {
      return;
    }
    setState(() {
      _secondsRemaining = secondsRemaining;
    });
  }

  void _submitAnswer(String rawValue) {
    if (_finished) {
      return;
    }
    final String trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      // No dejamos avanzar con un campo vacío: el niño debe escribir
      // un número antes de confirmar con ENTER.
      _refocus();
      return;
    }

    final int? parsed = int.tryParse(trimmed);
    final Question question = _questions[_answers.length];
    final bool isCorrect = parsed != null && parsed == question.correctAnswer;

    setState(() {
      _answers.add(
        AnsweredQuestion(
          question: question,
          userAnswer: parsed,
          isCorrect: isCorrect,
        ),
      );
      _answerController.clear();
    });

    if (_answers.length >= _questions.length) {
      _finishExam(byTimeout: false);
    } else {
      _refocus();
    }
  }

  void _refocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
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
          title: const Text('¿Querés cancelar el examen?'),
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

    if (confirmed != true || !mounted || _finished) {
      return;
    }

    // Se cancela el examen sin guardar ningún resultado ni tocar
    // récords: se descarta todo y se vuelve a la pantalla de
    // preparación con la misma configuración de tablas.
    _finished = true;
    _timer.stop();
    unawaited(_statsRepository.markCancelled());
    Navigator.of(context).pop();
  }

  void _finishExam({required bool byTimeout}) {
    if (_finished) {
      return;
    }
    _finished = true;
    _timer.stop();

    if (byTimeout) {
      // Las preguntas que no llegaron a responderse cuentan como
      // incorrectas.
      while (_answers.length < _questions.length) {
        _answers.add(
          AnsweredQuestion(
            question: _questions[_answers.length],
            userAnswer: null,
            isCorrect: false,
          ),
        );
      }
    }

    final ExamResult result = ExamResult(
      config: widget.config,
      answers: List<AnsweredQuestion>.unmodifiable(_answers),
      elapsedMilliseconds: _timer.elapsedMilliseconds,
      finishedByTimeout: byTimeout,
    );

    unawaited(_statsRepository.recordExam(result));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultsScreen(result: result),
      ),
    );
  }

  @override
  void dispose() {
    _timer.dispose();
    _answerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int questionNumber = _answers.length + 1;
    final Question? current =
        _answers.length < _questions.length ? _questions[_answers.length] : null;
    final bool isUrgent = _secondsRemaining <= 10;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AppBackground(
          child: Column(
            children: <Widget>[
              _TimerBar(
                secondsRemaining: _secondsRemaining,
                isUrgent: isUrgent,
              ),
              const SizedBox(height: 6),
              Text(
                'Pregunta $questionNumber de ${_questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: Center(
                  child: current == null
                      ? const SizedBox.shrink()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${current.displayLeft} × ${current.displayRight} =',
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
                                enabled: !_finished,
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

class _TimerBar extends StatelessWidget {
  const _TimerBar({required this.secondsRemaining, required this.isUrgent});

  final int secondsRemaining;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final Color color = isUrgent ? AppColors.errorRed : AppColors.primaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color, width: 3)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.timer_rounded, color: color, size: 26),
          const SizedBox(width: 8),
          Text(
            '$secondsRemaining',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
