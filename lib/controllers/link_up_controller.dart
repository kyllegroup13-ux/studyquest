import 'dart:math';

import '../models/link_up_question.dart';

class LinkUpController {
  final List<LinkUpQuestion> questions;

  int lives = 3;
  int score = 0;

  String? selectedTerm;
  String? selectedDefinition;

  final Set<String> matchedTerms = {};
  final Set<String> matchedDefinitions = {};

  late List<LinkUpQuestion> shuffledTerms;
  late List<LinkUpQuestion> shuffledDefinitions;

  void Function()? onUpdate;
  void Function()? onGameOver;
  void Function()? onRoundComplete;

  LinkUpController({required this.questions});

  // =========================
  // START GAME
  // =========================

  void startGame() {
    lives = 3;
    score = 0;

    selectedTerm = null;
    selectedDefinition = null;

    matchedTerms.clear();
    matchedDefinitions.clear();

    _shuffleItems();

    onUpdate?.call();
  }

  // =========================
  // SHUFFLE
  // =========================

  void _shuffleItems() {
    shuffledTerms = List.from(questions);
    shuffledDefinitions = List.from(questions);

    shuffledTerms.shuffle(Random());
    shuffledDefinitions.shuffle(Random());
  }

  // =========================
  // SELECT TERM
  // =========================

  void selectTerm(String term) {
    if (matchedTerms.contains(term)) return;

    selectedTerm = term;

    onUpdate?.call();
  }

  // =========================
  // SELECT DEFINITION
  // =========================

  void selectDefinition(String definition) {
    if (matchedDefinitions.contains(definition)) {
      return;
    }

    selectedDefinition = definition;

    onUpdate?.call();
  }

  // =========================
  // CHECK MATCH
  // =========================

  // true  = correct
  // false = wrong
  // null  = term/definition not completely selected yet

  bool? checkSelectedPair() {
    if (selectedTerm == null || selectedDefinition == null) {
      return null;
    }

    final LinkUpQuestion correctPair = questions.firstWhere(
      (question) => question.term == selectedTerm,
    );

    // CORRECT ANSWER
    if (correctPair.definition == selectedDefinition) {
      matchedTerms.add(selectedTerm!);

      matchedDefinitions.add(selectedDefinition!);

      score++;

      selectedTerm = null;
      selectedDefinition = null;

      onUpdate?.call();

      // Check if everything has been matched
      if (matchedTerms.length == questions.length) {
        onRoundComplete?.call();
      }

      return true;
    }

    // WRONG ANSWER
    return false;
  }

  // =========================
  // WRONG ANSWER
  // =========================

  void handleWrongAnswer() {
    selectedTerm = null;
    selectedDefinition = null;

    loseLife();
  }

  // =========================
  // CHECK STATES
  // =========================

  bool isTermMatched(String term) {
    return matchedTerms.contains(term);
  }

  bool isDefinitionMatched(String definition) {
    return matchedDefinitions.contains(definition);
  }

  bool isTermSelected(String term) {
    return selectedTerm == term;
  }

  bool isDefinitionSelected(String definition) {
    return selectedDefinition == definition;
  }

  // =========================
  // ALL MATCHED
  // =========================

  bool get allMatched {
    return matchedTerms.length == questions.length;
  }

  // =========================
  // CLEAR SELECTION
  // =========================

  void clearSelection() {
    selectedTerm = null;
    selectedDefinition = null;

    onUpdate?.call();
  }

  // =========================
  // LOSE LIFE
  // =========================

  void loseLife() {
    if (lives <= 0) return;

    lives--;

    onUpdate?.call();

    if (lives <= 0) {
      onGameOver?.call();
    }
  }

  // =========================
  // RESTART GAME
  // =========================

  void restartGame() {
    startGame();
  }
}
