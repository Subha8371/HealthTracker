import 'dart:convert';
import 'package:http/http.dart' as http;
import 'gemini_api_key.dart';
import '../models/health_metric.dart';
import '../models/metric_type.dart';

class GeminiApiService {
  // Try the latest Gemini 1.5 model endpoint
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  Future<String?> getHealthTip(String userInput) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'Give a health tip based on this input: $userInput'
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Gemini API returns the generated text in this path
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No tip found.';
    } else {
      return 'Failed to get tip: ${response.statusCode}';
    }
  }

  // Helper to get latest metric of each type
  List<HealthMetric> getLatestMetrics(List<HealthMetric> metrics) {
    final Map<MetricType, HealthMetric> latest = {};
    for (final m in metrics) {
      if (!latest.containsKey(m.type) || m.date.isAfter(latest[m.type]!.date)) {
        latest[m.type] = m;
      }
    }
    return latest.values.toList();
  }

  Future<String?> getHealthTipFromMetrics(List<HealthMetric> metrics) async {
    final latestMetrics = getLatestMetrics(metrics);
    // Convert metrics to a readable string for the prompt
    String input = latestMetrics.map((m) {
      String details = '${m.type.displayName}: ${m.value} ${m.type.unit} on ${m.date.toIso8601String()}';
      if (m.age != null) details += ', Age: ${m.age}';
      if (m.height != null) details += ', Height: ${m.height} cm';
      if (m.gender != null) details += ', Gender: ${m.gender}';
      if (m.activityLevel != null) details += ', Activity Level: ${m.activityLevel}';
      if (m.diet != null) details += ', Diet: ${m.diet}';
      if (m.type == MetricType.sleep) {
        details += ', Sleep Duration: ${m.sleepDuration ?? "-"} min, Quality: ${m.sleepQuality ?? "-"}/5, Awakenings: ${m.awakenings ?? "-"}';
      }
      return details;
    }).join('; ');
    return getHealthTip(input);
  }
}
