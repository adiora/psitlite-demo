import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:psitlite_demo/models/announcements.dart';
import 'package:psitlite_demo/models/marks.dart';
import 'package:psitlite_demo/models/olt_report.dart';
import 'package:psitlite_demo/models/olt_solution.dart';
import 'package:psitlite_demo/models/student_attendance.dart';
import 'package:psitlite_demo/models/student_data.dart';
import 'package:psitlite_demo/models/test_list.dart';
import 'package:psitlite_demo/services/mock_data.dart';
import 'package:psitlite_demo/services/cache_service.dart';
import '../utils/encryption.dart';
import '../state/student.dart';

class MockApiService {
  static final Random _rand = Random();

  static Future<T> _processRequest<T>({
    required Future<String> Function() dataSource,
    required T Function(dynamic json) parser,
    required Future<void> Function(String encrypted) cacheAction,
  }) async {
    try {
      final rawJson = await _simulateNetwork(await dataSource());

      Encryptor.encrypt(rawJson).then((encrypted) => cacheAction(encrypted));

      final decoded = jsonDecode(rawJson);
      final result = parser(decoded);

      return result;
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      throw _handleError(e);
    }
  }

  static Future<T> _simulateNetwork<T>(T value) async {
    await Future.delayed(Duration(milliseconds: _rand.nextInt(800) + 200));
    if (_rand.nextInt(20) == 0) throw 'Server Error'; // 5% fail chance
    return value;
  }

  static String _handleError(Object e) {
    final error = e.toString();
    if (error.contains('ClientException')) {
      return 'Check your internet connection';
    }
    if (error.contains('Server')) return 'Server is currently unreachable';
    return error.isNotEmpty ? error : 'Unexpected Error';
  }

  static Future<void> handleLogin(String userId, String pass) async {
    if (!MockData.authenticate(userId)) throw 'Invalid Credentials';

    await _processRequest<void>(
      dataSource: () => MockData.getStudentDetails(),
      parser: (json) {
        final data = StudentData.fromJson(json is List ? json[0] : json);
        Student.initializeWith(data: data);
      },
      cacheAction: (encrypted) => CacheService.cacheStudentDetails(encrypted),
    );
  }

  static Future<AttendanceSummary> getAttendanceSummary() async {
    return _processRequest(
      dataSource: () => MockData.getAttendanceSummary(),
      parser: (json) => AttendanceSummary.fromJson(json),
      cacheAction: (enc) => CacheService.cacheAttendanceSummary(enc),
    );
  }

  static Future<AttendanceDetails> getAttendanceDetails() async {
    return _processRequest(
      dataSource: () => MockData.getAttendanceDetails(),
      parser: (json) => AttendanceDetails.fromJson(json),
      cacheAction: (enc) => CacheService.cacheAttendanceDetails(enc),
    );
  }

  static Future<TestList> getTestList() async {
    return _processRequest(
      dataSource: () => MockData.getTestList(),
      parser: (json) => TestList.fromJson(json),
      cacheAction: (enc) => CacheService.cacheTestList(enc),
    );
  }

  static Future<Marks> getMarks({required String testID}) async {
    return _processRequest(
      dataSource: () => MockData.getMarks(testID),
      parser: (json) => Marks.fromJson(json),
      cacheAction: (enc) => CacheService.cacheMarks(enc, testID: testID),
    );
  }

  static Future<OltReport> getOltReport() async {
    return _processRequest(
      dataSource: () => MockData.getOltReport(),
      parser: (json) => OltReport.fromJson(json),
      cacheAction: (enc) => CacheService.cacheOltReport(enc),
    );
  }

  static Future<String> getTimetableJSON({required String date}) async {
    final json = await _simulateNetwork(await MockData.getTimetable());
    final encrypted = await Encryptor.encrypt(json);
    await CacheService.cacheTimetable(data: encrypted, date: date);
    return encrypted;
  }

  static Future<Announcements> getAnnouncements() async {
    return _processRequest(
      dataSource: () => MockData.getAnnouncements(),
      parser: (json) => Announcements.fromJson(json),
      cacheAction: (enc) => CacheService.cacheAnnouncements(enc),
    );
  }

  static Future<OltSolution> getOltSolution({required String testID}) async {
    return _processRequest(
      dataSource: () => MockData.getOltSolution(),
      parser: (json) => OltSolution.fromJson(json, testID: testID),
      cacheAction: (enc) => CacheService.cacheOltSolution(enc, testID: testID),
    );
  }

  static Future<dynamic> getProfileImage() async {
    return null;
  }

  static Future<void> updateStudentDetails() async {}
}
