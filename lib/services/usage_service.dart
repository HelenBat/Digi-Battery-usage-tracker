import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';  // Added import for debugPrint

class UsageService {
  static const _channel = MethodChannel('social_media_carbon_footprint/usage');

  /// CO₂ emissions (grams per minute) for each app
  final Map<String, double> co2PerMinute = {
    'com.google.android.youtube': 0.46,
    'tv.twitch.android.app': 0.55,
    'com.twitter.android': 0.60,
    'com.linkedin.android': 0.71,
    'com.facebook.katana': 0.79,
    'com.snapchat.android': 0.87,
    'com.instagram.android': 1.05,
    'com.pinterest': 1.30,
    'com.reddit.frontpage': 2.48,
    'com.zhiliaoapp.musically': 2.63,
  };

  /// Energy consumption (mAh per minute) for each app
  final Map<String, double> energyPerMinute = {
    'com.google.android.youtube': 8.58,
    'tv.twitch.android.app': 9.05,
    'com.twitter.android': 10.28,
    'com.linkedin.android': 8.92,
    'com.facebook.katana': 12.36,
    'com.snapchat.android': 11.48,
    'com.instagram.android': 8.90,
    'com.pinterest': 10.83,
    'com.reddit.frontpage': 11.04,
    'com.zhiliaoapp.musically': 15.81,
  };

  /// Fetches today's app usage data from the native Android method.
  /// Each object in the list contains:
  /// {package: "...", minutes: XX.XX, co2: YY.YY, energy: ZZ.ZZ}
  Future<List<Map<String, dynamic>>> getTodayUsage() async {
    try {
      final String result = await _channel.invokeMethod('getDailyUsage');
      List<Map<String, dynamic>> usageList = List<Map<String, dynamic>>.from(json.decode(result));

      // Debug print usageList before the loop
      debugPrint('UsageList BEFORE loop: $usageList');

      // Calculate CO₂ and energy for each app if missing from native side
      for (var usage in usageList) {
        String packageName = usage['package'];
        double minutes = usage['minutes'];

        usage['co2'] ??= minutes * (co2PerMinute[packageName] ?? 0.0);
        usage['energy'] ??= minutes * (energyPerMinute[packageName] ?? 0.0);
      }

      // Debug print usageList after the loop
      debugPrint('UsageList AFTER loop: $usageList');

      return usageList;
    } on PlatformException catch (e) {
      debugPrint('Error fetching today\'s usage data: $e');
      return [];
    }
  }

  /// Fetches usage data for a custom date range from the native Android method.
  /// Each object in the list contains:
  /// {package: "...", minutes: XX.XX, co2: YY.YY, energy: ZZ.ZZ}
  Future<List<Map<String, dynamic>>> getRangeUsage({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final String result = await _channel.invokeMethod('getRangeUsage', {
        'startTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
      });
      List<Map<String, dynamic>> usageList = List<Map<String, dynamic>>.from(json.decode(result));

      // Calculate CO₂ and energy for each app if missing from native side
      for (var usage in usageList) {
        String packageName = usage['package'];
        double minutes = usage['minutes'];

        usage['co2'] ??= minutes * (co2PerMinute[packageName] ?? 0.0);
        usage['energy'] ??= minutes * (energyPerMinute[packageName] ?? 0.0);
      }

      return usageList;
    } on PlatformException catch (e) {
      debugPrint('Error fetching range usage data: $e');
      return [];
    }
  }
}
