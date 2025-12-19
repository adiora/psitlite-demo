import 'package:flutter/material.dart';
import 'package:psitlite_demo/services/mock_data.dart';
import 'package:psitlite_demo/state/student.dart';
import 'package:psitlite_demo/services/cache_service.dart';
import 'package:psitlite_demo/services/fetch_service.dart';
import 'package:psitlite_demo/theme/theme.dart';
import 'package:psitlite_demo/theme/app_theme.dart';
import 'screens/dashboard/dashboard_screen.dart';
import '../screens/login_screen.dart';

class AppRoot extends StatelessWidget {
  final bool loggedIn;
  const AppRoot({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.themeMode,
      builder: (_, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: _PostMaterialInitializer(
            child: loggedIn ? const DashboardScreen() : const LoginScreen(),
          ),
        );
      },
    );
  }
}

class _PostMaterialInitializer extends StatefulWidget {
  final Widget child;
  const _PostMaterialInitializer({required this.child});

  @override
  State<_PostMaterialInitializer> createState() =>
      _PostMaterialInitializerState();
}

class _PostMaterialInitializerState extends State<_PostMaterialInitializer> {
  bool _ran = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_ran) return;
    _ran = true;

    Future.microtask(() async {
      CacheService.clearOldCache();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('This a demo build with mock data')));
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<bool> _loadInitialData() async {
  await MockData.initialize();
  final data = await FetchService.getStudentDetails();
  if (data != null) {
    Student.initializeWith(data: data);
    return true;
  }
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ThemeController.setInitialTheme();

  final loggedIn = await _loadInitialData();

  runApp(AppRoot(loggedIn: loggedIn));
}
