import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:psitlite_demo/models/student_timetable.dart';
import 'package:psitlite_demo/state/timetable/timetable_store.dart';
import 'package:psitlite_demo/services/cache_service.dart';
import 'package:psitlite_demo/services/fetch_service.dart';
import 'package:psitlite_demo/utils/util.dart';

class TimetableResolve extends StatefulWidget {
  const TimetableResolve({super.key});

  @override
  State<StatefulWidget> createState() => TimetableResolveState();
}

class TimetableResolveState extends State<TimetableResolve> {
  late List<int> batchList;
  late HashMap<int, HashSet<String>> batchInfoMap;
  bool invalid = false;
  bool isLoading = true;
  bool saved = true;

  @override
  void initState() {
    super.initState();
    _fetchBatchInfo();
  }

  void _fetchBatchInfo() async {
    setState(() {
      isLoading = true;
    });

    final date = paddedDate(DateTime.now());
    final timetableJSON = jsonDecode(
      await FetchService.getTimetableJSON(date: date),
    );
    batchList = TimetableStore.timetable.value?.batchList ?? [];
    batchInfoMap = StudentTimetable.periodByBatches(json: timetableJSON);

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          if (batchList.isNotEmpty) {
            TimetableStore.loadTimetable(
              date: paddedDate(DateTime.now()),
              batchList: batchList,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Batches', style: theme.textTheme.titleLarge),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : batchInfoMap.isEmpty
            ? Center(
                child: Text(
                  'Nothing to show',
                  style: theme.textTheme.bodyLarge,
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: RichText(
                      text: TextSpan(
                        text: 'What\'s this?\n',
                        style: theme.textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text:
                                'You may have noticed wrong classes being displayed for a period when checking timetable.\n'
                                'There are more than 1 batch_ID for which there is a clash at a particular day and period.\n\n'
                                'Just check below whichever classes you attend for a particular batch_ID, and select it.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: batchInfoMap.entries.map((e) {
                              return FilterChip(
                                showCheckmark: false,
                                label: Text(
                                  e.key.toString(),
                                  style: theme.textTheme.labelLarge,
                                ),
                                selected: batchList.contains(e.key),
                                onSelected: (selected) {
                                  setState(() {
                                    saved = false;
                                    if (selected) {
                                      batchList.add(e.key);
                                    } else {
                                      batchList.remove(e.key);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed: saved || batchList.isEmpty
                              ? null
                              : () async {
                                  setState(() => saved = true);
                                  CacheService.cacheStudentBatches(batchList);
                                },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      children: batchInfoMap.entries.map((entry) {
                        return ExpansionTile(
                          childrenPadding: EdgeInsets.all(16),
                          expandedAlignment: Alignment.topLeft,
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          title: Text(
                            'Batch ${entry.key}',
                            style: theme.textTheme.titleMedium,
                          ),
                          children: entry.value.map((className) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: Text(className),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
