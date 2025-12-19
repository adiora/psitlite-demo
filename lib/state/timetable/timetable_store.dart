import 'package:flutter/material.dart';
import 'package:psit_lite_demo/models/student_timetable.dart';
import 'package:psit_lite_demo/services/fetch_service.dart';

class TimetableKey {
  final String date;
  final String batchHash;

  TimetableKey(this.date, List<int> batchList)
    : batchHash = (batchList..sort()).join(',');

  @override
  bool operator ==(Object other) =>
      other is TimetableKey &&
      date == other.date &&
      batchHash == other.batchHash;

  @override
  int get hashCode => Object.hash(date, batchHash);
}

class TimetableStore {
  static final Map<TimetableKey, StudentTimetable> _cache = {};

  static final ValueNotifier<StudentTimetable?> timetable = ValueNotifier(null);

  static Future<void> loadTimetable({
    required String date,
    required List<int> batchList,
  }) async {
    final result = await getTimetable(date: date, batchList: batchList);
    timetable.value = result;
  }

  static Future<StudentTimetable?> getTimetable({
    required String date,
    required List<int> batchList,
  }) async {
    final key = TimetableKey(date, batchList);
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final result = await FetchService.getTimetable(
      date: date,
      batchList: batchList,
    );

    _cache[key] = result;

    return result;
  }

  static void clear() {
    _cache.clear();
  }

  static List<List<Period?>> get periods =>
      timetable.value?.periods ?? const [];
}
