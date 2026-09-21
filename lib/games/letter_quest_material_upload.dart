import 'package:flutter/material.dart';

import 'game_generator.dart';

class LetterQuestPage extends StatelessWidget {
  const LetterQuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameGeneratorPage(
      title: 'Letter Quest',
      description: 'Unscramble letters to find the correct term.',

      primaryColor: const Color(0xFF62D91E),
      uploadColor: const Color(0xFFA5EC7D),
      uploadButtonColor: const Color(0xFFC5F4AA),
      generateButtonColor: const Color(0xFF52C714),

      onUpload: () {
        // Select Letter Quest material
      },

      onGenerate: () {
        // Generate Letter Quest
      },
    );
  }
}
