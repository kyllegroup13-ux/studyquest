import 'package:flutter/material.dart';
import 'game_generator.dart';

class MindRushPage extends StatelessWidget {
  const MindRushPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameGeneratorPage(
      title: 'Mind Rush',
      description:
          'Choose the correct answer before the time runs out',

      primaryColor: const Color(0xFFF45B5F),
      uploadColor: const Color(0xFFF99A9D),
      uploadButtonColor: const Color(0xFFFFB6B8),
      generateButtonColor: const Color(0xFFF84247),

      onUpload: () {
        // Select Mind Rush material
      },

      onGenerate: () {
        // Generate Mind Rush
      },
    );
  }
}