import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ml_app/csv_loader.dart';
import 'package:ml_app/ml_predictor.dart';
import 'package:intl/intl.dart';

import 'alldata_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeMainContent(), // Original home content
    Container(),
    SettingsPagePlaceholder(), // Placeholder settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 247, 238),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 340),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },

        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(left: 16, right: 16, bottom: 29),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 12, 12, 12),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(52),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 68,
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white70, size: 20),
              ),

              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                selectedLabelStyle: const TextStyle(
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w400,
                ),

                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w400,
                ),

                // ITEMS OF NAVBAR
                items: [
                  BottomNavigationBarItem(
                    icon:
                        _currentIndex == 0
                            ? _buildSelectedIcon(Icons.home_outlined)
                            : const Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon:
                        _currentIndex == 1
                            ? _buildSelectedIcon(
                              Icons.stacked_line_chart_outlined,
                            )
                            : const Icon(Icons.stacked_line_chart_outlined),
                    label: 'Data',
                  ),
                  BottomNavigationBarItem(
                    icon:
                        _currentIndex == 2
                            ? _buildSelectedIcon(Icons.tune_outlined)
                            : const Icon(Icons.tune_outlined),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildSelectedIcon(IconData icon) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: const BoxDecoration(
      color: Color(0xFF2A9134),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );
}

class HomeMainContent extends StatefulWidget {
  const HomeMainContent({super.key});

  @override
  State<HomeMainContent> createState() => _HomeMainContentState();
}

class _HomeMainContentState extends State<HomeMainContent> {
  final csvLoader = CSVLoader();
  final mlPredictor = MLPredictor();

  String tempValue = '...';
  String humidValue = '...';
  String timeValue = '...';
  String dateValue = '...';
  String statusText = '...';
  String lastUpdatedText = 'Last Updated ...';

  Color statusColor = const Color(0xFF137547);
  IconData statusIcon = Icons.check_circle_outline;

  String pm25Value = '...';
  String pm10Value = '...';
  String vocValue = '...';

  @override
  void initState() {
    super.initState();
    loadPrediction();
  }

  void loadPrediction() async {
    try {
      await mlPredictor.loadModel();
      await csvLoader.loadScalerConfig(); // SCALER

      final buffer = await csvLoader.loadAndPrepareBuffer();
      final preprocessed = csvLoader.preprocessBuffer(buffer);

      if (preprocessed.length == 60) {
        final prediction = await mlPredictor.predict(preprocessed);

        final minTemp = csvLoader.min['Temperature']!;
        final maxTemp = csvLoader.max['Temperature']!;
        final minHumid = csvLoader.min['Humidity']!;
        final maxHumid = csvLoader.max['Humidity']!;
        final minVOC = csvLoader.min['VOC']!;
        final maxVOC = csvLoader.max['VOC']!;
        final minPM25 = csvLoader.min['PM2.5']!;
        final maxPM25 = csvLoader.max['PM2.5']!;
        final minPM10 = csvLoader.min['PM10']!;
        final maxPM10 = csvLoader.max['PM10']!;

        final predictedHumidity =
            prediction[0] * (maxHumid - minHumid) + minHumid;
        final predictedTemp = prediction[1] * (maxTemp - minTemp) + minTemp;
        final predictedVOC = prediction[2] * (maxVOC - minVOC) + minVOC;
        final predictedPM25 = prediction[3] * (maxPM25 - minPM25) + minPM25;
        final predictedPM10 = prediction[4] * (maxPM10 - minPM10) + minPM10;

        final latestDate = buffer.last.date;

        // LAST UPDATED DATE LOGIC
        final formattedTime = DateFormat.jm().format(latestDate);
        final formattedDate = DateFormat(
          'd MMM yyyy',
        ).format(latestDate); // 5 Aug 2025

        // STATUS LOGIC
        String newStatus;
        Color newStatusColor;

        // ACTUAL SENSOR VALUES FROM CSV
        final actualTemp = buffer.last.temperature;
        final actualHumidity = buffer.last.humidity;
        final actualVOC = buffer.last.voc;
        final actualPM25 = buffer.last.pm25;
        final actualPM10 = buffer.last.pm10;

        // FUNCTION TO CHECK IF VALUES ARE CLOSE ENOUGH
        bool isCloseEnough(
          double predicted,
          double actual,
          double tolerancePercent,
        ) {
          final diff = (predicted - actual).abs();
          final threshold = (tolerancePercent / 100) * actual;
          return diff <= threshold;
        }

        // COMPARISON RESULTS
        final isTempClose = isCloseEnough(predictedTemp, actualTemp, 10);
        final isHumidityClose = isCloseEnough(
          predictedHumidity,
          actualHumidity,
          10,
        );
        final isVOCClose = isCloseEnough(predictedVOC, actualVOC, 10);
        final isPM25Close = isCloseEnough(predictedPM25, actualPM25, 10);
        final isPM10Close = isCloseEnough(predictedPM10, actualPM10, 10);

        // COUNT HOW MANY FEATURES MATCH
        final closeCount =
            [
              isTempClose,
              isHumidityClose,
              isVOCClose,
              isPM25Close,
              isPM10Close,
            ].where((match) => match).length;

        if (closeCount >= 3) {
          newStatus = 'High Risk';
          newStatusColor = Colors.red;
          statusIcon = Icons.warning_amber_rounded;
        } else {
          newStatus = 'False Alarm';
          newStatusColor = const Color(0xFF137547);
          statusIcon = Icons.check_circle_outline;
        }

        if (kDebugMode) {
          print('✅ Corrected Prediction vs Actual:');
        }
        if (kDebugMode) {
          print('Temperature: $predictedTemp vs ${buffer.last.temperature}');
        }
        if (kDebugMode) {
          print('Humidity: $predictedHumidity vs ${buffer.last.humidity}');
        }
        if (kDebugMode) {
          print('VOC: $predictedVOC vs ${buffer.last.voc}');
        }
        if (kDebugMode) {
          print('PM2.5: $predictedPM25 vs ${buffer.last.pm25}');
        }
        if (kDebugMode) {
          print('PM10: $predictedPM10 vs ${buffer.last.pm10}');
        }

        setState(() {
          tempValue = '${predictedTemp.toStringAsFixed(1)}°C';
          humidValue = '${predictedHumidity.toStringAsFixed(1)}%';
          timeValue = DateFormat.jm().format(latestDate);
          dateValue = DateFormat.yMd().format(latestDate);
          statusText = newStatus;
          lastUpdatedText = 'Last Updated $formattedTime, $formattedDate';
          statusColor = newStatusColor;
          statusIcon = statusIcon;

          pm25Value = '${predictedPM25.toStringAsFixed(1)} µg/m³';
          pm10Value = '${predictedPM10.toStringAsFixed(1)} µg/m³';
          vocValue = '${predictedVOC.toStringAsFixed(1)} ppm';
        });
      } else {
        if (kDebugMode) {
          print('Not enough readings for prediction.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Prediction Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 63),

            // Top Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hi User!',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Check your mold risk today.',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/mainlogo_mirrored.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Stack(
              clipBehavior: Clip.none,
              children: [
                // OVERLAPPED WHITE AND GREEN CONTAINERS
                Positioned(
                  bottom: -43,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      widthFactor: 1,

                      child: Material(
                        elevation: 3.5,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        color: Colors.transparent,
                        child: Container(
                          height: 62,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A9134),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.0, top: 17),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lastUpdatedText,
                                style: TextStyle(
                                  fontFamily: 'WorkSans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // WHITE CONTAINER
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Baguio',
                                  style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.expand_more),
                          ],
                        ),
                        const SizedBox(height: 3),

                        Divider(color: Colors.grey, thickness: 0.8),

                        // STATUS OF MOLDS
                        const SizedBox(height: 9),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 60,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontFamily: 'WorkSans',
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                  fontSize: 23,
                                ),
                              ),
                            ),

                            // ICON SYMBOLIZING LOW MOLD RISK
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Icon(
                                statusIcon,
                                size: 37,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 78),

            // DATA CONTAINER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TITLE
                      const Text(
                        'Sensor Data',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      // REFRESH
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Color(0xFF137547),
                          size: 22,
                        ),
                        onPressed: () {
                          // Refresh the sensor data
                          loadPrediction();
                        },
                      ),
                    ],
                  ),

                  const Divider(color: Colors.grey, thickness: 0.7),
                  const SizedBox(height: 12),

                  // FIRST 2 ROWS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TEMP CONTAINER
                      Container(
                        width: 150,
                        height: 155,
                        decoration: BoxDecoration(
                          color: const Color(0xFF90BE6D),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Temperature',
                                style: TextStyle(
                                  fontFamily: 'WorkSans',
                                  fontSize: 14.5,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // VALUE
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                tempValue,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 33,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Bottom: Time, Date, Label
                            Column(
                              children: [
                                SizedBox(height: 5),
                                Text(
                                  timeValue,
                                  style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color.fromARGB(221, 255, 255, 255),
                                  ),
                                ),

                                Text(
                                  dateValue,
                                  style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // HUMID CONTAINER
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFF43AA8B),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Humidity',
                                style: TextStyle(
                                  fontFamily: 'WorkSans',
                                  color: Colors.black87,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // VALUE
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                humidValue,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 33,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(height: 5),
                                Text(
                                  timeValue,
                                  style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color.fromARGB(221, 255, 255, 255),
                                  ),
                                ),

                                Text(
                                  dateValue,
                                  style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // See All button with icon
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 1),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 400,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      AllDataPage(
                                        temp: tempValue,
                                        humid: humidValue,
                                        pm25: pm25Value,
                                        pm10: pm10Value,
                                        voc: vocValue,
                                        time: timeValue,
                                        date: dateValue,
                                      ),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'See all',
                              style: TextStyle(
                                fontFamily: 'WorkSans',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF137547),
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ), // Spacing between the text and the icon
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: Color(0xFF137547),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class SettingsPagePlaceholder extends StatelessWidget {
  const SettingsPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Page', style: TextStyle(fontSize: 18)),
    );
  }
}
