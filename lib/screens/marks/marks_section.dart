import 'package:flutter/material.dart';
import 'package:psit_lite_demo/screens/marks/marks_screen.dart';
import 'package:psit_lite_demo/screens/marks/oltmarks_screen.dart';

class MarksSection extends StatelessWidget {
  const MarksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'marks_title',
          child: Material(
            color: Colors.transparent,
            child: Text('Marks', style: theme.textTheme.titleLarge),
          ),
        ),
        ListTile(
          title: Text('View Marks', style: theme.textTheme.titleMedium),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.secondary,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return const MarksScreen();
                },
              ),
            );
          },
        ),
        ListTile(
          title: Text('View OLT Marks', style: theme.textTheme.titleMedium),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.secondary,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return const OltScreen();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
