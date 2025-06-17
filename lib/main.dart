import 'package:flutter/material.dart';
import 'package:myapp/models/metric_type.dart';
import 'package:myapp/screens/add_metric_screen.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:myapp/services/health_data_service.dart';
import 'package:myapp/models/health_metric.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/health_controller.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Health Tracker', // Changed MaterialApp to GetMaterialApp
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
        ),
      ),
      debugShowCheckedModeBanner:
          false, // Changed MaterialApp to GetMaterialApp
      initialRoute: '/',
      routes: {
        '/':
            (context) =>
                HomeScreen(), // Keep routes for now, will transition to GetX routing later
        '/addMetric': (context) => AddMetricScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final HealthController healthController = Get.put(HealthController());
  final RxString dailySuggestion = ''.obs;

  String getDailyRoutineSuggestion(List<HealthMetric> metrics) {
    if (metrics.isEmpty) {
      return 'No data available. Add some health metrics to get personalized suggestions!';
    }

    final random = Random();
    List<String> suggestions = [];

    // Sleep suggestions
    final sleepMetrics = metrics.where((metric) => metric.type == MetricType.sleep).toList();
    if (sleepMetrics.isNotEmpty) {
      final latestSleep = sleepMetrics.last;
      if (latestSleep.sleepDuration != null && latestSleep.sleepDuration! < 420) {
        suggestions.add('Aim for a longer sleep tonight. Try to get at least 7 hours of restful sleep.');
      }
      if (latestSleep.sleepQuality != null && latestSleep.sleepQuality! < 3) {
        suggestions.add('Improve your sleep quality. Consider creating a relaxing bedtime routine or optimizing your sleep environment.');
      }
      if (latestSleep.awakenings != null && latestSleep.awakenings! > 2) {
        suggestions.add('Try to reduce awakenings, consider relaxing before bed.');
      }
    }

    // Add more suggestions based on other metric types here
    //For example
    // Activity suggestions (assuming you have an activity metric)
    // final activityMetrics = metrics.where((metric) => metric.type == MetricType.activity).toList();
    //if (activityMetrics.isNotEmpty) {
    // final latestActivity = activityMetrics.last;
    // if (latestActivity.value < 3000) { // Example: less than 3000 steps
    //suggestions.add('Increase your daily activity. Take a walk, try some stretching, or dance to your favorite music.');
    //}
    //}

    if (suggestions.isEmpty) {
      return 'Maintain your current healthy habits!';
    } else {
      // Return a random suggestion from the list
      return 'Here is a tip for your daily routine:' +
      suggestions[random.nextInt(suggestions.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Health Overview')),
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start

        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Health Data:',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0), // Added spacing
          Expanded(
            child: Obx(
              // Use Obx to observe changes in the healthController.metrics list
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Apply padding to the ListView
                itemCount:
                    healthController
                        .metrics
                        .length, // Access metrics from the controller
                itemBuilder: (context, index) {
                  final metric = healthController.metrics[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.type == MetricType.sleep
                                ? 'Sleep Data'
                                : '${metric.type.displayName}: ${metric.value} ${metric.type.unit}',
                            style: textTheme.titleMedium,
                          ),
                          if (metric.type == MetricType.sleep) ...[
                            if (metric.bedtime != null) Text('Bedtime: ${DateFormat('yyyy-MM-dd HH:mm').format(metric.bedtime!)}'),
                            if (metric.wakeUpTime != null) Text('Wake-up Time: ${DateFormat('yyyy-MM-dd HH:mm').format(metric.wakeUpTime!)}'),
                            if (metric.sleepDuration != null) Text('Sleep Duration: ${metric.sleepDuration} minutes'),
                            if (metric.sleepQuality != null) Text('Sleep Quality: ${metric.sleepQuality}/5'),
                            if (metric.awakenings != null) Text('Number of Awakenings: ${metric.awakenings}'),
                          ] else
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(metric.date),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                dailySuggestion.value = getDailyRoutineSuggestion(healthController.metrics);
              },
              child: const Center(
                child: Text('Get Daily Health Tip'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Daily Suggestion:',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(() => Text(
                  dailySuggestion.value,
                  style: textTheme.bodyLarge,
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Use Get.toNamed for GetX routing
                Get.toNamed('/addMetric');
              },
              child: Center(
                child: Text('Add Health Metric'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
