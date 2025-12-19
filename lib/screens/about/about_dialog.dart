import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:psitlite_demo/screens/about/liked_widget.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showAppAboutDialog(BuildContext context) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String appName = packageInfo.appName;
  final String version = packageInfo.version;
  if (!context.mounted) return;

  final theme = Theme.of(context);

  showAboutDialog(
    context: context,
    applicationName: appName,
    applicationVersion: 'v$version',
    applicationIcon: Image.asset(
      theme.brightness == Brightness.light
          ? 'assets/icon_dark.png'
          : 'assets/icon_light.png',
      width: 64,
      height: 64,
    ),
    applicationLegalese: '© 2025 adiora',
    children: [
      const SizedBox(height: 16),
      RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            const TextSpan(
              text:
                  'PSiT Lite is a lightweight app to check your attendance, timetable, marks, and more with a clean interface.\n\n'
                  'This app is unofficial and not affiliated with PSIT. It accesses data from the official ERP system for your convenience.\n\n'
                  'I do not collect any personal information through this app.\n\n'
                  'For sugesstions or issues, feel free to reach out to me at ',
            ),
            TextSpan(
              text: 'support@psitlite.space',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse('mailto:support@psitlite.space'));
                },
            ),
            const TextSpan(text: '\n\nVisit '),
            TextSpan(
              text: 'PSiT Lite',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse('https://psitlite.space'));
                },
            ),

            const TextSpan(text: ' for more.'),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const LikedWidget(),
      
    ],
  );
}
