import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:intl/intl.dart';

class SensorReading {
  final DateTime date;
  final double temperature;
  final double humidity;
  final double voc;
  final double pm25;
  final double pm10;

  SensorReading(
    this.date,
    this.temperature,
    this.humidity,
    this.voc,
    this.pm25,
    this.pm10,
  );
}

class CSVLoader {
  final List<SensorReading> _buffer = [];

  final int bufferSize = 60;

  // Stores loaded min/max values from JSON config
  final Map<String, double> min = {};
  final Map<String, double> max = {};

  // BOTH FORMAT
  DateTime parseFlexibleDate(String input) {
    try {
      return DateFormat("M/d/yyyy H:mm").parseStrict(input);
    } catch (_) {
      return DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(input);
    }
  }

  // ✅ Load scaler_config.json min/max into _min/_max
  Future<void> loadScalerConfig() async {
    final rawJson = await rootBundle.loadString('assets/scaler_config.json');
    final Map<String, dynamic> data = jsonDecode(rawJson);

    final features = List<String>.from(data['features']);
    final mins = List<double>.from(data['min']);
    final maxs = List<double>.from(data['max']);

    for (int i = 0; i < features.length; i++) {
      min[features[i]] = mins[i];
      max[features[i]] = maxs[i];
    }
  }

  Future<List<SensorReading>> loadAndPrepareBuffer() async {
    final rawData = await rootBundle.loadString('assets/sensor_readings.csv');
    final lines = const LineSplitter().convert(rawData).skip(1); // skip header

    for (final line in lines) {
      final parts = line.split(',');

      final date = parseFlexibleDate(parts[0]);
      final humidity = double.tryParse(parts[1]) ?? 0;
      final temperature = double.tryParse(parts[2]) ?? 0;
      final voc = double.tryParse(parts[3]) ?? 0;
      final pm25 = double.tryParse(parts[4]) ?? 0;
      final pm10 = double.tryParse(parts[5]) ?? 0;

      final reading = SensorReading(
        date,
        temperature,
        humidity,
        voc,
        pm25,
        pm10,
      );
      _buffer.add(reading);

      if (_buffer.length > bufferSize) {
        _buffer.removeAt(0);
      }
    }

    return _buffer;
  }

  List<List<double>> preprocessBuffer(List<SensorReading> buffer) {
    return buffer.map((reading) {
      final hour = reading.date.hour / 23.0;
      final dayOfWeek = reading.date.weekday % 7 / 6.0;
      final month = reading.date.month / 12.0;

      return [
        normalize(reading.humidity, min['Humidity']!, max['Humidity']!),
        normalize(
          reading.temperature,
          min['Temperature']!,
          max['Temperature']!,
        ),
        normalize(reading.voc, min['VOC']!, max['VOC']!),
        normalize(reading.pm25, min['PM2.5']!, max['PM2.5']!),
        normalize(reading.pm10, min['PM10']!, max['PM10']!),
        hour,
        dayOfWeek,
        month,
      ];
    }).toList();
  }

  double normalize(double value, double min, double max) {
    return (value - min) / (max - min);
  }

  Future<List<SensorReading>> loadFullBuffer() async {
    final rawData = await rootBundle.loadString(
      'assets/sensor_readings_120.csv',
    );
    final lines = const LineSplitter().convert(rawData).skip(1); // Skip header

    final List<SensorReading> fullBuffer = [];

    for (final line in lines) {
      final parts = line.split(',');

      final date = parseFlexibleDate(parts[0]);
      final humidity = double.tryParse(parts[2]) ?? 0;
      final temperature = double.tryParse(parts[1]) ?? 0;
      final voc = double.tryParse(parts[3]) ?? 0;
      final pm25 = double.tryParse(parts[4]) ?? 0;
      final pm10 = double.tryParse(parts[5]) ?? 0;

      fullBuffer.add(
        SensorReading(date, temperature, humidity, voc, pm25, pm10),
      );
    }

    return fullBuffer;
  }
}
