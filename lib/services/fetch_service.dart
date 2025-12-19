import 'dart:convert';
import 'dart:typed_data';

import 'package:psit_lite_demo/models/announcements.dart';
import 'package:psit_lite_demo/models/marks.dart';
import 'package:psit_lite_demo/models/olt_report.dart';
import 'package:psit_lite_demo/models/student_attendance.dart';
import 'package:psit_lite_demo/models/student_data.dart';
import 'package:psit_lite_demo/models/student_timetable.dart';
import 'package:psit_lite_demo/models/test_list.dart';
import 'package:psit_lite_demo/models/olt_solution.dart';
import 'package:psit_lite_demo/services/mock_api_service.dart';
import 'package:psit_lite_demo/services/cache_service.dart';
import 'package:psit_lite_demo/utils/encryption.dart';

class FetchService {
  static Future<StudentData?> getStudentDetails() async {
    return CacheService.getCachedStudentDetails();
  }

  static Future<List<int>?> getBatchList() async {
    return CacheService.getCachedBatchList();
  }

  static Future<AttendanceSummary> getAttendanceSummary() async {
    AttendanceSummary? summary =
        await CacheService.getCachedAttendanceSummary();

    summary ??= await MockApiService.getAttendanceSummary();
    return summary;
  }

  static Future<AttendanceDetails> getAttendanceDetails() async {
    AttendanceDetails? details =
        await CacheService.getCachedAttendanceDetails();

    details ??= await MockApiService.getAttendanceDetails();
    return details;
  }

  static Future<StudentTimetable> getTimetable({
    required String date,
    required List<int> batchList,
  }) async {
    final timetableJSON = await getTimetableJSON(date: date);

    return StudentTimetable.fromJson(
      json: jsonDecode(timetableJSON),
      batchList: batchList,
    );
  }

  static Future<String> getTimetableJSON({required String date}) async {
    String? json = await CacheService.getCachedTimetableJSON(date: date);

    json ??= await MockApiService.getTimetableJSON(date: date);
    return await Encryptor.decrypt(json.trim());
  }

  static Future<Uint8List?> getProfileImage() async {
    Uint8List? imageBytes = await CacheService.getCachedProfileImage();

    imageBytes ??= await MockApiService.getProfileImage();
    return imageBytes;
  }

  static Future<TestList> getTestList() async {
    TestList? testList = await CacheService.getCachedTestList();

    testList ??= await MockApiService.getTestList();
    return testList;
  }

  static Future<Marks> getMarks(String testID) async {
    Marks? marks = await CacheService.getCachedMarks(testID: testID);

    marks ??= await MockApiService.getMarks(testID: testID);
    return marks;
  }

  static Future<Announcements> getAnnouncements() async {
    Announcements? announcements = await CacheService.getCachedAnnouncements();

    announcements ??= await MockApiService.getAnnouncements();
    return announcements;
  }

  static Future<OltReport> getOltReport() async {
    OltReport? oltReport = await CacheService.getCachedOltReport();

    oltReport ??= await MockApiService.getOltReport();
    return oltReport;
  }

  static Future<OltSolution> getOltSolution(String testID) async {
    OltSolution? oltSolution = await CacheService.getCachedOltSolution(
      testID: testID,
    );

    oltSolution ??= await MockApiService.getOltSolution(testID: testID);
    return oltSolution;
  }
}
