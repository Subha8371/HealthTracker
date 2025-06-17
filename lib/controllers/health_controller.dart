import 'package:get/get.dart';
import '../models/health_metric.dart';
import '../services/health_data_service.dart';
import '../services/database_helper.dart'; // Assuming DatabaseHelper is needed or used by HealthDataService

class HealthController extends GetxController {
  var _metrics = <HealthMetric>[].obs;
  final HealthDataService _healthDataService = HealthDataService.instance; // Initialize HealthDataService

  @override
  void onInit() {
    fetchMetrics();
    super.onInit(); // Call super.onInit() after fetching data
  }

  Future<void> fetchMetrics() async { // Make fetchMetrics asynchronous
    final fetchedList = await _healthDataService.getMetrics(); // Await the Future
    _metrics.assignAll(fetchedList);
  }

  Future<void> addMetric(HealthMetric metric) async { // Make addMetric asynchronous
    // Add data to your data source (e.g., HealthDataService)
    HealthDataService.instance.addMetric(metric);
    // Update the reactive list
    _metrics.add(metric);
  }

  List<HealthMetric> get metrics => _metrics.toList();

  }
