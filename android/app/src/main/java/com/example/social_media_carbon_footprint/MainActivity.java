package com.example.social_media_carbon_footprint;

import android.app.AppOpsManager;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "social_media_carbon_footprint/usage";

    // Hard-coded map of (Android package name -> grams of CO2 per MINUTE)
    // Adjust them according to the reference page’s data (grams per minute).
    private static final Map<String, Double> SOCIAL_MEDIA_CO2_MAP = new HashMap<String, Double>() {{
        put("com.google.android.youtube", 0.46); // YouTube
        put("tv.twitch.android.app", 0.55); // Twitch
        put("com.twitter.android", 0.60); // Twitter
        put("com.linkedin.android", 0.71); // LinkedIn
        put("com.facebook.katana", 0.79); // Facebook
        put("com.snapchat.android", 0.87); // Snapchat
        put("com.instagram.android", 1.05); // Instagram
        put("com.pinterest", 1.30); // Pinterest
        put("com.reddit.frontpage", 2.48); // Reddit
        put("com.zhiliaoapp.musically", 2.63); // TikTok
    }};

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "getDailyUsage": {
                            // Return usage stats for TODAY
                            String usageData = getDailyUsageStats();
                            result.success(usageData);
                            break;
                        }
                        case "getRangeUsage": {
                            // Return usage stats for custom range
                            long startTime = call.argument("startTime");
                            long endTime = call.argument("endTime");
                            String usageData = getRangeUsageStats(startTime, endTime);
                            result.success(usageData);
                            break;
                        }
                        case "hasUsagePermission": {
                            boolean hasPermission = hasUsageStatsPermission(this);
                            result.success(hasPermission);
                            break;
                        }
                        case "openUsageSettings": {
                            openUsageAccessSettings();
                            result.success(null);
                            break;
                        }
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    // ---------------------------
    //  Permission Check Methods
    // ---------------------------

    /**
     * Checks if this app has Usage Stats permission.
     */
    private static boolean hasUsageStatsPermission(Context context) {
        AppOpsManager appOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
        int mode = appOps.checkOpNoThrow("android:get_usage_stats",
                android.os.Process.myUid(),
                context.getPackageName());
        return mode == AppOpsManager.MODE_ALLOWED;
    }

    /**
     * Opens the Usage Access settings screen so the user can grant permission.
     */
    private void openUsageAccessSettings() {
        Intent intent = new Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS);
        intent.setData(Uri.parse("package:" + getPackageName()));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    // ---------------------------
    //  Usage Stats Methods
    // ---------------------------

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

        UsageStatsManager usageStatsManager =
                (UsageStatsManager) getSystemService(Context.USAGE_STATS_SERVICE);
        List<UsageStats> stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY, startTime, endTime);

        if (stats == null || stats.isEmpty()) {
            return "No usage data available. (Check if permission is granted)";
        }

        // Collect usage data for relevant social media apps only
        HashMap<String, Long> appForegroundTimeMap = new HashMap<>();
        for (UsageStats usage : stats) {
            String packageName = usage.getPackageName();
            if (SOCIAL_MEDIA_CO2_MAP.containsKey(packageName)) {
                long totalForegroundTime = usage.getTotalTimeInForeground(); // ms
                // Accumulate in case of multiple intervals
                appForegroundTimeMap.put(
                        packageName,
                        appForegroundTimeMap.getOrDefault(packageName, 0L) + totalForegroundTime
                );
            }
        }

        // Build JSON-like string with usage in minutes and CO2
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

        // Return array of JSON objects in a string
        return "[" + String.join(",", usageResults) + "]";
    }
}
