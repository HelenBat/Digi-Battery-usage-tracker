import 'dart:convert';
import 'package:flutter/services.dart';

class UsageService {
  static const _channel = MethodChannel('social_media_carbon_footprint/usage');

  /// Returns a list of usage objects for today.
  /// Each object looks like: {package: "...", minutes: XX.XX, co2: YY.YY}
  Future<List<Map<String, dynamic>>> getTodayUsage() async {
    try {
      final String result = await _channel.invokeMethod('getDailyUsage');
      return List<Map<String, dynamic>>.from(json.decode(result));
    } on PlatformException catch (e) {
      // In case of iOS or any error
      return [];
    }
  }

  /// Returns usage objects for a custom date range (start, end in milliseconds).
  Future<List<Map<String, dynamic>>> getRangeUsage({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final String result = await _channel.invokeMethod('getRangeUsage', {
        'startTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
      });
      return List<Map<String, dynamic>>.from(json.decode(result));
    } on PlatformException catch (e) {
      return [];
    }
  }
}
