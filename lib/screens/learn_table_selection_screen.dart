import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/table_selector_grid.dart';
import 'learn_table_screen.dart';

/// Pantalla de selección de tabla para el modo "Aprender": el niño
/// elige UNA sola tabla y pasa directo al listado de esa tabla (no
/// hace falta un botón "continuar", ya que es una elección única).
class LearnTableSelectionScreen extends StatelessWidget {
  const LearnTableSelectionScreen({super.key});

  static const List<int> _availableTables = <int>[2, 3, 4, 5, 6, 7, 8, 9, 10];

  void _onTableTapped(BuildContext context, int table) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LearnTableScreen(table: table),
      ),
    );
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
            const SizedBox(height: 8),
            const Text(
              '¿QUÉ TABLA\nQUERÉS APRENDER?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.1,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                child: TableSelectorGrid(
                  availableTables: _availableTables,
                  // Ninguna tabla queda "marcada": tocar una tabla
                  // navega directo al listado, no es una selección
                  // persistente.
                  selectedTables: const <int>{},
                  onToggle: (int table) => _onTableTapped(context, table),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
