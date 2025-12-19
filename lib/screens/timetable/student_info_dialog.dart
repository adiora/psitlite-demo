import 'package:flutter/material.dart';
import 'package:psit_lite_demo/state/timetable/timetable_store.dart';

class SubjectInfoDialog extends StatelessWidget {
  const SubjectInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final heading = theme.textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.bold,
    );
    final para = theme.textTheme.bodyMedium;

    return AlertDialog(
      title: const Text('Subject Info'),
      content: TimetableStore.timetable.value?.subjectInfo.isEmpty ?? true
          ? Text('Nothing to show', style: theme.textTheme.bodyLarge)
          : SingleChildScrollView(
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: TimetableStore.timetable.value!.subjectInfo.entries.map((subject) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject.key, style: heading),
                      Text(subject.value, style: para),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
