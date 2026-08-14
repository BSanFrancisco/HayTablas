import 'dart:async';

import 'package:flutter/material.dart';

import '../models/table_record.dart';
import '../services/records_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

/// Pantalla de mejores tiempos: muestra todos los récords guardados,
/// uno por cada combinación exacta de tablas, ordenados del más
/// rápido al más lento.
class BestTimesScreen extends StatefulWidget {
  const BestTimesScreen({super.key});

  @override
  State<BestTimesScreen> createState() => _BestTimesScreenState();
}

class _BestTimesScreenState extends State<BestTimesScreen> {
  final RecordsRepository _repository = RecordsRepository();
  late Future<List<TableRecord>> _recordsFuture;
  int _selectedQuestionCount = 10;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _repository.getRecordsForQuestionCount(_selectedQuestionCount);
  }

  void _reloadRecords() {
    setState(() {
      _recordsFuture =
          _repository.getRecordsForQuestionCount(_selectedQuestionCount);
    });
  }

  void _onSelectQuestionCount(int count) {
    if (_selectedQuestionCount == count) {
      return;
    }
    setState(() {
      _selectedQuestionCount = count;
      _recordsFuture = _repository.getRecordsForQuestionCount(count);
    });
  }

  Future<void> _onResetPressed() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('¿Borrar todos los récords?'),
          content: const Text(
            'Se van a borrar todos los mejores tiempos guardados. '
            'Esta acción no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Borrar',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _repository.clearAll();
    if (!mounted) {
      return;
    }
    _reloadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 30),
                  color: AppColors.textDark,
                ),
              ],
            ),
            const Text(
              '🏆 MEJORES TIEMPOS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ModeToggleButton(
                    label: '10 – 60 Seg',
                    isSelected: _selectedQuestionCount == 10,
                    onTap: () => _onSelectQuestionCount(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeToggleButton(
                    label: '20 – 90 Seg',
                    isSelected: _selectedQuestionCount == 20,
                    onTap: () => _onSelectQuestionCount(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<TableRecord>>(
                future: _recordsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<TableRecord> records = snapshot.data ?? const [];

                  if (records.isEmpty) {
                    return const _EmptyRecordsMessage();
                  }

                  return ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _RecordTile(record: records[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _onResetPressed,
              icon: const Icon(Icons.delete_forever_rounded,
                  color: AppColors.errorRed),
              label: const Text(
                'Reset (borrar historial)',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
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
      color: isSelected ? AppColors.primaryBlue : AppColors.cardWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRecordsMessage extends StatelessWidget {
  const _EmptyRecordsMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('🏅', style: TextStyle(fontSize: 72)),
            SizedBox(height: 16),
            Text(
              'Todavía no hay récords.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '¡Completá un examen perfecto para conseguir el primero!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final TableRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
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
          const Text('🏆', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              record.displayLabel,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            '${record.bestTimeSeconds} s',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlueDark,
            ),
          ),
        ],
      ),
    );
  }
}
