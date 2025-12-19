class OltQuestion {
  final int number;
  final String question;
  final String markedAnser;
  final String correctAnswer;
  final bool isCorrect;

  const OltQuestion({
    required this.number,
    required this.question,
    required this.markedAnser,
    required this.correctAnswer,
    required this.isCorrect,
  });
}

class OltSolution {
  final String testID;
  final List<OltQuestion> questions;

  const OltSolution({required this.testID, required this.questions});

  factory OltSolution.fromJson(List<dynamic> json, {required String testID}) {
    List<OltQuestion> questions = [];

    int i = 0;

    for (var entry in json[0]) {
      questions.add(
        OltQuestion(
          number: ++i,
          question: entry['Question'],
          markedAnser: entry['Answer_Text'],
          correctAnswer: entry['Correct_Answer'],
          isCorrect: entry['IsCorrect'] == 1 ? true : false,
        ),
      );
    }

    for (var entry in json[1]) {
      questions.add(
        OltQuestion(
          number: ++i,
          question: entry['PassageQuestionText'],
          markedAnser: entry['PassageAnswer_Text'],
          correctAnswer: entry['Correct_Answer'],
          isCorrect: entry['IsCorrect'] == 1 ? true : false,
        ),
      );
    }

    return OltSolution(testID: testID, questions: questions);
  }
}
