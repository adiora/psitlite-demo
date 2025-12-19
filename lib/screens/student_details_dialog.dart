import 'package:flutter/material.dart';
import 'package:psit_lite_demo/state/student.dart';

Future<void> showStudentDetailsDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) {
      final theme = Theme.of(context);
      final heading = theme.textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.bold,
      );
      final para = theme.textTheme.bodyMedium;
      return AlertDialog(
        title: const Text('Student Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text('University Roll No:', style: heading),
              Text(Student.data.userId, style: para),
              const SizedBox(height: 12),
              Text('Library Code:', style: heading),
              Text(Student.data.sId, style: para),
              const SizedBox(height: 12),
              Text('Name:', style: heading),
              Text(Student.data.name, style: para),
              const SizedBox(height: 12),
              Text('Section:', style: heading),
              Text(Student.data.section, style: para),
              const SizedBox(height: 12),
              Text('Date of Birth:', style: heading),
              Text(Student.data.dob, style: para),
              const SizedBox(height: 12),
              Text('Phone:', style: heading),
              Text(Student.data.phone, style: para),
              const SizedBox(height: 12),
              Text('Email:', style: heading),
              Text(Student.data.email, style: para),
              const SizedBox(height: 12),
              Text('Temp Address:', style: heading),
              Text(Student.data.tempAddress, style: para),
              const SizedBox(height: 12),
              Text('Permanent Address:', style: heading),
              Text(Student.data.permanentAddress, style: para),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
