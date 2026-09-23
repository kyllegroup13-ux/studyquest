import 'dart:math';

import '../models/letter_quest_question.dart';

class LetterQuestController {
  final List<LetterQuestQuestion> questions;

  int currentQuestionIndex = 0;
  int lives = 3;
  int score = 0;

  late List<String> shuffledLetters;

  List<String?> selectedLetters = [];

  void Function()? onUpdate;
  void Function()? onGameOver;
  void Function()? onGameComplete;

  LetterQuestController({required this.questions});

  // =========================
  // CURRENT QUESTION
  // =========================

  LetterQuestQuestion get currentQuestion {
    return questions[currentQuestionIndex];
  }

  // =========================
  // START GAME
  // =========================

  void startGame() {
    currentQuestionIndex = 0;
    lives = 3;
    score = 0;

    _prepareQuestion();

    onUpdate?.call();
  }

  // =========================
  // PREPARE QUESTION
  // =========================

  void _prepareQuestion() {
    final String answer = currentQuestion.answer
        .replaceAll(' ', '')
        .toUpperCase();

    // Create answer slots.
    selectedLetters = List<String?>.filled(answer.length, null);

    // Create shuffled letters.
    shuffledLetters = answer.split('');

    shuffledLetters.shuffle(Random());
  }

  // =========================
  // SELECT LETTER
  // =========================

  void selectLetter(int letterIndex) {
    if (letterIndex < 0 || letterIndex >= shuffledLetters.length) {
      return;
    }

    final String letter = shuffledLetters[letterIndex];

    // Find first empty answer slot.
    final int emptyIndex = selectedLetters.indexWhere((value) => value == null);

    if (emptyIndex == -1) {
      return;
    }

    selectedLetters[emptyIndex] = letter;

    // Mark source tile as used.
    shuffledLetters[letterIndex] = '';

    onUpdate?.call();
  }

  // =========================
  // REMOVE LETTER
  // =========================

  void removeLetter(int answerIndex) {
    if (answerIndex < 0 || answerIndex >= selectedLetters.length) {
      return;
    }

    final String? letter = selectedLetters[answerIndex];

    if (letter == null) {
      return;
    }

    // Return letter to first empty
    // position in the letter bank.
    final int emptyIndex = shuffledLetters.indexWhere((value) => value.isEmpty);

    if (emptyIndex != -1) {
      shuffledLetters[emptyIndex] = letter;
    }

    selectedLetters[answerIndex] = null;

    onUpdate?.call();
  }

  // =========================
  // ANSWER COMPLETE
  // =========================

  bool get answerComplete {
    return selectedLetters.every((letter) => letter != null);
  }

  // =========================
  // PLAYER ANSWER
  // =========================

  String get playerAnswer {
    return selectedLetters.map((letter) => letter ?? '').join();
  }

  // =========================
  // CHECK ANSWER
  // =========================

  bool checkAnswer() {
    final String correctAnswer = currentQuestion.answer
        .replaceAll(' ', '')
        .toUpperCase();

    return playerAnswer.toUpperCase() == correctAnswer;
  }

  // =========================
  // CORRECT ANSWER
  // =========================

  void handleCorrectAnswer() {
    score++;

    onUpdate?.call();
  }

  // =========================
  // WRONG ANSWER
  // =========================

  void handleWrongAnswer() {
    lives--;

    onUpdate?.call();

    if (lives <= 0) {
      onGameOver?.call();
    }
  }

  // =========================
  // CLEAR ANSWER
  // =========================

  void clearAnswer() {
    _prepareQuestion();

    onUpdate?.call();
  }

  // =========================
  // NEXT QUESTION
  // =========================

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;

      _prepareQuestion();

      onUpdate?.call();
    } else {
      onGameComplete?.call();
    }
  }

  // =========================
  // RESTART
  // =========================

  void restartGame() {
    startGame();
  }
}
