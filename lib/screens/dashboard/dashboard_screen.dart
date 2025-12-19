import 'package:flutter/material.dart';
import 'package:psitlite_demo/screens/announcements_screen.dart';
import 'package:psitlite_demo/screens/bottom_sheet.dart';
import 'package:psitlite_demo/screens/marks/marks_section.dart';
import 'package:psitlite_demo/screens/timetable/timetable_section.dart';
import '../attendance/attendance_section.dart';
import 'background_shape.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actionsPadding: const EdgeInsets.all(8),
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        title: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Image.asset(
                theme.brightness == Brightness.light
                    ? 'assets/icon_dark.png'
                    : 'assets/icon_light.png',
                gaplessPlayback: true,
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 8),
              Text('Dashboard', style: theme.textTheme.titleLarge),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnnouncementScreen(),
              ),
            ),
            icon: Icon(Icons.notifications_outlined),
            color: theme.colorScheme.secondary,
          ),
          IconButton(
            color: theme.colorScheme.secondary,
            icon: Icon(Icons.more_vert),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ModalBottomSheet(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundShape(),
          SafeArea(
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AttendanceSection(),
                    const TimetableSection(),
                    const MarksSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
