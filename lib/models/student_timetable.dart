import 'dart:collection';

class Period {
  final int periodNumber;
  final String room;
  final String empName;
  final String subjectCode;
  final String subjectName;
  final bool isLab;

  Period({
    required this.periodNumber,
    required this.room,
    required this.empName,
    required this.subjectCode,
    required this.subjectName,
    required this.isLab,
  });
}

class StudentTimetable {
  final List<List<Period?>> periods;
  final int periodCount;
  final int dayCount;
  final SplayTreeMap<String, String> subjectInfo;
  final List<int> batchList;

  StudentTimetable({
    required this.periods,
    required this.periodCount,
    required this.dayCount,
    required this.subjectInfo,
    required this.batchList,
  });

  factory StudentTimetable.fromJson({
    required List<dynamic> json,
    required List<int> batchList,
  }) {
    List<List<Period?>> periods = List.generate(
      7,
      (_) => List.generate(9, (index) {
        return null;
      }),
    );

    SplayTreeMap<String, String> subjectInfo = SplayTreeMap();

    int periodCount = 8;
    int dayCount = 5;

    for (var entry in json) {
      final batchId = int.parse(entry['Batch_Id']);
      if (batchList.isNotEmpty && !batchList.contains(batchId)) continue;

      final dayIndex = entry['TT_Day'] - 1;
      final periodIndex = entry['TT_Period'] - 1;
      final subjectCode = entry['Subject_Code'].toString();
      final subjectName = entry['Subject'].toString();

      periods[dayIndex][periodIndex] = Period(
        periodNumber: periodIndex,
        room: entry['Room'].toString(),
        empName: entry['EmpName'].toString(),
        subjectCode: subjectCode,
        subjectName: subjectName,
        isLab: entry['IsLab'] != 0,
      );

      if (periodIndex == 8) periodCount = 9;
      if (dayIndex >= dayCount) dayCount = dayIndex + 1;
      subjectInfo[subjectCode] = subjectName;
    }

    return StudentTimetable(
      periods: periods,
      periodCount: periodCount,
      dayCount: dayCount,
      subjectInfo: subjectInfo,
      batchList: batchList,
    );
  }

  static bool isAmbiguous({required List<dynamic> json}) {
    HashSet<int> scheduleSet = HashSet();
    for (var entry in json) {
      final day = entry['TT_Day'];
      final period = entry['TT_Period'];

      if (scheduleSet.contains(day * 10 + period)) return true;
      scheduleSet.add(day * 10 + period);
    }

    return false;
  }

  static List<int> getBatchList({required List<dynamic> json}) {
    List<int> batchList = [];
    for (var entry in json) {
      batchList.add(int.parse(entry['Batch_Id']));
    }

    return batchList;
  }

  static HashMap<int, HashSet<String>> periodByBatches({
    required List<dynamic> json,
  }) {
    final HashMap<int, HashSet<String>> batchMap = HashMap();

    for (var entry in json) {
      final batchId = int.parse(entry['Batch_Id']);

      final room = entry['Room'].toString();
      final empName = entry['EmpName'].toString();
      final subjectName = entry['Subject'].toString();

      final info = '$subjectName, $empName, $room';
      batchMap[batchId] ??= HashSet();
      batchMap[batchId]!.add(info);
    }

    return batchMap;
  }
}
