import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_learning/interface/dashboard.dart';
import 'package:e_learning/interface/profile.dart';

class ReviewersPage extends StatefulWidget {
  const ReviewersPage({super.key});

  @override
  State<ReviewersPage> createState() => _ReviewersPageState();
}

class _ReviewersPageState extends State<ReviewersPage> {
  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'Mind Rush',
    'Link Up',
    'Word Forge',
    'Letter Quest',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ================= TITLE =================
                  Text(
                    'Reviewers',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ================= FILTERS =================
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                      ),
                      itemCount: filters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final filter = filters[index];

                        return _buildFilterButton(filter);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= REVIEWER LIST =================
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                      ),
                      children: [
                        ReviewerCard(
                          title: 'Topic',
                          game: 'Mind Rush',
                          imagePath:
                              'assets/images/notebook_icon.png',
                          onTap: () {
                            // Open reviewer
                          },
                          onDelete: () {
                            // Delete reviewer
                          },
                        ),

                        const SizedBox(height: 18),

                        ReviewerCard(
                          title: 'Topic',
                          game: 'Mind Rush',
                          imagePath:
                              'assets/images/notebook_icon.png',
                          onTap: () {},
                          onDelete: () {},
                        ),

                        const SizedBox(height: 18),

                        ReviewerCard(
                          title: 'Topic',
                          game: 'Mind Rush',
                          imagePath:
                              'assets/images/notebook_icon.png',
                          onTap: () {},
                          onDelete: () {},
                        ),

                        const SizedBox(height: 18),

                        ReviewerCard(
                          title: 'Topic',
                          game: 'Mind Rush',
                          imagePath:
                              'assets/images/notebook_icon.png',
                          onTap: () {},
                          onDelete: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= BOTTOM NAV =================
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // FILTER BUTTON
  // =============================================================

  Widget _buildFilterButton(String filter) {
    final bool isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: isSelected
          ? null
          : () {
              setState(() {
                selectedFilter = filter;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 5,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1)
              : Colors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: const Color(0xFF6366F1),
            width: 2,
          ),
        ),

        child: Center(
          child: Text(
            filter,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF777777),
            ),
          ),
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

      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 6,
      ),

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
            },
          ),

          _buildNavItem(
            icon: Icons.menu_book_outlined,
            label: 'Reviewers',
            isActive: true,
            onTap: () {},
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

  // =============================================================
  // NAVIGATION ITEM
  // =============================================================

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        // Disable current page
        onTap: isActive ? null : onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.transparent,

            borderRadius: BorderRadius.circular(30),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 30,
                color: isActive
                    ? const Color(0xFF6064F4)
                    : Colors.black,
              ),

              const SizedBox(height: 2),

              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? const Color(0xFF6064F4)
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// REVIEWER CARD
// =================================================================

class ReviewerCard extends StatelessWidget {
  final String title;
  final String game;
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReviewerCard({
    super.key,
    required this.title,
    required this.game,
    required this.imagePath,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),

      child: Container(
        height: 90,

        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: const Color(0xFFD9D9D9),
            width: 2,
          ),
        ),

        child: Row(
          children: [
            // ================= NOTEBOOK IMAGE =================

            SizedBox(
              width: 50,
              height: 60,

              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 16),

            // ================= INFORMATION =================

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.nunito(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 13),

                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    text: TextSpan(
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.black,
                      ),

                      children: [
                        const TextSpan(
                          text: 'Game: ',
                        ),

                        TextSpan(
                          text: game,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ================= DELETE =================

            GestureDetector(
              onTap: onDelete,

              child: Container(
                width: 43,
                height: 43,

                decoration: BoxDecoration(
                  color: const Color(0xFFFF454D),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}