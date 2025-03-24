import 'package:flutter/material.dart';
import 'login_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/start_bg1.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight, // Keeps image to the right
            ),
          ),

          // Dark Green Overlay
          Positioned.fill(
            child: Container(
              color: Color.fromARGB(255, 5, 39, 23).withAlpha(185),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 95),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TITLE
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      'Welcome to MoldShield!',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontSize: 36, // Keeps text large
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 13),

                  // TAGLINE
                  const Text(
                    'Detect and Prevent Mold Growth\n'
                    'for a Healthier Indoor Environment.',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity, // Makes button take full width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5bba6f),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
