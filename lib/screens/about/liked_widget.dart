import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:psit_lite_demo/services/like_service.dart';

class LikedWidget extends StatefulWidget {
  const LikedWidget({super.key});

  @override
  State<LikedWidget> createState() => _LikedWidgetState();
}

class _LikedWidgetState extends State<LikedWidget> {
  bool _isLoading = true;

  int _likes = 0;
  int _visits = 0;
  bool _hasLiked = false;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    if (!_isLoading) {
      _isLoading = true;
      if (mounted) setState(() {});
    }

    try {
      final results = await Future.wait([
        LikeService.fetchUserStats(),
        LikeService.fetchStats(),
      ]);

      final userStats = results[0] as UserStats;
      final globalStats = results[1] as Stats;

      _hasLiked = userStats.liked;
      _likes = globalStats.likes;
      _visits = globalStats.visits;
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading like stats: $e');
    } finally {
      _isLoading = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _onToggleLike() async {
    if (_isLoading) return;

    final newHasLiked = !_hasLiked;
    final newLikes = _likes + (newHasLiked ? 1 : -1);

    int newVisits = _visits;
    if (newHasLiked) {
      if (_visits <= _likes) {
        newVisits = _visits + 1;
      }
      if (mounted) _showToast(context, newLikes, newVisits);
    }

    setState(() {
      _hasLiked = newHasLiked;
      _likes = newLikes;
      _visits = newVisits;
    });

    try {
      if (_hasLiked) {
        LikeService.like();
      } else {
        LikeService.dislike();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error sending like/dislike: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = _hasLiked ? Colors.red : theme.iconTheme.color;

    final onPressedCallback = _isLoading ? null : _onToggleLike;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!_isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              "$_likes liked out of $_visits",
              style: theme.textTheme.bodyMedium,
            ),
          ),

        TextButton.icon(
          onPressed: onPressedCallback,
          icon: Icon(
            _hasLiked ? Icons.favorite : Icons.favorite_border,
            color: iconColor,
          ),
          label: Text(
            _hasLiked ? "Liked" : "Like",
            style: theme.textTheme.labelLarge!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

void _showToast(BuildContext context, int likes, int visits) {
  final overlay = Overlay.of(context);

  OverlayEntry? entry;

  entry = OverlayEntry(
    builder: (_) => _CenterToast(
      onDismiss: () {
        entry?.remove();
        entry = null;
      },
    ),
  );

  overlay.insert(entry!);
}

class _CenterToast extends StatefulWidget {
  final VoidCallback onDismiss;

  const _CenterToast({required this.onDismiss});

  @override
  State<_CenterToast> createState() => _CenterToastState();
}

class _CenterToastState extends State<_CenterToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 200),
    vsync: this,
  );

  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(_controller);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward().then((_) {
      _timer = Timer(const Duration(seconds: 1), _dismiss);
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toastText = "Thanks for liking!";

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                  ),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(20),
                color: Colors.red.shade50,
                shadowColor: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        toastText,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
