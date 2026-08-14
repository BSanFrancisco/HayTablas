# Tablas de Multiplicar 🧮

Aplicación educativa en **Flutter** para que niños de edad escolar practiquen
y sean evaluados en las tablas de multiplicar. Funciona 100% offline y
guarda los mejores tiempos localmente en el dispositivo (sin backend, sin
cuentas de usuario).

## ⚠️ Nota importante sobre esta entrega

Este proyecto fue escrito en un entorno en la nube sin salida a internet
hacia los servidores de Flutter/Google, así que **no se pudo ejecutar
`flutter pub get` / `flutter analyze` / `flutter build apk` durante el
desarrollo**. Todo el código fue escrito y revisado a mano con mucho
cuidado (sintaxis, tipos, imports, íconos usados), pero la verificación
final de compilación la tenés que hacer vos en tu máquina, donde sí hay
internet. Más abajo te dejo los pasos exactos.

Si al correr `flutter pub get` o `flutter run` te aparece algún error de
versión de Gradle/AGP/Kotlin (poco probable, pero puede pasar si tu Flutter
instalado es mucho más nuevo o más viejo que el que se usó como referencia),
la solución más simple es:

```bash
rm -rf android
flutter create --platforms=android --org com.sebalima .
```

Esto regenera la carpeta `android/` perfectamente adaptada a tu versión de
Flutter instalada, sin tocar nada del código Dart en `lib/` (que es donde
está toda la app en realidad).

## Cómo correr el proyecto

```bash
flutter pub get
flutter analyze
flutter run
```

Para generar el instalable (APK):

```bash
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.

## Arquitectura

```
lib/
  main.dart                    Punto de entrada
  app.dart                     MaterialApp + tema global
  models/                      Clases de datos inmutables
    exam_config.dart           Configuración de tablas del examen
    question.dart              Pregunta y respuesta
    exam_result.dart           Resultado final de un examen
    table_record.dart          Récord guardado para una combinación de tablas
  services/                    Lógica de negocio, sin UI
    question_generator.dart    Genera las 10 preguntas aleatorias sin repetir
    exam_timer.dart            Cronómetro preciso basado en Stopwatch
    records_repository.dart    Persistencia local de récords (SharedPreferences)
  screens/                     Una pantalla por archivo
    home_screen.dart           Selección de tablas + tabla máxima
    preparation_screen.dart    Resumen antes de iniciar
    countdown_screen.dart      Cuenta regresiva 3-2-1
    exam_screen.dart           El examen en sí (preguntas + cronómetro)
    results_screen.dart        Calificación, emoji y estado del récord
    best_times_screen.dart     Lista de mejores tiempos
  widgets/                     Componentes reutilizables (botones, fondo, grilla)
  theme/                       Colores y estilos globales para niños
```

## Cómo se implementaron los puntos clave del pedido

- **Tabla máxima como límite superior**: en la pantalla principal, cualquier
  tabla mayor a la "Tabla máxima" elegida aparece deshabilitada (gris) y no
  puede seleccionarse; si el usuario baja la tabla máxima después de haber
  elegido tablas más altas, esas tablas se desmarcan automáticamente. Así
  nunca puede quedar seleccionada una tabla por encima del límite.
- **Generación de preguntas**: se arma un pool con todas las combinaciones
  únicas (tabla × 1..10) de las tablas permitidas, se baraja y se toman 10.
  Cada multiplicación (sin importar el orden de los factores) aparece como
  máximo una vez por examen. El orden de los dos factores en pantalla se
  sortea al azar por variedad visual (podés ver "8 × 3" o "3 × 8").
- **Cronómetro**: usa `Stopwatch` (tiempo real transcurrido), no un contador
  que resta 1 por segundo, para evitar desincronización. Se detiene
  inmediatamente al responder la pregunta 10, o corta el examen exactamente
  a los 60 segundos.
- **Teclado numérico y ENTER**: el campo de respuesta se enfoca
  automáticamente al empezar el examen, solo acepta dígitos, y al presionar
  ENTER (`onSubmitted`) se valida la respuesta, se contabiliza y se pasa a
  la siguiente pregunta sin necesidad de tocar la pantalla.
- **Récords**: se identifican por clave única `"2-3-4-5"` (tablas ordenadas
  y unidas con guiones). Solo un examen 10/10 puede crear o mejorar un
  récord, y se guarda el menor tiempo con `SharedPreferences` (persiste
  aunque se cierre la app o se reinicie el teléfono).
- **Emoji según calificación**: 0-4 → 😭, 5-6 → 😟, 7-9 → 😊, 10 → 🤩👑.

## Checklist de verificación (para hacer en tu máquina)

1. `flutter pub get` sin errores.
2. `flutter analyze` sin errores (pueden aparecer sugerencias de estilo,
   pero no errores).
3. Navegación: Principal → Preparación → Cuenta regresiva → Examen →
   Resultados → (Reiniciar vuelve a la cuenta regresiva / Ver mejores
   tiempos abre esa pantalla).
4. El cronómetro de 60s baja de a 1 en 1 y el examen corta justo al llegar
   a 0.
5. La cuenta regresiva muestra 3, 2, 1 (~1s cada uno) antes de la primera
   pregunta.
6. Al entrar al examen el teclado numérico se abre solo.
7. ENTER confirma la respuesta y avanza a la siguiente pregunta.
8. Con "Tabla máxima" en 4, seleccionando 2,3,4,5,6, solo deberían
   aparecer preguntas de las tablas 2, 3 y 4 (5 y 6 quedan deshabilitadas).
9. La calificación final coincide con las respuestas correctas (X/10).
10. El emoji cambia según el puntaje (probar 3, 6, 8 y 10 correctas).
11. Un examen 10/10 guarda un récord nuevo en "Mejores tiempos".
12. Cerrar la app completamente y volver a abrirla: el récord sigue ahí.
13. Un examen de 9/10 o menos no crea ni modifica ningún récord.
14. Practicar con dos combinaciones de tablas distintas (ej. "2-3" y
    "2-3-4") y confirmar que cada una guarda su propio récord por separado.
