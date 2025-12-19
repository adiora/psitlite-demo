import 'package:flutter/material.dart';
import 'package:psitlite_demo/models/olt_report.dart';
import 'package:psitlite_demo/screens/marks/oltsolution_screen.dart';
import 'package:psitlite_demo/services/mock_api_service.dart';
import 'package:psitlite_demo/services/fetch_service.dart';
import 'package:psitlite_demo/utils/util.dart';
import 'package:psitlite_demo/widgets/error_box.dart';

class OltScreen extends StatefulWidget {
  const OltScreen({super.key});

  @override
  State<StatefulWidget> createState() => _OltScreenState();
}

class _OltScreenState extends State<OltScreen> {
  bool isLoading = true;
  String? error;
  List<OltDetail> oltList = [];

  @override
  void initState() {
    super.initState();
    _fetchOltReport();
  }

  Future<void> _fetchOltReport({bool refresh = false}) async {
    setState(() {
      error = null;
      isLoading = true;
    });

    try {
      final report = await (refresh
          ? MockApiService.getOltReport()
          : FetchService.getOltReport());
      oltList = report.list;
    } catch (e) {
      error = e.toString();
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _refreshOltReport() async {
    return _fetchOltReport(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('OLT ', style: theme.textTheme.titleLarge),
            Hero(
              tag: 'marks_title',
              child: Material(
                color: Colors.transparent,
                child: Text('Marks', style: theme.textTheme.titleLarge),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshOltReport,
              child: oltList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height -
                                  kToolbarHeight -
                                  MediaQuery.of(context).padding.top,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                error == null
                                    ? Text(
                                        'No OLT Marks found',
                                        style: theme.textTheme.bodyLarge,
                                      )
                                    : ErrorBox(
                                        errorMessage: error!,
                                        actionText: 'Retry',
                                        onPressed: () => _refreshOltReport(),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: oltList.length,
                      itemBuilder: (_, index) {
                        final olt = oltList[index];
                        final total = olt.correct + olt.incorrect;
                        final percentage = (olt.correct / total * 100)
                            .toStringAsFixed(1);

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          clipBehavior: Clip.antiAlias,
                          shape: theme.cardTheme.shape,
                          child: InkWell(
                            focusColor: theme.colorScheme.primary.withAlpha(48),
                            highlightColor: theme.colorScheme.primary.withAlpha(
                              48,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    paddedDateDMY(olt.date),
                                    style: theme.textTheme.labelMedium!
                                        .copyWith(
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    olt.testName,
                                    style: theme.textTheme.labelLarge!.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _infoTile(
                                        'Questions',
                                        '$total',
                                        Colors.blue,
                                        theme,
                                      ),

                                      _infoTile(
                                        'Correct',
                                        '${olt.correct}',
                                        Colors.green,
                                        theme,
                                      ),
                                      _infoTile(
                                        'Incorrect',
                                        '${olt.incorrect}',
                                        Colors.red,
                                        theme,
                                      ),
                                      _infoTile(
                                        'Percent',
                                        '$percentage%',
                                        Colors.teal,
                                        theme,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OltSolutionScreen(olt: olt),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _infoTile(String label, String value, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
