import 'package:flutter/material.dart';
import 'homepage.dart';

class AllDataPage extends StatelessWidget {
  final String temp;
  final String humid;
  final String pm25;
  final String pm10;
  final String voc;
  final String time;
  final String date;

  const AllDataPage({
    super.key,
    required this.temp,
    required this.humid,
    required this.pm25,
    required this.pm10,
    required this.voc,
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Transform.translate(
              offset: const Offset(0, -340),
              child: Image.asset('assets/start_bg1.jpg', fit: BoxFit.cover),
            ),
          ),

          // DARK GREEN OVERLAY
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 5, 39, 23).withAlpha(185),
            ),
          ),

          Positioned(
            top: screenHeight * 0.148,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Sensor Data',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 255, 255, 255),
                  ),
                ),
                Positioned(
                  left: 59,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 19,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 350),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const HomePage(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(-1.0, 0.0),
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
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // White Container at Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: 0.728,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.6,
                  maxHeight: screenHeight * 0.75,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      DataBox(
                        label: 'Temperature',
                        value: temp,
                        color: const Color(0xFF90BE6D),
                        time: time,
                        date: date,
                      ),
                      DataBox(
                        label: 'Humidity',
                        value: humid,
                        color: const Color(0xFF43AA8B),
                        time: time,
                        date: date,
                      ),
                      DataBox(
                        label: 'PM2.5',
                        value: pm25,
                        color: Color(0xFFF9C74F),
                        time: time,
                        date: date,
                        fontSize: 28,
                      ),
                      DataBox(
                        label: 'PM10',
                        value: pm10,
                        color: Color(0xFFF8961E),
                        time: time,
                        date: date,
                        fontSize: 27,
                      ),
                      DataBox(
                        label: 'VOC',
                        value: voc,
                        color: Color(0xFF577590),
                        time: time,
                        date: date,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double? fontSize;
  final String time;
  final String date;

  const DataBox({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.fontSize,
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 157,
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 14.5,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: fontSize ?? 33,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 5),
                  Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color.fromARGB(221, 255, 255, 255),
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
