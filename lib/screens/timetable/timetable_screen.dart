import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psitlite_demo/screens/timetable/student_info_dialog.dart';
import 'package:psitlite_demo/screens/timetable/timetaable_grid.dart';
import 'package:psitlite_demo/domain/timetable/timetable_orientation.dart';
import 'package:psitlite_demo/screens/timetable/timetable_resolve.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  void initState() {
    super.initState();
    _initializeOrientation();
  }

  Future<void> _initializeOrientation() async {
    TimetableOrientation.orientation.value =
        await TimetableOrientation.getOrientation();
    TimetableOrientation.updateDeviceOrientation();
  }

  @override
  dispose() async {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.all(8),
        title: Hero(
          tag: 'timetable_title',
          child: Material(
            color: Colors.transparent,
            child: Text('Timetable', style: theme.textTheme.titleLarge),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimetableResolve()),
              );
            },
            icon: Icon(Icons.filter_list),
          ),

          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return const SubjectInfoDialog();
              },
            ),
            icon: Icon(Icons.info_outline),
          ),

          IconButton(
            onPressed: TimetableOrientation.toggleOrientation,
            icon: ValueListenableBuilder(
              valueListenable: TimetableOrientation.orientation,
              builder: (_, orientation, _) {
                return Icon(
                  orientation == Orientation.portrait
                      ? Icons.stay_current_portrait_outlined
                      : Icons.stay_current_landscape_outlined,
                );
              },
            ),
          ),
        ],
      ),
      body: const TimetableGrid(),
    );
  }
}