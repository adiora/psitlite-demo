import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MockData {
  static final List<String> _availableIDs = [];

  static Future<void> initialize() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/mock/auth.json',
      );
      final data = jsonDecode(response);
      final sId = data['user']?['SId'];
      if (sId != null) {
        _availableIDs.add(sId.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize MockData: $e');
      }
    }
  }

  static bool authenticate(String userId) => _availableIDs.contains(userId);

  static Future<String> _load(String path) {
    return rootBundle.loadString('assets/mock/$path', cache: true);
  }

  static Future<String> getStudentDetails() => _load('details.json');
  static Future<String> getAttendanceSummary() => _load('att_summary.json');
  static Future<String> getAttendanceDetails() => _load('att_details.json');
  static Future<String> getTestList() => _load('test_list.json');
  static Future<String> getTimetable() => _load('timetable.json');
  static Future<String> getAnnouncements() => _load('announcements.json');
  static Future<String> getOltReport() => _load('olt_report.json');
  static Future<String> getOltSolution() => _load('olt_solution.json');

  static Future<String> getMarks(String testID) => _load('marks/$testID.json');

  static Future<String> getLikeStats() => _load('like_stats.json');
}
