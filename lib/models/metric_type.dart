enum MetricType {
  weight,
  steps,
  heartRate,
  calories,
  distance,
  sleep,
}

extension MetricTypeDetails on MetricType {
  String get displayName {
    switch (this) {
      case MetricType.weight:
        return 'Weight';
      case MetricType.steps:
        return 'Steps';
      case MetricType.heartRate:
        return 'Heart Rate';
      case MetricType.calories:
        return 'Calories';
      case MetricType.distance:
        return 'Distance';
      case MetricType.sleep:
        return 'Sleep';
    }
  }

  String get unit {
    switch (this) {
      case MetricType.weight:
        return 'kg';
      case MetricType.steps:
        return 'steps';
      case MetricType.heartRate:
        return 'bpm';
      case MetricType.calories:
        return 'kcal';
      case MetricType.distance:
        return 'km';
      case MetricType.sleep:
        return '';
    }
  }
}
