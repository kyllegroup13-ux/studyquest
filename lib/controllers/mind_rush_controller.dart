import 'dart:async';
import 'dart:math';

import '../models/mind_rush_question.dart';

class MindRushController {
  final List<MindRushQuestion> questions;

  int currentQuestionIndex = 0;
  int lives = 3;
  int score = 0;

  int maxTime = 10;
  int remainingTime = 10;

  Timer? _timer;

  void Function()? onUpdate;
  void Function()? onGameFinished;

  MindRushController({required this.questions});

  MindRushQuestion get currentQuestion => questions[currentQuestionIndex];

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  double get progress {
    if (maxTime == 0) return 0;
    return remainingTime / maxTime;
  }

  void startGame() {
    currentQuestionIndex = 0;
    lives = 3;
    score = 0;

    shuffleChoices();
    startTimer();

    onUpdate?.call();
  }

  void startTimer() {
    _timer?.cancel();

    remainingTime = maxTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        remainingTime--;
        onUpdate?.call();
      } else {
        timer.cancel();
        handleTimeout();
      }
    });
  }

  void handleTimeout() {
    lives--;

    if (lives <= 0) {
      finishGame();
      return;
    }

    nextQuestion();
  }

  bool checkAnswer(String selectedAnswer) {
    return selectedAnswer == currentQuestion.correctAnswer;
  }

  void answerQuestion(String selectedAnswer) {
    _timer?.cancel();

    final bool correct = checkAnswer(selectedAnswer);

    if (correct) {
      score++;
    } else {
      lives--;
    }

    onUpdate?.call();
  }

  void nextQuestion() {
    if (lives <= 0) {
      finishGame();
      return;
    }

    if (isLastQuestion) {
      finishGame();
      return;
    }

    currentQuestionIndex++;

    shuffleChoices();

    startTimer();

    onUpdate?.call();
  }

  void shuffleChoices() {
    currentQuestion.choices.shuffle(Random());
  }

  void finishGame() {
    _timer?.cancel();
    onGameFinished?.call();
  }

  void restartGame() {
    currentQuestionIndex = 0;
    lives = 3;
    score = 0;

    for (final question in questions) {
      question.choices.shuffle(Random());
    }

    startTimer();
    onUpdate?.call();
  }

  void dispose() {
    _timer?.cancel();
  }
}
