import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:psit_lite_demo/services/mock_data.dart';
import 'package:psit_lite_demo/models/announcements.dart';
import 'package:psit_lite_demo/models/marks.dart';
import 'package:psit_lite_demo/models/olt_report.dart';
import 'package:psit_lite_demo/models/olt_solution.dart';
import 'package:psit_lite_demo/state/student.dart';
import 'package:psit_lite_demo/models/test_list.dart';
import 'package:psit_lite_demo/services/cache_service.dart';
import '../utils/encryption.dart';
import '../models/student_data.dart';
import '../models/student_attendance.dart';

class MockApiService {
  static String _networkOrUnexpectedError(Object e) {
    String error = e.toString();
    throw error.contains('ClientException')
        ? 'Check your internet connection'
        : error.contains('Server')
        ? error
        : 'Unexpected Error';
  }

  static Random rand = Random();

  static Future<T> _simulateNetwork<T>(T value) async {
    int ms = rand.nextInt(800) + 200;
    await Future.delayed(Duration(milliseconds: ms));

    int fail = rand.nextInt(15);

    if (fail == 0) throw 'Server Error';

    return value;
  }

  static Future<void> authenticate(String userId, String pass) async {
    if (!MockData.authenticate(userId)) {
      throw await _simulateNetwork('Invalid Credentials');
    }
  }

  static Future<void> handleLogin(String userId, String pass) async {
    await authenticate(userId, pass);
    try {
      final authBody = await _simulateNetwork(
        await MockData.getStudentDetails(),
      );

      Student.initializeWith(
        data: StudentData.fromJson(jsonDecode(authBody)[0]),
      );

      final encrypted = await Encryptor.encrypt(authBody);
      await CacheService.cacheStudentDetails(encrypted);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<void> updateStudentDetails() async {
    try {
      final authBody = await _simulateNetwork(
        await MockData.getStudentDetails(),
      );

      Student.initializeWith(data: StudentData.fromJson(jsonDecode(authBody)));

      final encrypted = await Encryptor.encrypt(authBody);
      await CacheService.cacheStudentDetails(encrypted);

      return _simulateNetwork(null);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<AttendanceSummary> getAttendanceSummary() async {
    try {
      final json = await _simulateNetwork(
        await MockData.getAttendanceSummary(),
      );
      final summary = AttendanceSummary.fromJson(jsonDecode(json));
      final encrypted = await Encryptor.encrypt(json);
      await CacheService.cacheAttendanceSummary(encrypted);
      return _simulateNetwork(summary);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<AttendanceDetails> getAttendanceDetails() async {
    try {
      final json = await _simulateNetwork(
        await MockData.getAttendanceDetails(),
      );
      final details = AttendanceDetails.fromJson(jsonDecode(json));
      final encrypted = await Encryptor.encrypt(json);
      await CacheService.cacheAttendanceDetails(encrypted);
      return _simulateNetwork(details);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<String> getTimetableJSON({required String date}) async {
    try {
      final json = await _simulateNetwork(await MockData.getTimetable());
      final encrypted = await Encryptor.encrypt(json);
      await CacheService.cacheTimetable(data: encrypted, date: date);
      return await _simulateNetwork(json);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<Uint8List> getProfileImage() async {
    try {
      throw 'default image';
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<TestList> getTestList() async {
    try {
      final json = await _simulateNetwork(await MockData.getTestList());
      final testList = TestList.fromJson(jsonDecode(json));
      final encrypted = await Encryptor.encrypt(json);
      await CacheService.cacheTestList(encrypted);
      return _simulateNetwork(testList);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<Marks> getMarks({required String testID}) async {
    try {
      final json = await _simulateNetwork(await MockData.getMarks(testID));
      final marks = Marks.fromJson(jsonDecode(json));
      final encrypted = await Encryptor.encrypt(json);
      await CacheService.cacheMarks(encrypted, testID: testID);
      return _simulateNetwork(marks);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<Announcements> getAnnouncements() async {
    try {
      final json = await _simulateNetwork(await MockData.getAnnouncements());
      final announcements = Announcements.fromJson(jsonDecode(json));
      final encrypted = await Encryptor.encrypt(json);
      await CacheService.cacheAnnouncements(encrypted);
      return _simulateNetwork(announcements);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<OltReport> getOltReport() async {
    try {
      final json = await _simulateNetwork(await MockData.getOltReport());
      final report = OltReport.fromJson(jsonDecode(json));
      final encrypted = await Encryptor.encrypt(json);
      await CacheService.cacheOltReport(encrypted);
      return _simulateNetwork(report);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }

  static Future<OltSolution> getOltSolution({required String testID}) async {
    try {
      final json = await _simulateNetwork(await MockData.getOltSolution());
      final solution = OltSolution.fromJson(jsonDecode(json), testID: testID);
      final encrypted = await Encryptor.encrypt(json);
      await CacheService.cacheOltSolution(encrypted, testID: testID);
      return _simulateNetwork(solution);
    } catch (e) {
      throw _networkOrUnexpectedError(e);
    }
  }
}
