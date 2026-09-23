import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_learning/interface/login.dart';
import 'package:e_learning/interface/dashboard.dart';
import 'package:e_learning/interface/reviewer.dart';
import 'package:e_learning/services/auth_service.dart';
import '../widgets/current_user_profile_image.dart';

import 'account.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  Future<String> getUserName() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'Guest';
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    return data != null && data.containsKey('username')
        ? data['username'] as String
        : 'Guest';
  }

  String getUserEmail() {
    final User? user = FirebaseAuth.instance.currentUser;

    return user?.email ?? 'student@example.com';
  }

  Future<void> logoutUser() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to logout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // MAIN CONTENT
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 35),

                      // PROFILE TITLE
                      Text(
                        'Profile',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // PROFILE IMAGE
                      const CurrentUserProfileImage(radius: 50),

                      const SizedBox(height: 8),

                      // USERNAME
                      FutureBuilder<String>(
                        future: getUserName(),
                        builder: (context, snapshot) => Text(
                          snapshot.data ?? 'Guest',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      // EMAIL
                      Text(
                        getUserEmail(),
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: const Color(0xFF999999),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // STATISTICS
                      _buildStatistics(),

                      const SizedBox(height: 20),

                      // SETTINGS TITLE
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFD5D5D5),
                              thickness: 1.5,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Settings',
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          const Expanded(
                            child: Divider(
                              color: Color(0xFFD5D5D5),
                              thickness: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ACCOUNT
                      SettingsButton(
                        title: 'Account',
                        icon: Icons.account_box_outlined,
                        color: const Color(0xFF62D91E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),
                      // GAME HISTORY
                      SettingsButton(
                        title: 'Game History',
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFFFFB12D),
                        onTap: () {
                          // Navigate to Game History
                        },
                      ),

                      const SizedBox(height: 12),

                      // ABOUT STUDYQUEST
                      SettingsButton(
                        title: 'About StudyQuest',
                        icon: Icons.info_outline,
                        color: const Color(0xFF4FC3EF),
                        onTap: () {
                          // Navigate to About StudyQuest
                        },
                      ),

                      const SizedBox(height: 18),

                      // LOGOUT
                      ElevatedButton(
                        onPressed: logoutUser,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5C60),
                          foregroundColor: Colors.black,

                          minimumSize: const Size(80, 43),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),

                        child: Text(
                          'Logout',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),

            // BOTTOM NAVIGATION
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  // ============================================================
  Widget _buildStatistics() {
    return Container(
      width: double.infinity,
      height: 125,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),

      decoration: BoxDecoration(
        color: const Color(0xFFFFF2C5),
        borderRadius: BorderRadius.circular(17),
      ),

      child: Row(
        children: [
          const Expanded(
            child: StatisticItem(value: '50', label: 'Questions\nAnswered'),
          ),

          _divider(),

          const Expanded(
            child: StatisticItem(value: '5', label: 'Generated\nMaterials'),
          ),

          _divider(),

          const Expanded(
            child: StatisticItem(value: '5', label: 'Classes\nJoined'),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1.5, height: 75, color: const Color(0xFFD9CFA9));
  }

  // ============================================================
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 12),

      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),

      decoration: BoxDecoration(
        color: const Color(0xFF7477F3),
        borderRadius: BorderRadius.circular(35),
      ),

      child: Row(
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),

          _buildNavItem(
            icon: Icons.menu_book_outlined,
            label: 'Reviewers',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReviewersPage()),
              );
            },
          ),

          _buildNavItem(
            icon: Icons.class_outlined,
            label: 'Classes',
            isActive: false,
            onTap: () {
              // Navigate to Classes
            },
          ),

          _buildNavItem(
            icon: Icons.account_circle,
            label: 'Profile',
            isActive: true,
            onTap: () {},
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
        // Active page cannot be clicked
        onTap: isActive ? null : onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          padding: const EdgeInsets.symmetric(vertical: 6),

          decoration: BoxDecoration(
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

// ================================================================
// STATISTIC ITEM
// ================================================================

class StatisticItem extends StatelessWidget {
  final String value;
  final String label;

  const StatisticItem({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFF454D),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 11,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// SETTINGS BUTTON
// ================================================================

class SettingsButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SettingsButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),

        child: Container(
          width: double.infinity,
          height: 55,

          padding: const EdgeInsets.symmetric(horizontal: 18),

          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),

          child: Row(
            children: [
              Icon(icon, size: 26, color: Colors.white),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 29,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
