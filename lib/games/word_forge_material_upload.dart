import 'package:flutter/material.dart';

import 'game_generator.dart';

class WordForgePage extends StatelessWidget {
  const WordForgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameGeneratorPage(
      title: 'Word Forge',
      description: 'Fill in the missing word or phrase.',

      primaryColor: const Color(0xFF7477F3),
      uploadColor: const Color(0xFFA5A7FA),
      uploadButtonColor: const Color(0xFFC4C5FF),
      generateButtonColor: const Color(0xFF6366F1),

      onUpload: () {
        // Select Word Forge material
      },

      onGenerate: () {
        // Generate Word Forge
      },
    );
  }
}
