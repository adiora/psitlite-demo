import 'package:psit_lite_demo/models/student_data.dart' show StudentData;

class Student {
  static StudentData data = StudentData.fromJson({});

  static void initializeWith({required StudentData data}) {
    Student.data = data;
  }
}
