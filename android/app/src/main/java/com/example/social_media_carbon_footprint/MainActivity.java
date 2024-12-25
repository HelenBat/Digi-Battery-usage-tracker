package com.example.social_media_carbon_footprint;

import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "social_media_carbon_footprint/usage";

    // Hard-coded map of (Android package name -> grams of CO2 per MINUTE)
    // Values below are only EXAMPLES (not the actual values from carbonliteracy.com).
    // Adjust them according to the reference page’s data (grams per minute).
    private static final Map<String, Double> SOCIAL_MEDIA_CO2_MAP = new HashMap<String, Double>() {{
        put("com.facebook.katana", 0.79); // Facebook
        put("com.instagram.android", 1.05); // Instagram
        put("com.twitter.android", 0.60); // Twitter (X)
        put("com.snapchat.android", 0.87); // Snapchat
        put("com.pinterest", 0.63); // Pinterest
        put("com.linkedin.android", 0.72); // LinkedIn
        put("com.reddit.frontpage", 0.69); // Reddit
        put("com.tumblr", 0.80); // Tumblr
        put("com.google.android.youtube", 2.00); // YouTube (if considered social media)
        put("com.whatsapp", 0.55); // WhatsApp
        // Feel free to replace or remove any that differ from your needs
    }};

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getDailyUsage")) {
                        // Return usage stats for TODAY
                        String usageData = getDailyUsageStats();
                        result.success(usageData);
                    } else if (call.method.equals("getRangeUsage")) {
                        // Return usage stats for custom range: startTime, endTime
                        // Passed from Dart as milliseconds
                        long startTime = call.argument("startTime");
                        long endTime = call.argument("endTime");
                        String usageData = getRangeUsageStats(startTime, endTime);
                        result.success(usageData);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    /**
     * Get usage for the current day, from midnight until now.
     */
    private String getDailyUsageStats() {
        Calendar calendar = Calendar.getInstance();
        long endTime = calendar.getTimeInMillis();
        // Set to midnight
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        long startTime = calendar.getTimeInMillis();
        return getUsageFormatted(startTime, endTime);
    }

    /**
     * Get usage for a custom date range.
     */
    private String getRangeUsageStats(long startTime, long endTime) {
        return getUsageFormatted(startTime, endTime);
    }

    /**
     * Core usage retrieval, filters only the 10 social media apps of interest, 
     * calculates total usage minutes, and multiplies by each app’s CO2 factor.
     */
    private String getUsageFormatted(long startTime, long endTime) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return "Unsupported Android version for UsageStats (below Lollipop).";
        }

        UsageStatsManager usageStatsManager = (UsageStatsManager) getSystemService(Context.USAGE_STATS_SERVICE);
        List<UsageStats> stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY, startTime, endTime);

        if (stats == null || stats.isEmpty()) {
            return "No usage data available. (Check if permission is granted)";
        }

        // We’ll collect usage data for relevant social media apps only
        HashMap<String, Long> appForegroundTimeMap = new HashMap<>();
        for (UsageStats usage : stats) {
            String packageName = usage.getPackageName();
            if (SOCIAL_MEDIA_CO2_MAP.containsKey(packageName)) {
                long totalForegroundTime = usage.getTotalTimeInForeground(); // in ms
                // Accumulate in case of multiple intervals
                appForegroundTimeMap.put(
                        packageName,
                        appForegroundTimeMap.getOrDefault(packageName, 0L) + totalForegroundTime
                );
            }
        }

        // Build a JSON-like string with usage in minutes and CO2
        List<String> usageResults = new ArrayList<>();
        for (Map.Entry<String, Long> entry : appForegroundTimeMap.entrySet()) {
            String packageName = entry.getKey();
            long totalMs = entry.getValue();
            double totalMinutes = totalMs / 60000.0; // convert ms to minutes
            double co2PerMinute = SOCIAL_MEDIA_CO2_MAP.get(packageName);
            double totalCO2 = totalMinutes * co2PerMinute; // grams of CO2

            usageResults.add(String.format(
                    "{\"package\":\"%s\",\"minutes\":%.2f,\"co2\":%.2f}",
                    packageName, totalMinutes, totalCO2
            ));
        }

        // Return a list of JSON objects in a string
        return "[" + String.join(",", usageResults) + "]";
    }
}
