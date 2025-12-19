import 'dart:convert';

import 'package:psit_lite_demo/services/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStats {
  final bool visited;
  final bool liked;
  const UserStats({required this.visited, required this.liked});

  UserStats copyWith({bool? visited, bool? liked}) =>
      UserStats(
        visited: visited ?? this.visited,
        liked: liked ?? this.liked,
      );
}

class Stats {
  final int likes;
  final int visits;
  const Stats({required this.likes, required this.visits});
}

class LikeService {
  static UserStats? _cached;

  static Future<UserStats> fetchUserStats() async {
    if (_cached != null) return _cached!;

    final prefs = await SharedPreferences.getInstance();
    final visited = prefs.getBool('visited') ?? false;
    final liked = prefs.getBool('liked') ?? false;

    _cached = UserStats(visited: true, liked: liked);

    if (!visited) {
      prefs.setBool('visited', true);
    }

    return _cached!;
  }

  static Future<Stats> fetchStats() async {
    final stats = jsonDecode(await MockData.getLikeStates());
    return Stats(likes: stats['likes'], visits: stats['visits']);
  }

  static Future<void> like() async {
    _cached = _cached?.copyWith(liked: true);

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('liked', true);
  }

  static Future<void> dislike() async {
    _cached = _cached?.copyWith(liked: false);

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('liked', false);
  }
}
