import 'package:flutter/material.dart';
import 'package:psitlite_demo/models/announcements.dart';
import 'package:psitlite_demo/services/mock_api_service.dart';
import 'package:psitlite_demo/services/fetch_service.dart';
import 'package:psitlite_demo/widgets/error_box.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcements')),
      body: const AnnouncementListView(),
    );
  }
}

class AnnouncementListView extends StatefulWidget {
  const AnnouncementListView({super.key});

  @override
  State<AnnouncementListView> createState() => _AnnouncementListViewState();
}

class _AnnouncementListViewState extends State<AnnouncementListView> {
  bool isLoading = true;
  String? error;
  List<Announcement> announcementList = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements({bool refresh = false}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final fetched = await (refresh
          ? MockApiService.getAnnouncements()
          : FetchService.getAnnouncements());

      announcementList = fetched.list;
    } catch (e) {
      error = e.toString();
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _refreshAnnouncements() async {
    return _fetchAnnouncements(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: SizedBox(
          height: 120,
          child: ErrorBox(
            errorMessage: error!,
            actionText: 'Retry',
            onPressed: () => _fetchAnnouncements(refresh: true),
          ),
        ),
      );
    }

    if (announcementList.isEmpty) {
      return const Center(child: Text('No announcements'));
    }

    return RefreshIndicator(
      onRefresh: _refreshAnnouncements,
      child: ListView.builder(
        itemCount: announcementList.length,
        itemBuilder: (_, index) =>
            AnnouncementChip(announcement: announcementList[index]),
      ),
    );
  }
}

class AnnouncementChip extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementChip({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: theme.cardTheme.shape,

      child: InkWell(
        focusColor: theme.colorScheme.primary.withAlpha(48),
        highlightColor: theme.colorScheme.primary.withAlpha(48),

        onTap: announcement.filename.isEmpty
            ? null
            : () async {

              // Announcement link not available in mock

               if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Could not open announcement',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            spacing: 12,
            children: [
              Icon(detectAnnouncementType(announcement.heading)),
              Expanded(
                child: Text(
                  announcement.heading,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData detectAnnouncementType(String heading) {
    final lowerCaseHeading = heading.toLowerCase();

    if (lowerCaseHeading.contains('penalty')) {
      return Icons.gavel_outlined;
    }

    if (lowerCaseHeading.contains('aktu') ||
        lowerCaseHeading.contains('important')) {
      return Icons.label_important_outlined;
    }
    if (lowerCaseHeading.contains('detain')) {
      return Icons.label_important_outline;
    }

    return Icons.campaign_outlined;
  }
}
