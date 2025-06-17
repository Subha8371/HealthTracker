import '../models/health_metric.dart';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';

class HealthDataService extends ChangeNotifier {
  HealthDataService._privateConstructor();

  // Create a static final instance
  static final HealthDataService _instance = HealthDataService._privateConstructor();

  // Provide a factory constructor to access the instance
  static HealthDataService get instance {
    return _instance;
  }

  late final DatabaseHelper _dbHelper;
  final ValueNotifier<List<HealthMetric>> _notifier = ValueNotifier<List<HealthMetric>>([]);

  Future<void> addMetric(HealthMetric metric) async {
    await _dbHelper.insertMetric(metric);
    await fetchMetrics(); // Fetch updated data from the database and notify listeners
  }

  // Public method to get metrics, primarily used by the controller to initially load data
  Future<List<HealthMetric>> getMetrics() async => _dbHelper.getMetrics();

  // Initialize the database helper after the instance is created
  Future<void> init() async {
    _dbHelper =await DatabaseHelper.instance();
  }

  Future<void> fetchMetrics() async {
    _notifier.value = await _dbHelper.getMetrics();
  }

  // Add a public getter for the ValueNotifier
  ValueNotifier<List<HealthMetric>> get notifier => _notifier;
}