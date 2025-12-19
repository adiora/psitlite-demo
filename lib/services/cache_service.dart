import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:psit_lite_demo/models/announcements.dart';
import 'package:psit_lite_demo/models/marks.dart';
import 'package:psit_lite_demo/models/olt_report.dart';
import 'package:psit_lite_demo/models/student_attendance.dart';
import 'package:psit_lite_demo/models/student_data.dart';
import 'package:psit_lite_demo/models/test_list.dart';
import 'package:psit_lite_demo/models/olt_solution.dart';
import 'package:psit_lite_demo/services/mock_api_service.dart';
import 'package:psit_lite_demo/utils/encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // In milliseconds

  // 1 hour for announcements
  static const _fastDuration = 1 * 60 * 60 * 1000;

  // 2 hours for attendance
  static const _frequentDuration = 2 * 60 * 60 * 1000;

  // 4 hours for timetable, marks, olt marks
  static const _nomralDuration = 4 * 60 * 60 * 1000;

  // 3 days for student details and profile image
  static const _seldomDuration = 3 * 24 * 60 * 60 * 1000;

  // 2 days for old cache
  static const _oldCacheDuration = _seldomDuration;

  static const _foreverDuration = 180 * 24 * 60 * 60 * 1000;

  static const _detailsKey = 'details';
  static const _attendanceSummaryKey = 'attSummary';
  static const _attendanceDetailsKey = 'attDetails';
  static const _timetableKey = 'timetable';
  static const _pImageKey = 'pimage';
  static const _testListKey = 'testlist';
  static const _marksKey = 'marks';
  static const _announcementKey = 'announce';
  static const _oltReportKey = 'oltreport';
  static const _oltSolutionKey = 'oltsolution';
  static const _batchSetKey = 'batchSet';

  static int get currentEpoch => DateTime.now().millisecondsSinceEpoch;

  static Future<void> clearOldCache() async {
    final prefs = await SharedPreferences.getInstance();

    final clearTimestamp = prefs.getInt('clearCache_TS');
    if (clearTimestamp != null &&
        currentEpoch - clearTimestamp <
            const Duration(days: 1).inMilliseconds) {
      return;
    }

    for (var key in prefs.getKeys()) {
      if (key.startsWith(_timetableKey) ||
          key.startsWith(_oltSolutionKey) ||
          key.startsWith(_marksKey)) {
        final timestamp = prefs.getInt('${key}_TS');
        if (timestamp != null && currentEpoch - timestamp > _oldCacheDuration) {
          await prefs.remove(key);
          await prefs.remove('${key}_TS');
        }
      }
    }

    await prefs.setInt('clearCache_TS', currentEpoch);
  }

  static Future<void> saveKey(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('${key}_TS', currentEpoch);
    prefs.setString(key, value);
  }

  static Future<String?> loadKey(String key, int durationMillis) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final timestampMillis = prefs.getInt('${key}_TS');
    if (timestampMillis == null) {
      return null;
    }

    if (currentEpoch < timestampMillis + durationMillis) {
      return prefs.getString(key);
    }

    return null;
  }

  static Future<void> cacheStudentDetails(String data) async {
    await saveKey(_detailsKey, data);
  }

  static Future<void> cacheStudentBatches(List<int> batchList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('${_batchSetKey}_TS', currentEpoch);
    prefs.setString(_batchSetKey, batchList.join(','));
  }

  static Future<void> cacheAttendanceSummary(String data) async {
    await saveKey(_attendanceSummaryKey, data);
  }

  static Future<void> cacheAttendanceDetails(String data) async {
    await saveKey(_attendanceDetailsKey, data);
  }

  static Future<void> cacheTimetable({
    required String data,
    required String date,
  }) async {
    await saveKey('$_timetableKey$date', data);
  }

  static Future<void> cacheProfileImage({required Uint8List imageBytes}) async {
    final dir = await getApplicationCacheDirectory();
    final file = File('${dir.path}/profile.jpg');

    await file.writeAsBytes(imageBytes, flush: true);

    saveKey(_pImageKey, '');
  }

  static Future<void> cacheTestList(String data) async {
    await saveKey(_testListKey, data);
  }

  static Future<void> cacheMarks(String data, {required String testID}) async {
    await saveKey('$_marksKey$testID', data);
  }

  static Future<void> cacheAnnouncements(String data) async {
    await saveKey(_announcementKey, data);
  }

  static Future<void> cacheOltReport(String data) async {
    await saveKey(_oltReportKey, data);
  }

  static Future<void> cacheOltSolution(
    String data, {
    required String testID,
  }) async {
    await saveKey('$_oltSolutionKey$testID', data);
  }

  // custom method, should be refactored
  // return student details even if data is stale for faster app restart
  // update details asynchronously if stale
  static Future<StudentData?> getCachedStudentDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedStudentData = prefs.getString(_detailsKey);

    if (cachedStudentData == null) return null;

    final studentData = StudentData.fromJson(
      jsonDecode(await Encryptor.decrypt(cachedStudentData.trim()))[0],
    );

    Future(() async {
      final timestampMillis = prefs.getInt('${_detailsKey}_TS');
      if (timestampMillis != null &&
          currentEpoch > timestampMillis + _seldomDuration) {
        await MockApiService.updateStudentDetails();
      }
    });

    return studentData;
  }

  static Future<List<int>?> getCachedBatchList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final timestampMillis = prefs.getInt('${_batchSetKey}_TS');
    if (timestampMillis == null) {
      return null;
    }

    if (currentEpoch < timestampMillis + _foreverDuration) {
      final batches = prefs.getString(_batchSetKey);

      if (batches != null && batches.isNotEmpty) {
        return batches.split(',').map(int.parse).toList();
      }
    }

    return null;
  }

  static Future<AttendanceSummary?> getCachedAttendanceSummary() async {
    final cachedSummary = await loadKey(
      _attendanceSummaryKey,
      _frequentDuration,
    );

    return cachedSummary == null
        ? null
        : AttendanceSummary.fromJson(
            jsonDecode(await Encryptor.decrypt(cachedSummary.trim())),
          );
  }

  static Future<AttendanceDetails?> getCachedAttendanceDetails() async {
    final cachedDetails = await loadKey(
      _attendanceDetailsKey,
      _frequentDuration,
    );

    return cachedDetails == null
        ? null
        : AttendanceDetails.fromJson(
            jsonDecode(await Encryptor.decrypt(cachedDetails.trim())),
          );
  }

  static Future<String?> getCachedTimetableJSON({required String date}) async {
    final timetableJSON = await loadKey('$_timetableKey$date', _nomralDuration);

    return timetableJSON;
  }

  static Future<Uint8List?> getCachedProfileImage() async {
    if (await loadKey(_pImageKey, _seldomDuration) != null) {
      final dir = await getApplicationCacheDirectory();
      final file = File('${dir.path}/profile.jpg');

      if (await file.exists()) {
        return await file.readAsBytes();
      }
    }

    return null;
  }

  static Future<TestList?> getCachedTestList() async {
    final cachedTestList = await loadKey(_testListKey, _seldomDuration);

    return cachedTestList == null
        ? null
        : TestList.fromJson(
            jsonDecode(await Encryptor.decrypt(cachedTestList.trim())),
          );
  }

  static Future<Marks?> getCachedMarks({required String testID}) async {
    final cachedMarks = await loadKey('$_marksKey$testID', _nomralDuration);

    return cachedMarks == null
        ? null
        : Marks.fromJson(
            jsonDecode(await Encryptor.decrypt(cachedMarks.trim())),
          );
  }

  static Future<Announcements?> getCachedAnnouncements() async {
    final cachedAnnouncements = await loadKey(_announcementKey, _fastDuration);

    return cachedAnnouncements == null
        ? null
        : Announcements.fromJson(
            jsonDecode(await Encryptor.decrypt(cachedAnnouncements.trim())),
          );
  }

  static Future<OltReport?> getCachedOltReport() async {
    final cachedOltReport = await loadKey(_oltReportKey, _nomralDuration);

    return cachedOltReport == null
        ? null
        : OltReport.fromJson(
            jsonDecode(await Encryptor.decrypt(cachedOltReport.trim())),
          );
  }

  static Future<OltSolution?> getCachedOltSolution({
    required String testID,
  }) async {
    final cachedOltSolution = await loadKey(
      '$_oltSolutionKey$testID',
      _seldomDuration,
    );

    return cachedOltSolution == null
        ? null
        : OltSolution.fromJson(
            testID: testID,
            jsonDecode(await Encryptor.decrypt(cachedOltSolution.trim())),
          );
  }

  static Future<void> clearProfileImage() async {
    final dir = await getApplicationCacheDirectory();
    final file = File('${dir.path}/profile.jpg');

    if (await file.exists()) {
      await file.delete();
    }
  }
}
