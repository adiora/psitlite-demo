import 'package:flutter/material.dart';
import 'package:psitlite_demo/models/student_timetable.dart';
import 'package:psitlite_demo/domain/timetable/timetable_constants.dart';
import 'package:psitlite_demo/domain/timetable/timetable_orientation.dart';
import 'package:psitlite_demo/state/timetable/timetable_store.dart';
import 'package:psitlite_demo/utils/util.dart';
import 'package:psitlite_demo/widgets/error_box.dart';

class TimetableGrid extends StatefulWidget {
  static const int lunchIndex = 3;

  const TimetableGrid({super.key});

  @override
  State<TimetableGrid> createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  String error = '';
  bool isLoading = false;

  DateTime date = DateTime.now();
  StudentTimetable? localTimetable;

  @override
  void initState() {
    super.initState();

    localTimetable = TimetableStore.timetable.value;

    TimetableStore.timetable.addListener(_onGlobalTimetableChange);
  }

  @override
  void dispose() {
    TimetableStore.timetable.removeListener(_onGlobalTimetableChange);
    super.dispose();
  }

  // When batchlist changes
  void _onGlobalTimetableChange() async {
    _refreshTimetable();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return ErrorBox(
        errorMessage: error,
        actionText: 'Retry',
        onPressed: () => _refreshTimetable(),
      );
    }

    if (localTimetable == null) {
      return const SizedBox();
    }

    return _buildTable(context);
  }

  Widget _buildTable(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return InteractiveViewer(
      constrained: false,

      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ValueListenableBuilder(
          valueListenable: TimetableOrientation.orientation,
          builder: (_, orientation, __) {
            return orientation == Orientation.portrait
                ? PortraitTable(
                    dateTime: date,
                    timetable: localTimetable!,
                    onDateSelected: _onDateSelected,
                    size: size,
                  )
                : LandscapeTable(
                    dateTime: date,
                    timetable: localTimetable!,
                    onDateSelected: _onDateSelected,
                    size: size,
                  );
          },
        ),
      ),
    );
  }

  Future<void> _onDateSelected(DateTime picked) async {
    if (picked.month == date.month && picked.day == date.day) return;
    date = picked;
    _refreshTimetable();
  }

  Future<void> _refreshTimetable() async {
    setState(() => isLoading = true);

    try {
      final result = await TimetableStore.getTimetable(
        date: paddedDate(date),
        batchList: TimetableStore.timetable.value!.batchList,
      );

      localTimetable = result;
    } catch (e) {
      error = e.toString();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

const double minCellHeight = 60;

class PortraitTable extends StatelessWidget {
  final DateTime dateTime;
  final StudentTimetable timetable;
  final Future<void> Function(DateTime) onDateSelected;
  final Size size;

  const PortraitTable({
    super.key,
    required this.dateTime,
    required this.timetable,
    required this.onDateSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    final height = size.height / 11.7;

    final cellHeight = minCellHeight > height ? minCellHeight : height;

    return Table(
      border: TableBorder.all(color: color.outline),
      columnWidths: {0: FixedColumnWidth(80)},
      defaultColumnWidth: FixedColumnWidth(120),
      children: [
        TableRow(
          children: [
            SelectDateCell(
              dateTime: dateTime,
              onDateSelected: onDateSelected,
              cellHeight: cellHeight * 0.8,
            ),
            for (int dayIndex = 0; dayIndex < timetable.dayCount; ++dayIndex)
              DayCell(dayIndex: dayIndex, cellHeight: cellHeight * 0.8),
          ],
        ),
        for (int pIndex = 0; pIndex < timetable.periodCount; ++pIndex) ...[
          TableRow(
            children: [
              PeriodTimeCell(time: periodTimes[pIndex], cellHeight: cellHeight),
              for (int dayIndex = 0; dayIndex < timetable.dayCount; ++dayIndex)
                SubjectCell(
                  period: timetable.periods[dayIndex][pIndex],
                  cellHeight: cellHeight,
                ),
            ],
          ),
          if (pIndex == 1 || pIndex == 5)
            _buildTableRow(
              theme,
              span: timetable.dayCount + 1,
              text: 'Break',
              height: cellHeight * 0.4,
              backgroundColor: color.surfaceContainerHighest,
            ),
          if (pIndex == TimetableGrid.lunchIndex)
            _buildTableRow(
              theme,
              span: timetable.dayCount + 1,
              text: 'Lunch',
              height: cellHeight * 0.6,
              backgroundColor: color.primaryContainer,
            ),
        ],
      ],
    );
  }

  TableRow _buildTableRow(
    ThemeData theme, {
    required int span,
    required String text,
    required double height,
    required Color backgroundColor,
  }) {
    final color = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TableRow(
      children: [
        Container(
          height: height,
          alignment: Alignment.center,
          color: backgroundColor,
          child: Text(
            text,
            style: textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        for (int i = 1; i < span; ++i)
          Container(height: height, color: backgroundColor),
      ],
    );
  }
}

class LandscapeTable extends StatelessWidget {
  final DateTime dateTime;
  final StudentTimetable timetable;
  final Future<void> Function(DateTime) onDateSelected;
  final Size size;

  const LandscapeTable({
    super.key,
    required this.dateTime,
    required this.timetable,
    required this.onDateSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final height = size.height / 6;

    final cellHeight = minCellHeight > height ? minCellHeight : height;

    final int lunchIndex = TimetableGrid.lunchIndex;

    return Table(
      border: TableBorder.all(color: color.outline),
      columnWidths: {
        0: FixedColumnWidth(80),
        3: FixedColumnWidth(24),
        lunchIndex + 3: FixedColumnWidth(36),
        9: FixedColumnWidth(24),
      },
      defaultColumnWidth: const FixedColumnWidth(120),
      children: [
        TableRow(
          children: [
            SelectDateCell(
              dateTime: dateTime,
              onDateSelected: onDateSelected,
              cellHeight: cellHeight * 0.8,
            ),
            for (int pIndex = 0; pIndex < timetable.periodCount; ++pIndex) ...[
              PeriodTimeCell(
                time: periodTimesLandscape[pIndex],
                cellHeight: cellHeight * 0.8,
              ),

              if (pIndex == 1 || pIndex == 5 || pIndex == lunchIndex)
                Container(
                  height: cellHeight * 0.8,
                  alignment: Alignment.center,
                  color: pIndex == lunchIndex
                      ? color.primaryContainer
                      : color.surfaceContainerHighest,
                  child: Text(
                    pIndex == lunchIndex ? 'L' : 'B',
                    style: theme.textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
        for (int dayIndex = 0; dayIndex < timetable.dayCount; ++dayIndex)
          TableRow(
            children: [
              DayCell(dayIndex: dayIndex, cellHeight: cellHeight),
              for (
                int pIndex = 0;
                pIndex < timetable.periodCount;
                ++pIndex
              ) ...[
                SubjectCell(
                  period: timetable.periods[dayIndex][pIndex],
                  cellHeight: cellHeight,
                ),

                if (pIndex == 1 || pIndex == 5 || pIndex == lunchIndex)
                  Container(
                    height: cellHeight,
                    color: pIndex == lunchIndex
                        ? color.primaryContainer
                        : color.surfaceContainerHighest,
                  ),
              ],
            ],
          ),
      ],
    );
  }
}

class SelectDateCell extends StatelessWidget {
  final DateTime dateTime;
  final Future<void> Function(DateTime) onDateSelected;
  final double cellHeight;

  const SelectDateCell({
    super.key,
    required this.dateTime,
    required this.onDateSelected,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cellHeight,
      alignment: Alignment.center,
      child: TextButton(
        style: Theme.of(context).textButtonTheme.style!.copyWith(
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: dateTime.subtract(const Duration(days: 364)),
            lastDate: dateTime.add(const Duration(days: 364)),
          );
          if (picked != null) onDateSelected(picked);
        },
        child: Text(
          textAlign: TextAlign.center,
          'Select\n${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${(dateTime.year % 100).toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}

class DayCell extends StatelessWidget {
  final int dayIndex;
  final double cellHeight;

  const DayCell({super.key, required this.dayIndex, required this.cellHeight});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      height: cellHeight,
      alignment: Alignment.center,
      color: color.primaryContainer,
      child: Text(
        weekdaydAbbr[dayIndex],
        style: text.labelLarge!.copyWith(
          color: color.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class PeriodTimeCell extends StatelessWidget {
  final String time;
  final double cellHeight;

  const PeriodTimeCell({
    super.key,
    required this.time,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      alignment: Alignment.center,
      height: cellHeight,
      color: color.surfaceContainerHighest,
      child: Text(
        time,
        style: text.labelLarge!.copyWith(
          color: color.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SubjectCell extends StatelessWidget {
  final Period? period;
  final double cellHeight;

  const SubjectCell({
    super.key,
    required this.period,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (period == null) {
      return Container(height: cellHeight, color: color.surface);
    }

    final Period p = period!;

    return Container(
      height: cellHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      color: p.isLab ? color.tertiaryContainer : color.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            p.subjectCode,
            style: text.labelLarge!.copyWith(
              color: p.isLab ? color.onTertiaryContainer : color.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            p.empName,
            style: text.labelMedium!.copyWith(
              color: p.isLab
                  ? color.onTertiaryContainer.withAlpha(180)
                  : color.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            p.room,
            style: text.labelMedium!.copyWith(
              color: p.isLab
                  ? color.onTertiaryContainer.withAlpha(180)
                  : color.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
