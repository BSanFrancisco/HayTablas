import 'dart:async';

import 'package:flutter/material.dart';

import '../models/exam_config.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import 'exam_screen.dart';

/// Cuenta regresiva 3-2-1 antes de comenzar el examen. El cronómetro
/// de 60 segundos todavía NO corre durante esta pantalla.
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key, required this.config, this.nextScreenBuilder});

  final ExamConfig config;

  /// Constructor de la pantalla a la que se navega al terminar la
  /// cuenta regresiva. Si no se especifica, se navega al examen
  /// normal ([ExamScreen]) con la misma configuración. Permite
  /// reutilizar esta misma pantalla de cuenta regresiva desde otros
  /// modos, como "Practicar".
  final WidgetBuilder? nextScreenBuilder;

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with SingleTickerProviderStateMixin {
  static const int _startValue = 3;
  static const Duration _tickDuration = Duration(seconds: 1);

  int _count = _startValue;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _tickDuration,
    );
    _runCountdown();
  }

  Future<void> _runCountdown() async {
    while (_count >= 1) {
      _pulseController
        ..reset()
        ..forward();
      await Future<void>.delayed(_tickDuration);
      if (!mounted) {
        return;
      }
      setState(() {
        _count -= 1;
      });
    }
    if (!mounted) {
      return;
    }
    final WidgetBuilder builder =
        widget.nextScreenBuilder ?? (_) => ExamScreen(config: widget.config);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: builder),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int displayValue = _count < 1 ? 1 : _count;
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.25).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
            ),
            child: Text(
              '$displayValue',
              style: const TextStyle(
                fontSize: 160,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
