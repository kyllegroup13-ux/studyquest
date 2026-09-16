import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_learning/interface/startup_one.dart';
import 'package:e_learning/interface/startup_three.dart';

class StartUpTwo extends StatefulWidget {
  const StartUpTwo({super.key});

  @override
  State<StartUpTwo> createState() => _StartUpTwoState();
}

class _StartUpTwoState extends State<StartUpTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBBF24),
      body: Stack(
        children: [
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/startup_image_2.png'),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    child: Text(
                      'Answer questions, earn rewards, and challenge yourself while learning.',
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

          // Bottom buttons
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
                            const StartUp(),
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
                            const StartupThree(),
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
                  color: const Color(0xFF58CC02),
                  minWidth: 100,
                  height: 56,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
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
