import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Ancho máximo del "marco" de la app en pantallas grandes (navegador
/// de escritorio, en la versión web). Todas las pantallas están
/// diseñadas para caber sin scroll en el alto de un celular; algunos
/// elementos (como la grilla de tablas de la pantalla principal) se
/// agrandan para ocupar todo el ancho disponible. Sin este límite, en
/// una ventana de navegador ancha esos elementos se agrandarían mucho
/// más de lo pensado y dejarían de entrar en el alto de la ventana.
/// En un celular real este límite no tiene ningún efecto, porque el
/// ancho disponible ya es menor a este máximo.
const double _kMaxAppWidth = 480;

/// Widget raíz de la aplicación.
class TablasMultiplicarApp extends StatelessWidget {
  const TablasMultiplicarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tablas de Multiplicar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
      builder: (BuildContext context, Widget? child) {
        // Centra el contenido y lo angosta como un celular en pantallas
        // grandes (ver comentario de _kMaxAppWidth). El color de fondo
        // solo se ve en los costados, en ventanas anchas.
        return ColoredBox(
          color: AppColors.textDark,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxAppWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
