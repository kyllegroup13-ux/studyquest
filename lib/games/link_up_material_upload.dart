import 'package:flutter/material.dart';

import 'game_generator.dart';

class LinkUpPage extends StatelessWidget {
  const LinkUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameGeneratorPage(
      title: 'Link Up',
      description: 'Match terms with their definitions.',

      primaryColor: const Color(0xFFFFB12D),
      uploadColor: const Color(0xFFFFD084),
      uploadButtonColor: const Color(0xFFFFDFA3),
      generateButtonColor: const Color(0xFFFFA000),

      onUpload: () {
        // Select Link Up material
      },

      onGenerate: () {
        // Generate Link Up
      },
    );
  }
}
