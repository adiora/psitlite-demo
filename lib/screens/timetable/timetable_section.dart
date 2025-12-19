import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:psit_lite_demo/models/student_timetable.dart';
import 'package:psit_lite_demo/domain/timetable/timetable_constants.dart';
import 'package:psit_lite_demo/screens/timetable/timetable_resolve.dart';
import 'package:psit_lite_demo/screens/timetable/timetable_screen.dart';
import 'package:psit_lite_demo/state/timetable/timetable_store.dart';
import 'package:psit_lite_demo/services/cache_service.dart';
import 'package:psit_lite_demo/services/fetch_service.dart';
import 'package:psit_lite_demo/utils/util.dart';
import 'package:psit_lite_demo/widgets/error_box.dart';
import 'package:psit_lite_demo/widgets/shimmer_box.dart';

class TimetableSection extends StatefulWidget {
  const TimetableSection({super.key});

  @override
  State<TimetableSection> createState() => _TimetableSectionState();
}

class _TimetableSectionState extends State<TimetableSection> {
  String error = '';
  bool isLoading = true;
  bool ambiguous = false;
  final DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      isLoading = true;
      ambiguous = false;
    });

    final date = paddedDate(now);

    try {
      List<int> batchList = await FetchService.getBatchList() ?? const [];

      if (batchList.isEmpty) {
        final timetableJSON = jsonDecode(
          await FetchService.getTimetableJSON(date: date),
        );

        ambiguous = StudentTimetable.isAmbiguous(json: timetableJSON);

        if (!ambiguous) {
          batchList = StudentTimetable.getBatchList(json: timetableJSON);
          CacheService.cacheStudentBatches(batchList);
          await TimetableStore.loadTimetable(date: date, batchList: batchList);
        }
      } else {
        await TimetableStore.loadTimetable(date: date, batchList: batchList);
      }

      error = '';
    } catch (e) {
      error = e.toString();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: TimetableStore.timetable,
      builder: (context, timetable, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              title: Material(
                color: Colors.transparent,
                child: Hero(
                  tag: 'timetable_title',
                  child: Text(
                    'Today\'s Timetable',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              trailing: isLoading || timetable == null || ambiguous
                  ? null
                  : Icon(
                      Icons.navigate_next,
                      color: theme.colorScheme.secondary,
                    ),
              onTap: isLoading || timetable == null || ambiguous
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TimetableScreen(),
                        ),
                      );
                    },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                weekdays[now.weekday - 1],
                style: theme.textTheme.titleMedium,
              ),
            ),

            if (isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                child: Column(
                  spacing: 16,
                  children: List.generate(4, (_) {
                    return const ShimmerBox(height: 60);
                  }),
                ),
              )
            else if (ambiguous)
              Center(
                child: ErrorBox(
                  errorMessage: 'Ambiguous Periods Found',
                  actionText: 'Resolve',
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TimetableResolve(),
                      ),
                    ).whenComplete(() async {
                      final batchSet = await FetchService.getBatchList();
                      if (batchSet != null && batchSet.isNotEmpty) {
                        _fetchTimetable();
                      }
                    });
                  },
                ),
              )
            else if (timetable == null)
              Center(
                child: ErrorBox(
                  errorMessage: 'Couldn\'t fetch timetable\n$error',
                  actionText: 'Refresh',

                  onPressed: _fetchTimetable,
                ),
              )
            else if (now.hour > 18 ||
                (now.hour > 16 &&
                    timetable.periods[now.weekday - 1][8] == null) ||
                timetable.periods[now.weekday - 1].every(
                  (period) => period == null,
                ))
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'zzz... no classes',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              )
            else
              SizedBox(
                height: 305,
                child: _PeriodView(
                  initialPage: now.hour < 12 ? 0 : (now.hour < 17 ? 1 : 2),
                  periods: timetable.periods[now.weekday - 1],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PeriodView extends StatefulWidget {
  final int initialPage;
  final List<Period?> periods;

  const _PeriodView({required this.initialPage, required this.periods});

  @override
  State<StatefulWidget> createState() => _PeriodViewState();
}

class _PeriodViewState extends State<_PeriodView> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nonNullPeriods = widget.periods.whereType<Period>().toList();

    return PageView.builder(
      controller: pageController,
      itemCount: (nonNullPeriods.length + 3) ~/ 4,
      itemBuilder: (context, pageIndex) {
        final start = pageIndex * 4;
        final end = start + 4 > nonNullPeriods.length
            ? nonNullPeriods.length
            : start + 4;
        return Column(
          children: [
            for (int i = start; i < end; ++i)
              _PeriodRow(period: nonNullPeriods[i]),
          ],
        );
      },
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final Period period;

  const _PeriodRow({required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int periodIndex = period.periodNumber;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 16,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: period.isLab
                  ? theme.colorScheme.primary.withAlpha(180)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Text(
              'P${periodIndex + 1}',
              style: theme.textTheme.bodyLarge!.copyWith(
                color: period.isLab
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),

          Text(periodTimes[periodIndex], style: theme.textTheme.bodyMedium),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(period.subjectCode, style: theme.textTheme.bodyLarge),
                Text(period.empName, style: theme.textTheme.bodyMedium),
                Text(period.room, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
