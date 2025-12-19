import 'package:flutter/material.dart';
import 'package:psit_lite_demo/services/cache_service.dart';
import 'package:psit_lite_demo/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> performPostLogout() async {
  () async {
    await CacheService.clearProfileImage();
    await SharedPreferences.getInstance()
      ..clear()
      ..setBool(
        'isDarkMode',
        ThemeController.themeMode.value == ThemeMode.dark,
      );
  }();
}

String paddedDateDMY(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String paddedDate(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.year}';
}
