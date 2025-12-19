import 'dart:convert';

import 'package:flutter/services.dart';

class MockData {
  static List<String> availableID = [];

  static int loggedUser = 0;

  static Future<void> initialize() async {
    final auth = jsonDecode(
      await rootBundle.loadString('assets/mock/auth.json'),
    );

    final userData = auth['user'];

    availableID.add( userData['SId'].toString());
  }

  static bool authenticate(String user) {
    return availableID.contains(user);
  }

  static Future<String> getStudentDetails() async {
    return await rootBundle.loadString('assets/mock/details.json', cache: true);
  }

  static Future<String> getAttendanceSummary() async {
    return await rootBundle.loadString(
      'assets/mock/attendance_summary.json',
      cache: true,
    );
  }

  static Future<String> getAttendanceDetails() async {
    return await rootBundle.loadString(
      'assets/mock/attendance_details.json',
      cache: true,
    );
  }

  static Future<String> getTestList() async {
    return await rootBundle.loadString(
      'assets/mock/test_list.json',
      cache: true,
    );
  }

  static Future<String> getMarks(String testID) async {
    return await rootBundle.loadString(
      'assets/mock/marks/$testID.json',
      cache: true,
    );
  }

  static Future<String> getTimetable() async {
    return await rootBundle.loadString(
      'assets/mock/timetable.json',
      cache: true,
    );
  }

  static Future<String> getAnnouncements() async {
    return await rootBundle.loadString(
      'assets/mock/announcements.json',
      cache: true,
    );
  }

  static Future<String> getOltReport() async {
    return await rootBundle.loadString(
      'assets/mock/olt_report.json',
      cache: true,
    );
  }

  static Future<String> getOltSolution() async {
    return await rootBundle.loadString(
      'assets/mock/olt_solution.json',
      cache: true,
    );
  }

  static Future<String> getLikeStates() async {
    return await rootBundle.loadString(
      'assets/mock/like_stats.json',
      cache: true,
    );
  }
}
