import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableOrientation {

  static final orientation = ValueNotifier(Orientation.portrait);

  static Future<Orientation> getOrientation() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('isTimetableLandscape') ?? false)
        ? Orientation.landscape
        : Orientation.portrait;
  }

  static Future<void> setOrientation(Orientation orientation) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(
      'isTimetableLandscape',
      orientation == Orientation.landscape ? true : false,
    );
  }

  static void toggleOrientation() {
    orientation.value = orientation.value == Orientation.portrait
          ? Orientation.landscape
          : Orientation.portrait;
    
    updateDeviceOrientation();
    TimetableOrientation.setOrientation(orientation.value);
  }

  static void updateDeviceOrientation() {
    if (orientation.value == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }
}