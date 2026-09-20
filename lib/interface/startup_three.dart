import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_learning/interface/login.dart';
import 'package:e_learning/interface/startup_two.dart';


class StartupThree extends StatefulWidget {
  const StartupThree({super.key});

  @override
  State<StartupThree> createState() => _StartupThreeState();
}

class _StartupThreeState extends State<StartupThree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEF4444),
      body: Stack(
        children: [
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/startup_image_3.png',
                  height: 300,
                  width: 300,
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    child: Text(
                      'Let AI transform your materials into fun games and make studying more engaging.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom-right button
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const StartUpTwo(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeIn,
                              );

                              return FadeTransition(
                                opacity: curvedAnimation,
                                child: child,
                              );
                            },

                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  color: const Color(0xFF58CC02),
                  minWidth: 100,
                  height: 56,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const LoginPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              );

                              return FadeTransition(
                                opacity: curvedAnimation,
                                child: child,
                              );
                            },

                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  color: const Color(0xFFFFD54F),
                  minWidth: 100,
                  height: 56,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.nunito(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
