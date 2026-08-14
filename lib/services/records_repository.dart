import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/table_record.dart';

/// Guarda y lee los mejores tiempos (récords) de forma local en el
/// dispositivo, usando [SharedPreferences]. No se usa internet ni
/// backend: los datos sobreviven al cierre de la app y al reinicio
/// del teléfono porque SharedPreferences persiste en almacenamiento
/// nativo del dispositivo.
class RecordsRepository {
  static const String _storageKey = 'tablas_multiplicar.best_times.v1';

  /// Devuelve todos los récords guardados, ordenados de menor a mayor
  /// tiempo (el más rápido primero).
  Future<List<TableRecord>> getAllRecords() async {
    final Map<String, TableRecord> records = await _readAll();
    final List<TableRecord> list = records.values.toList()
      ..sort(
        (a, b) => a.bestTimeMilliseconds.compareTo(b.bestTimeMilliseconds),
      );
    return list;
  }

  /// Devuelve el récord actual para una combinación de tablas, o null
  /// si todavía no existe ninguno para esa combinación exacta.
  Future<TableRecord?> getRecordFor(String recordKey) async {
    final Map<String, TableRecord> records = await _readAll();
    return records[recordKey];
  }

  /// Devuelve solo los récords correspondientes a exámenes de
  /// [questionCount] preguntas (10 o 20), ordenados del más rápido al
  /// más lento. Los dos historiales (10 y 20 preguntas) son
  /// completamente independientes.
  Future<List<TableRecord>> getRecordsForQuestionCount(
    int questionCount,
  ) async {
    final List<TableRecord> all = await getAllRecords();
    return all
        .where((TableRecord record) => record.questionCount == questionCount)
        .toList();
  }

  /// Intenta guardar un nuevo tiempo para [recordKey].
  ///
  /// Solo actualiza el récord si no existía uno previo o si
  /// [candidateTimeMilliseconds] es menor (más rápido) que el
  /// existente. Devuelve true si se estableció o mejoró el récord.
  ///
  /// El llamador es responsable de verificar que el examen haya sido
  /// perfecto (todas las preguntas correctas) antes de invocar este
  /// método: este repositorio no conoce la calificación, solo guarda
  /// tiempos.
  Future<bool> tryUpdateRecord({
    required String recordKey,
    required List<int> tables,
    required int questionCount,
    required int candidateTimeMilliseconds,
  }) async {
    final Map<String, TableRecord> records = await _readAll();
    final TableRecord? existing = records[recordKey];

    final bool isNewRecord = existing == null ||
        candidateTimeMilliseconds < existing.bestTimeMilliseconds;

    if (!isNewRecord) {
      return false;
    }

    records[recordKey] = TableRecord(
      recordKey: recordKey,
      tables: tables,
      questionCount: questionCount,
      bestTimeMilliseconds: candidateTimeMilliseconds,
    );
    await _writeAll(records);
    return true;
  }

  /// Borra todos los récords guardados (reinicia el historial de
  /// mejores tiempos por completo). No se puede deshacer.
  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<Map<String, TableRecord>> _readAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <String, TableRecord>{};
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final Map<String, TableRecord> result = <String, TableRecord>{};
      for (final dynamic item in decoded) {
        final TableRecord record =
            TableRecord.fromJson(item as Map<String, dynamic>);
        result[record.recordKey] = record;
      }
      return result;
    } catch (_) {
      // Si los datos guardados están corruptos, se ignora en lugar de
      // romper la aplicación.
      return <String, TableRecord>{};
    }
  }

  Future<void> _writeAll(Map<String, TableRecord> records) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded =
        records.values.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(encoded));
  }
}
