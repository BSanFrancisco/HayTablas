import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exam_config.dart';
import '../services/stats_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

/// Modo "Inverso": preguntas ilimitadas, sin cronómetro ni límite,
/// igual que Practicar, pero con la incógnita en el medio en vez de al
/// final. Se muestra una de las tablas seleccionadas y el resultado
/// (ej. "2 × ? = 6"), y hay que completar el factor que falta (3 en
/// ese ejemplo), no el resultado.
class ReversePracticeScreen extends StatefulWidget {
  const ReversePracticeScreen({super.key, required this.config});

  final ExamConfig config;

  @override
  State<ReversePracticeScreen> createState() => _ReversePracticeScreenState();
}

enum _Feedback { none, correct, incorrect }

class _ReversePracticeScreenState extends State<ReversePracticeScreen> {
  static const int _minFactor = 1;
  static const int _maxFactor = 10;

  final Random _random = Random();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final StatsRepository _statsRepository = StatsRepository();
  final Stopwatch _sessionStopwatch = Stopwatch();

  late int _table;
  late int _missingFactor;
  _Feedback _feedback = _Feedback.none;
  bool _canSubmit = true;
  int? _lastCorrectAnswer;

  int get _product => _table * _missingFactor;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    _sessionStopwatch.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  void _generateQuestion() {
    final List<int> tables = widget.config.tables;
    _table = tables[_random.nextInt(tables.length)];
    _missingFactor = _minFactor + _random.nextInt(_maxFactor - _minFactor + 1);
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
    final bool isCorrect = parsed != null && parsed == _missingFactor;

    setState(() {
      _feedback = isCorrect ? _Feedback.correct : _Feedback.incorrect;
      _lastCorrectAnswer = _missingFactor;
      _canSubmit = false;
    });

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _generateQuestion();
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
          title: const Text('¿Querés terminar el modo inverso?'),
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
      // Vuelve a la pantalla principal (no hay nada que guardar en
      // este modo, igual que en Practicar).
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
                '🔄 MODO INVERSO',
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '$_table ×',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 90,
                            child: TextField(
                              controller: _answerController,
                              focusNode: _focusNode,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.center,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: AppColors.violetPurple,
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                hintText: '?',
                              ),
                              onSubmitted: _submitAnswer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '= $_product',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
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
