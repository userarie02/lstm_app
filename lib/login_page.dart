import 'package:flutter/material.dart';
import 'homepage.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String hardcodedEmail = "gama17@gmail.com";
  final String hardcodedPassword = "moldshield";

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_emailController.text == hardcodedEmail &&
        _passwordController.text == hardcodedPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Login successful!",
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'WorkSans',
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: Color(0xFF5bba6f),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Invalid email or password.",
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'WorkSans',
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: Color(0xFFe6ccb2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 500,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _CurvedPainter()),
                  ),
                  Positioned(
                    top: 184,
                    left: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Sign in",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'WorkSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CURVED CONTENTS
            Transform.translate(
              offset: const Offset(0, -103),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        focusNode: _emailFocus,
                        controller: _emailController,
                        cursorColor: const Color(0xFFddb892),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color:
                                _emailFocus.hasFocus
                                    ? const Color(0xFFddb892)
                                    : Colors.grey,
                          ),
                          hintText: "user@email.com",
                          hintStyle: const TextStyle(fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        focusNode: _passwordFocus,
                        controller: _passwordController,
                        cursorColor: const Color(0xFFddb892),
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color:
                                _passwordFocus.hasFocus
                                    ? const Color(0xFFe6ccb2)
                                    : Colors.grey,
                          ),
                          hintText: "Enter your password",
                          hintStyle: const TextStyle(fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 41),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5bba6f),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'WorkSans',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    //SIGN-UP OPTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Don't have an Account?",
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                                pageBuilder: (_, __, ___) => const SignUpPage(),
                                transitionsBuilder: (_, animation, __, child) {
                                  const begin = Offset(
                                    0,
                                    1,
                                  ); // ADJUST ANIMATION
                                  const end = Offset.zero;
                                  final tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: Curves.easeInOut));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }
}

class _CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double shiftY = -72;

    // Define the curved path
    Path path = Path();
    path.moveTo(0, size.height * 0.52 - shiftY);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3 - shiftY,
      size.width * 0.5,
      size.height * 0.5 - shiftY,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7 - shiftY,
      size.width,
      size.height * 0.4 - shiftY,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    // Clip canvas to the curved path
    canvas.save();
    canvas.clipPath(path);

    // Load and paint the image
    final imageProvider = AssetImage('assets/start_bg1.jpg');

    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            final image = info.image;

            // Draw the background image
            paintImage(
              canvas: canvas,
              image: image,
              rect: Rect.fromLTWH(0, -57, size.width, size.height),
              fit: BoxFit.cover,
            );

            // Draw the dark green overlay
            final overlayPaint =
                Paint()..color = const Color.fromARGB(195, 3, 40, 22);
            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              overlayPaint,
            );
          }),
        );

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
