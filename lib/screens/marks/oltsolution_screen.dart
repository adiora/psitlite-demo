import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:psitlite_demo/models/olt_report.dart';
import 'package:psitlite_demo/models/olt_solution.dart';
import 'package:psitlite_demo/services/fetch_service.dart';
import 'package:psitlite_demo/widgets/error_box.dart';

class OltSolutionScreen extends StatefulWidget {
  final OltDetail olt;
  const OltSolutionScreen({super.key, required this.olt});

  @override
  State<OltSolutionScreen> createState() => _OltSolutionScreenState();
}

enum Sorted { serial, incorrect, correct }

class _OltSolutionScreenState extends State<OltSolutionScreen> {
  bool isLoading = true;
  String? error;
  List<OltQuestion> oltList = [];
  Sorted order = Sorted.incorrect;

  @override
  void initState() {
    super.initState();
    _fetchOltSolution();
  }

  Future<void> _fetchOltSolution() async {
    setState(() => isLoading = true);
    try {
      final report = await FetchService.getOltSolution(
        widget.olt.testId.toString(),
      );
      oltList = report.questions;
      sortOltList();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    if (mounted) setState(() => isLoading = false);
  }

  void sortOltList() {
    if (order == Sorted.serial) {
      oltList.sort((a, b) => a.number - b.number);
    } else if (order == Sorted.incorrect) {
      oltList.sort(
        (a, b) =>
            (!a.isCorrect && b.isCorrect ||
                (a.isCorrect == b.isCorrect && a.number < b.number))
            ? -1
            : 1,
      );
    } else {
      oltList.sort(
        (a, b) =>
            (a.isCorrect && !b.isCorrect ||
                (a.isCorrect == b.isCorrect && a.number < b.number))
            ? -1
            : 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.all(8),
        title: const Text('OLT Solution'),
        actions: [
          PopupMenuButton<Sorted>(
            icon: const Icon(Icons.sort),
            onSelected: (value) async {
              if (value == order) return;
              order = value;
              sortOltList();
              setState(() {});
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Sorted.incorrect,
                child: Text("Sort by Incorrect"),
              ),
              const PopupMenuItem(
                value: Sorted.correct,
                child: Text("Sort by Correct"),
              ),
              const PopupMenuItem(
                value: Sorted.serial,
                child: Text("Sort by Serial"),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? ErrorBox(
              errorMessage: error!,
              actionText: 'Retry',
              onPressed: () => _fetchOltSolution(),
            )
          : oltList.isEmpty
          ? const Center(child: Text('No questions available'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: oltList.length,
              itemBuilder: (_, index) {
                final question = oltList[index];
                return _OltSolutionCard(index: index, question: question);
              },
            ),
    );
  }
}

class _OltSolutionCard extends StatelessWidget {
  final int index;
  final OltQuestion question;

  const _OltSolutionCard({required this.index, required this.question});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = question.isCorrect;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: isCorrect ? Colors.green : Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Q${question.number}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCorrect ? 'Correct' : 'Incorrect',
                    style: TextStyle(
                      color: isCorrect ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Html(
              data: question.question,
              style: {
                "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              },
            ),

            const SizedBox(height: 12),

            Text.rich(
              TextSpan(
                text: 'You marked: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: question.markedAnser,
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Text.rich(
              TextSpan(
                text: 'Correct Answer: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: question.correctAnswer,
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
