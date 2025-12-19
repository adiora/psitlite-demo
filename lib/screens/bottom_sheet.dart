import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:psitlite_demo/screens/about/about_dialog.dart';
import 'package:psitlite_demo/screens/student_details_dialog.dart';
import 'package:psitlite_demo/state/student.dart';
import 'package:psitlite_demo/screens/login_screen.dart';
import 'package:psitlite_demo/services/fetch_service.dart';
import 'package:psitlite_demo/theme/theme.dart';
import 'package:psitlite_demo/utils/util.dart';
import 'package:psitlite_demo/widgets/shimmer_box.dart';

class ModalBottomSheet extends StatefulWidget {
  const ModalBottomSheet({super.key});

  @override
  State<ModalBottomSheet> createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  bool isLoading = true;
  Image? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  void _loadProfileImage() async {
    Uint8List? imageBytes;
    try {
      imageBytes = await FetchService.getProfileImage();
    } catch (_) {}

    if (mounted) {
      setState(() {
        isLoading = false;
        _profileImage = imageBytes == null
            ? null
            : Image.memory(imageBytes, scale: 8, fit: BoxFit.fill);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.horizontal_rule, color: Colors.grey),
          const SizedBox(height: 8),
          Row(
            spacing: 16,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isLoading
                    ? SizedBox(width: 46, child: ShimmerBox(height: 58))
                    : _profileImage ?? Icon(Icons.person_outlined, size: 46),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Student.data.name, style: theme.textTheme.titleMedium),
                    Text(
                      Student.data.userId,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async => showStudentDetailsDialog(context),
                child: Text(
                  'More',
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: ThemeController.themeMode.value == ThemeMode.dark,
              onChanged: (value) {
                ThemeController.toggleTheme();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => showAppAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await performPostLogout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
