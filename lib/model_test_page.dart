import 'package:flutter/material.dart';
import '../csv_loader.dart'; // adjust path if needed
import '../ml_predictor.dart'; // adjust path if needed

class ModelTestPage extends StatefulWidget {
  const ModelTestPage({super.key});

  @override
  State<ModelTestPage> createState() => _ModelTestPageState();
}

class _ModelTestPageState extends State<ModelTestPage> {
  final csvLoader = CSVLoader();
  final mlPredictor = MLPredictor();

  String resultText = 'Press "Evaluate Model" to test the TFLite model.';
  bool isLoading = false;

  Future<void> evaluateModel() async {
    setState(() {
      isLoading = true;
      resultText = 'Running evaluation...';
    });

    try {
      await mlPredictor.loadModel();
      await csvLoader.loadScalerConfig();

      final fullBuffer = await csvLoader.loadFullBuffer();
      const int windowSize = 60;

      if (fullBuffer.length < windowSize + 1) {
        setState(() {
          resultText = '❌ Not enough data to evaluate (need > 60 rows).';
          isLoading = false;
        });
        return;
      }

      double totalTempError = 0;
      double totalHumidityError = 0;
      double totalVOCError = 0;
      double totalPM25Error = 0;
      double totalPM10Error = 0;
      int count = 0;

      for (int i = 0; i <= fullBuffer.length - windowSize - 1; i++) {
        final inputWindow = fullBuffer.sublist(i, i + windowSize);
        final groundTruth = fullBuffer[i + windowSize];

        final preprocessed = csvLoader.preprocessBuffer(inputWindow);
        final prediction = await mlPredictor.predict(preprocessed);

        final predictedTemp =
            prediction[1] *
                (csvLoader.max['Temperature']! -
                    csvLoader.min['Temperature']!) +
            csvLoader.min['Temperature']!;
        final predictedHumidity =
            prediction[0] *
                (csvLoader.max['Humidity']! - csvLoader.min['Humidity']!) +
            csvLoader.min['Humidity']!;
        final predictedVOC =
            prediction[2] * (csvLoader.max['VOC']! - csvLoader.min['VOC']!) +
            csvLoader.min['VOC']!;
        final predictedPM25 =
            prediction[3] *
                (csvLoader.max['PM2.5']! - csvLoader.min['PM2.5']!) +
            csvLoader.min['PM2.5']!;
        final predictedPM10 =
            prediction[4] * (csvLoader.max['PM10']! - csvLoader.min['PM10']!) +
            csvLoader.min['PM10']!;

        final actualTemp = groundTruth.temperature;
        final actualHumidity = groundTruth.humidity;
        final actualVOC = groundTruth.voc;
        final actualPM25 = groundTruth.pm25;
        final actualPM10 = groundTruth.pm10;

        totalTempError += (predictedTemp - actualTemp).abs();
        totalHumidityError += (predictedHumidity - actualHumidity).abs();
        totalVOCError += (predictedVOC - actualVOC).abs();
        totalPM25Error += (predictedPM25 - actualPM25).abs();
        totalPM10Error += (predictedPM10 - actualPM10).abs();

        count++;
      }

      final maeTemp = totalTempError / count;
      final maeHumidity = totalHumidityError / count;
      final maeVOC = totalVOCError / count;
      final maePM25 = totalPM25Error / count;
      final maePM10 = totalPM10Error / count;

      setState(() {
        resultText = '''
✅ Model Evaluation Complete
Samples Evaluated: $count

📊 MAE (Mean Absolute Error):
• Temperature: ${maeTemp.toStringAsFixed(2)} °C
• Humidity:    ${maeHumidity.toStringAsFixed(2)} %
• VOC:         ${maeVOC.toStringAsFixed(2)} ppm
• PM2.5:       ${maePM25.toStringAsFixed(2)} µg/m³
• PM10:        ${maePM10.toStringAsFixed(2)} µg/m³
''';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        resultText = '❌ Evaluation failed: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Evaluation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('Evaluate Model'),
              onPressed: isLoading ? null : evaluateModel,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const LinearProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(resultText, style: const TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
