import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

/// Muestra el detalle de las preguntas de un examen ya finalizado,
/// filtradas por correctas o incorrectas, para que el usuario pueda
/// revisar exactamente qué respondió.
class AnswerReviewScreen extends StatelessWidget {
  const AnswerReviewScreen({
    super.key,
    required this.title,
    required this.answers,
  });

  final String title;
  final List<AnsweredQuestion> answers;

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
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: answers.isEmpty
                  ? const _EmptyAnswersMessage()
                  : ListView.separated(
                      itemCount: answers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        return _AnswerTile(answered: answers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAnswersMessage extends StatelessWidget {
  const _EmptyAnswersMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No hay preguntas para mostrar acá.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.answered});

  final AnsweredQuestion answered;

  @override
  Widget build(BuildContext context) {
    final Question question = answered.question;
    final Color accent =
        answered.isCorrect ? AppColors.leafGreenDark : AppColors.errorRed;
    final String userAnswerText = answered.userAnswer == null
        ? 'Sin respuesta (se acabó el tiempo)'
        : 'Tu respuesta: ${answered.userAnswer}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent, width: 2),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            answered.isCorrect
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: accent,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${question.displayLeft} × ${question.displayRight} = '
                  '${question.correctAnswer}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userAnswerText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: accent,
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
