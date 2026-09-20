import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_learning/interface/reviewer.dart';
import 'package:e_learning/interface/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

String getUserName() {
  final User? user = FirebaseAuth.instance.currentUser;

  return user?.displayName ?? 'Student';
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),

                    // ================= STREAK =================
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF58C900),
                          size: 26,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          '1',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ================= PROFILE HEADER =================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${getUserName()}!',
                                style: GoogleFonts.nunito(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                'Today is the day to keep on\nlearning',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  height: 1.3,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF8A8A8A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Profile Picture
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                            'assets/images/profile.png',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 55),

                    // ================= GAME CARDS =================
                    GameCard(
                      title: 'Mind Rush',
                      description:
                          'Choose the correct answer before\ntime runs out.',
                      backgroundColor: const Color(0xFFF96165),
                      imageBackgroundColor: const Color(0xFFFF8A8D),
                      imagePath: 'assets/images/mind_rush_icon.png',
                      imageHeight: 50,
                      onTap: () {
                        // Navigate to Mind Rush
                      },
                    ),

                    const SizedBox(height: 20),

                    GameCard(
                      title: 'Link Up',
                      description:
                          'Match terms with their correct\ndefinitions.',
                      backgroundColor: const Color(0xFFFFB12D),
                      imageBackgroundColor: const Color(0xFFFFCC66),
                      imagePath: 'assets/images/link_up_icon.png',
                      imageHeight: 50,
                      onTap: () {
                        // Navigate to Link Up
                      },
                    ),

                    const SizedBox(height: 20),

                    GameCard(
                      title: 'Word Forge',
                      description: 'Fill in the missing word or phrase.',
                      backgroundColor: const Color(0xFF7477F3),
                      imageBackgroundColor: const Color(0xFF9A9CF7),
                      imagePath: 'assets/images/word_forge_icon.png',
                      imageHeight: 50,
                      onTap: () {
                        // Navigate to Word Forge
                      },
                    ),

                    const SizedBox(height: 20),

                    GameCard(
                      title: 'Letter Quest',
                      description:
                          'Unscramble letters to find the\ncorrect term.',
                      backgroundColor: const Color(0xFF62D91E),
                      imageBackgroundColor: const Color(0xFF8BE557),
                      imagePath: 'assets/images/letter_quest_icon.png',
                      imageHeight: 100,
                      onTap: () {
                        // Navigate to Letter Quest
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ================= BOTTOM NAVIGATION =================
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // BOTTOM NAVIGATION
  // =============================================================

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 12),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(35),
      ),

      child: Row(
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            isActive: true,
            onTap: () {
              // Disabled because Home is already active
            },
          ),

          _buildNavItem(
            icon: Icons.menu_book_outlined,
            label: 'Reviewers',
            isActive: false,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewersPage()));
            },
          ),

          _buildNavItem(
            icon: Icons.workspace_premium_outlined,
            label: 'Awards',
            isActive: false,
            onTap: () {
              // Navigate to Awards
            },
          ),

          _buildNavItem(
            icon: Icons.account_circle_outlined,
            label: 'Profile',
            isActive: false,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isActive ? null : onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            // Highlight active button
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 30,
                color: isActive ? const Color(0xFF6064F4) : Colors.black,
              ),

              const SizedBox(height: 2),

              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive ? const Color(0xFF6064F4) : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// REUSABLE GAME CARD
// ===============================================================

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final Color imageBackgroundColor;
  final String imagePath;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.imageBackgroundColor,
    required this.imagePath,
    required this.onTap,
    required int imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              // IMAGE
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: imageBackgroundColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 14),

              // TITLE + DESCRIPTION
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 21,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ARROW
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0x99FFFFFF),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
