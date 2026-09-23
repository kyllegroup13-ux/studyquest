import 'dart:math';

import '../models/word_forge_question.dart';

class WordForgeController {
  final List<WordForgeQuestion> questions;

  int currentQuestionIndex = 0;
  int lives = 3;
  int score = 0;

  List<String> selectedWords = [];
  late List<String> shuffledChoices;

  void Function()? onUpdate;
  void Function()? onGameOver;
  void Function()? onGameComplete;

  WordForgeController({
    required this.questions,
  });

  // =========================
  // CURRENT QUESTION
  // =========================

  WordForgeQuestion get currentQuestion {
    return questions[currentQuestionIndex];
  }

  // =========================
  // START GAME
  // =========================

  void startGame() {
    currentQuestionIndex = 0;
    lives = 3;
    score = 0;

    selectedWords.clear();

    _shuffleChoices();

    onUpdate?.call();
  }

  // =========================
  // SHUFFLE CHOICES
  // =========================

  void _shuffleChoices() {
    shuffledChoices =
        List.from(currentQuestion.choices);

    shuffledChoices.shuffle(Random());
  }

  // =========================
  // SELECT WORD
  // =========================

  void selectWord(String word) {
    if (selectedWords.contains(word)) {
      return;
    }

    if (selectedWords.length >=
        currentQuestion.correctAnswers.length) {
      return;
    }

    selectedWords.add(word);

    onUpdate?.call();
  }

  // =========================
  // REMOVE WORD
  // =========================

  void removeWord(String word) {
    selectedWords.remove(word);

    onUpdate?.call();
  }

  // =========================
  // CHECK IF SELECTED
  // =========================

  bool isSelected(String word) {
    return selectedWords.contains(word);
  }

  // =========================
  // ANSWER COMPLETE
  // =========================

  bool get answerComplete {
    return selectedWords.length ==
        currentQuestion.correctAnswers.length;
  }

  // =========================
  // CHECK ANSWER
  // =========================

  bool checkAnswer() {
    if (!answerComplete) {
      return false;
    }

    for (int i = 0;
        i < currentQuestion.correctAnswers.length;
        i++) {
      if (selectedWords[i].toLowerCase() !=
          currentQuestion
              .correctAnswers[i]
              .toLowerCase()) {
        return false;
      }
    }

    return true;
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

    selectedWords.clear();

    onUpdate?.call();

    if (lives <= 0) {
      onGameOver?.call();
    }
  }

  // =========================
  // NEXT QUESTION
  // =========================

  void nextQuestion() {
    if (currentQuestionIndex <
        questions.length - 1) {
      currentQuestionIndex++;

      selectedWords.clear();

      _shuffleChoices();

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