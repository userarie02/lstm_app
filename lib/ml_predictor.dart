import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class MLPredictor {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/lstm_model_day.tflite');
  }

  Future<List<double>> predict(List<List<double>> preprocessedInput) async {
    final flatInput = Float32List.fromList(
      preprocessedInput.expand((e) => e).toList(),
    );

    // Allocate memory for outputs
    final outputCurrent = List.filled(5, 0.0).reshape([1, 5]);
    final outputFuture = List.filled(5, 0.0).reshape([1, 5]);

    // Run inference (input shape: [1, 60, 8])
    _interpreter.runForMultipleInputs(
      [
        flatInput.reshape([1, 12, 8]),
      ],
      {0: outputCurrent, 1: outputFuture},
    );

    return outputFuture[0]; // Output for future prediction
  }
}
