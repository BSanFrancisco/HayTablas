import 'dart:async';

import 'package:flutter/material.dart';

import '../services/stats_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

/// Muestra el listado completo de una tabla de multiplicar, del
/// "tabla × 1" al "tabla × 10", para que el niño la lea y la
/// memorice.
class LearnTableScreen extends StatefulWidget {
  const LearnTableScreen({super.key, required this.table});

  final int table;

  @override
  State<LearnTableScreen> createState() => _LearnTableScreenState();
}

class _LearnTableScreenState extends State<LearnTableScreen> {
  static const int _minMultiplier = 1;
  static const int _maxMultiplier = 10;

  @override
  void initState() {
    super.initState();
    unawaited(StatsRepository().recordTableLearned(widget.table));
  }

  @override
  Widget build(BuildContext context) {
    final int table = widget.table;
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
              'TABLA DEL $table',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _maxMultiplier - _minMultiplier + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (BuildContext context, int index) {
                  final int multiplier = _minMultiplier + index;
                  final int result = table * multiplier;
                  return _MultiplicationRow(
                    table: table,
                    multiplier: multiplier,
                    result: result,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiplicationRow extends StatelessWidget {
  const _MultiplicationRow({
    required this.table,
    required this.multiplier,
    required this.result,
  });

  final int table;
  final int multiplier;
  final int result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$table × $multiplier = $result',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlueDark,
            ),
          ),
        ],
      ),
    );
  }
}
