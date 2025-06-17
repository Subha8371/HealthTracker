import 'package:myapp/models/metric_type.dart';

class HealthMetric {
  String id;
  MetricType type; // Use MetricType enum
  double value;
  DateTime date;
  int? sleepDuration; // in minutes
  int? sleepQuality; // 1-5 scale
  DateTime? bedtime;
  DateTime? wakeUpTime;
  int? awakenings;

  HealthMetric({
    required this.id,
    required this.type,
    required this.value,
    required this.date,
    this.sleepDuration,
    this.sleepQuality,
    this.bedtime,
    this.wakeUpTime,
    this.awakenings,
  });

  // Optional: for future use with data storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last, // Store enum as string
      'value': value,
      'date': date.toIso8601String(),
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
      'bedtime': bedtime?.toIso8601String(),
      'wakeUpTime': wakeUpTime?.toIso8601String(),
      'awakenings': awakenings,
    };
  }

  // Optional: for future use with data storage
  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'],
      type: MetricType.values.firstWhere((e) => e.toString().split('.').last == json['type'] as String),
      value: json['value'],
      date: DateTime.parse(json['date']),
      sleepDuration: json['sleepDuration'],
      sleepQuality: json['sleepQuality'],
      bedtime: json['bedtime'] != null ? DateTime.parse(json['bedtime']) : null,
      wakeUpTime: json['wakeUpTime'] != null ? DateTime.parse(json['wakeUpTime']) : null,
      awakenings: json['awakenings'],
    );
  }
}
