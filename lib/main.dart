import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import 'package:e_learning/auth_wrapper.dart';
//import 'package:e_learning/games/mind_rush_page.dart';
//import 'package:e_learning/games/link_up_page.dart';
//import 'package:e_learning/games/word_forge_page.dart';
import 'package:e_learning/games/letter_quest_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const LetterQuestPage(),
    );
  }
}
