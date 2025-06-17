import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/health_metric.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:myapp/models/metric_type.dart';
import 'package:myapp/controllers/health_controller.dart';

class AddMetricScreen extends StatefulWidget {
  @override
  _AddMetricScreenState createState() => _AddMetricScreenState();
}

class _AddMetricScreenState extends State<AddMetricScreen> {
  double _value = 0.0;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _sleepDurationController = TextEditingController();
  final TextEditingController _sleepQualityController = TextEditingController();
  final TextEditingController _awakeningsController = TextEditingController();
  final Uuid _uuid = Uuid();
  bool _isLoading = false;
  MetricType? _selectedMetricType;
  int? _sleepDuration;
  int? _sleepQuality;
  DateTime? _bedtime;
  DateTime? _wakeUpTime;
  int? _awakenings;

  final HealthController healthController = Get.find();

  @override
  void dispose() {
    _valueController.dispose();
    _sleepDurationController.dispose();
    _sleepQualityController.dispose();
    _awakeningsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectBedtime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _bedtime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_bedtime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _bedtime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectWakeUpTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _wakeUpTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_wakeUpTime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _wakeUpTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Health Metric'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 16.0),
            DropdownButtonFormField<MetricType>(
              decoration: InputDecoration(
                labelText: 'Metric Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedMetricType,
              onChanged: (MetricType? newValue) {
                setState(() {
                  _selectedMetricType = newValue;
                });
              },
              items: MetricType.values.map((MetricType type) {
                return DropdownMenuItem<MetricType>(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
            ),
            SizedBox(height: 12.0),
            if (_selectedMetricType != MetricType.sleep) ...[
              TextField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _value = double.tryParse(value) ?? 0.0;
                },
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 12.0),
            ],
            if (_selectedMetricType == MetricType.sleep) ...[
              TextField(
                controller: _sleepDurationController,
                decoration: InputDecoration(labelText: 'Sleep Duration (minutes)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _sleepDuration = int.tryParse(value);
                },
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _sleepQualityController,
                decoration: InputDecoration(labelText: 'Sleep Quality (1-5)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _sleepQuality = int.tryParse(value);
                },
              ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bedtime: ${_bedtime != null ? DateFormat('yyyy-MM-dd HH:mm').format(_bedtime!) : 'Not set'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => _selectBedtime(context),
                    child: Text('Select Bedtime'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wake-up Time: ${_wakeUpTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(_wakeUpTime!) : 'Not set'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => _selectWakeUpTime(context),
                    child: Text('Select Wake-up Time'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _awakeningsController,
                decoration: InputDecoration(labelText: 'Number of Awakenings'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _awakenings = int.tryParse(value);
                },
              ),
              SizedBox(height: 12.0),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Date and Time: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Select Time'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (_selectedMetricType == null) {
                  Get.snackbar('Validation Error', 'Please select a metric type.',
                      snackPosition: SnackPosition.BOTTOM);
                } else if (_selectedMetricType != MetricType.sleep && _value <= 0) {
                  Get.snackbar('Validation Error', 'Please enter a valid positive value.',
                      snackPosition: SnackPosition.BOTTOM);
                } else {
                  _saveMetric();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Add Metric'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMetric() async {
    setState(() {
      _isLoading = true;
    });

    final id = _uuid.v4();
    final newMetric = HealthMetric(
      id: id,
      type: _selectedMetricType!,
      value: _value,
      date: _selectedDate,
      sleepDuration: _sleepDuration,
      sleepQuality: _sleepQuality,
      bedtime: _bedtime,
      wakeUpTime: _wakeUpTime,
      awakenings: _awakenings,
    );

    await healthController.addMetric(newMetric);

    _valueController.clear();
    _sleepDurationController.clear();
    _sleepQualityController.clear();
    _awakeningsController.clear();

    setState(() {
      _selectedMetricType = null;
      _selectedDate = DateTime.now();
      _value = 0.0;
      _sleepDuration = null;
      _sleepQuality = null;
      _bedtime = null;
      _wakeUpTime = null;
      _awakenings = null;
      _isLoading = false;
    });

    Get.back();
  }
}
