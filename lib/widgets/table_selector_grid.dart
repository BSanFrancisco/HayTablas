import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Grilla de casilleros, uno por cada tabla del 2 al 10, para que el
/// niño elija qué tablas quiere practicar.
class TableSelectorGrid extends StatelessWidget {
  const TableSelectorGrid({
    super.key,
    required this.availableTables,
    required this.selectedTables,
    required this.onToggle,
    this.compact = false,
    this.crossAxisCount,
    this.tileExtent,
    this.stretchToWidth = false,
  });

  final List<int> availableTables;
  final Set<int> selectedTables;
  final ValueChanged<int> onToggle;

  /// Si es true, muestra los casilleros en tamaño reducido (usado en
  /// la pantalla principal, donde conviven con otros botones). Siguen
  /// siendo perfectamente tocables para un niño.
  final bool compact;

  /// Cantidad de columnas de la grilla. Si no se especifica, usa 3
  /// (tamaño normal) o 5 (compacto) según [compact].
  final int? crossAxisCount;

  /// Si se especifica, cada casillero tiene este ancho/alto fijo (en
  /// dp) en vez de repartirse todo el ancho disponible. Sirve para
  /// mantener casilleros chicos aunque la grilla tenga pocas columnas.
  /// Se ignora si [stretchToWidth] es true.
  final double? tileExtent;

  /// Si es true, los casilleros se agrandan proporcionalmente hasta
  /// ocupar todo el ancho disponible (el mismo ancho que un botón que
  /// se estira, como CONTINUAR), en vez de mantener un tamaño chico
  /// fijo.
  final bool stretchToWidth;

  @override
  Widget build(BuildContext context) {
    final int columns = crossAxisCount ?? (compact ? 5 : 3);
    final double spacing = compact ? 8 : 14;

    if (stretchToWidth) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double extent =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return _buildGrid(columns: columns, spacing: spacing, tileExtent: extent);
        },
      );
    }

    if (tileExtent != null) {
      final double width = columns * tileExtent! + (columns - 1) * spacing;
      return Center(
        child: SizedBox(
          width: width,
          child: _buildGrid(
            columns: columns,
            spacing: spacing,
            tileExtent: tileExtent,
          ),
        ),
      );
    }

    return _buildGrid(columns: columns, spacing: spacing, tileExtent: null);
  }

  Widget _buildGrid({
    required int columns,
    required double spacing,
    required double? tileExtent,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableTables.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: tileExtent != null ? 1.0 : (compact ? 1.0 : 1.15),
      ),
      itemBuilder: (BuildContext context, int index) {
        final int table = availableTables[index];
        final bool isSelected = selectedTables.contains(table);

        return _TableTile(
          table: table,
          isSelected: isSelected,
          onTap: () => onToggle(table),
          compact: compact,
          tileExtent: tileExtent,
        );
      },
    );
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({
    required this.table,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
    this.tileExtent,
  });

  final int table;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  /// Si se especifica, todos los tamaños internos (fuente, borde,
  /// ícono de tilde) se escalan proporcionalmente a partir de este
  /// tamaño de casillero, en vez de usar los tamaños fijos de
  /// [compact].
  final double? tileExtent;

  // Tamaños de referencia para el modo compacto (casillero de 66dp),
  // usados como base para escalar proporcionalmente cuando se
  // especifica [tileExtent].
  static const double _referenceExtent = 66;
  static const double _referenceFontSize = 16;
  static const double _referenceRadius = 14;
  static const double _referenceBorderWidth = 2;
  static const double _referenceCheckIconSize = 12;

  @override
  Widget build(BuildContext context) {
    final Color background =
        isSelected ? AppColors.leafGreen : AppColors.cardWhite;
    final Color foreground = isSelected ? Colors.white : AppColors.textDark;

    late final double radius;
    late final double fontSize;
    late final double borderWidth;
    late final double checkIconSize;

    if (tileExtent != null) {
      final double scale = tileExtent! / _referenceExtent;
      radius = _referenceRadius * scale;
      fontSize = _referenceFontSize * scale;
      borderWidth = (_referenceBorderWidth * scale).clamp(2.0, 6.0);
      checkIconSize = _referenceCheckIconSize * scale;
    } else if (compact) {
      radius = _referenceRadius;
      fontSize = _referenceFontSize;
      borderWidth = _referenceBorderWidth;
      checkIconSize = _referenceCheckIconSize;
    } else {
      radius = 20;
      fontSize = 34;
      borderWidth = 3;
      checkIconSize = 20;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isSelected ? AppColors.leafGreenDark : Colors.transparent,
              width: borderWidth,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$table',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(top: compact ? 2 : 4),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: checkIconSize,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
