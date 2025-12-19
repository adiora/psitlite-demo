import 'package:flutter/material.dart';
import 'package:psit_lite_demo/models/marks.dart';
import 'package:psit_lite_demo/models/test_list.dart';
import 'package:psit_lite_demo/state/timetable/timetable_store.dart';
import 'package:psit_lite_demo/services/mock_api_service.dart';
import 'package:psit_lite_demo/services/fetch_service.dart';
import 'package:psit_lite_demo/widgets/error_box.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({super.key});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  bool isLoadingTestList = true;
  bool isLoadingMarks = false;
  String? errorTestList;
  String? errorMarks;
  TestList? testList;
  Marks? marks;
  Test? selectedTest;

  @override
  void initState() {
    super.initState();
    _fetchTestList();
  }

  Future<void> _fetchTestList() async {
    setState(() {
      errorTestList = null;
      isLoadingTestList = true;
    });

    try {
      testList = await FetchService.getTestList();
    } catch (e) {
      errorTestList = e.toString();
    }

    if (mounted) {
      setState(() {
        isLoadingTestList = false;
      });
    }
  }

  Future<void> _fetchMarks(String testID, {bool refresh = false}) async {
    setState(() {
      errorMarks = null;
      isLoadingMarks = true;
    });

    try {
      marks = await (refresh
          ? MockApiService.getMarks(testID: testID)
          : FetchService.getMarks(testID));
    } catch (e) {
      errorMarks = e.toString();
    }

    if (mounted) {
      setState(() {
        isLoadingMarks = false;
      });
    }
  }

  Future<void> _refreshMarks() {
    return _fetchMarks(selectedTest!.id, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'marks_title',
          child: Material(
            color: Colors.transparent,
            child: Text('Marks', style: theme.textTheme.titleLarge),
          ),
        ),
      ),
      body: isLoadingTestList
          ? const Center(child: CircularProgressIndicator())
          : errorTestList != null
          ? Center(
              child: ErrorBox(
                errorMessage: 'Couldn\'t fetch test list\n$errorTestList!',
                actionText: 'Retry',
                onPressed: () => _fetchTestList(),
              ),
            )
          : testList!.tests.isEmpty
          ? Center(
              child: Text('No tests found', style: theme.textTheme.bodyLarge),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    children: testList!.tests.map((test) {
                      return ChoiceChip(
                        elevation: 2,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        label: SizedBox(
                          width: 50,
                          child: Text(
                            test.name,
                            style: theme.textTheme.labelLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        selected: selectedTest?.id == test.id,
                        onSelected: (_) {
                          setState(() {
                            selectedTest = test;
                          });
                          _fetchMarks(test.id);
                        },
                      );
                    }).toList(),
                  ),
                ),
                Center(),

                if (isLoadingMarks)
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (errorMarks != null)
                  Expanded(
                    child: Center(
                      child: ErrorBox(
                        errorMessage:
                            'Couldn\'t fetch ${selectedTest!.name} marks\n$errorMarks!',
                        actionText: 'Retry',
                        onPressed: () => _refreshMarks(),
                      ),
                    ),
                  )
                else if (selectedTest != null && marks != null)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshMarks,
                      child: marks!.markList.isEmpty
                          ? Center(
                              child: Text(
                                'No marks found',
                                style: theme.textTheme.bodyLarge,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              itemCount: marks!.markList.length,
                              itemBuilder: (context, index) {
                                return MarksCard(
                                  test: selectedTest!,
                                  mark: marks!.markList[index],
                                );
                              },
                            ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class MarksCard extends StatelessWidget {
  final Test test;
  final Mark mark;

  const MarksCard({super.key, required this.test, required this.mark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAbsent = mark.marks == -1;

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mark.subject, style: theme.textTheme.titleMedium),
                Text(
                  isAbsent
                      ? 'Absent'
                      : '${mark.marks == mark.marks.toInt() ? mark.marks.toInt() : mark.marks}/${test.maxMarks}',
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            Text(
              TimetableStore.timetable.value?.subjectInfo[mark.subject] ?? '',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: isAbsent ? 0 : (mark.marks / test.maxMarks),
              minHeight: 8,
              color: isAbsent
                  ? Colors.grey
                  : theme.colorScheme.primary.withAlpha(128),
            ),
          ],
        ),
      ),
    );
  }
}
