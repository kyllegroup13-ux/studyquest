import 'package:flutter/material.dart';

import '../controllers/letter_quest_controller.dart';
import '../models/letter_quest_question.dart';

class LetterQuestPage extends StatefulWidget {
  const LetterQuestPage({super.key});

  @override
  State<LetterQuestPage> createState() => _LetterQuestPageState();
}

class _LetterQuestPageState extends State<LetterQuestPage>
    with SingleTickerProviderStateMixin {
  late LetterQuestController controller;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool checkingAnswer = false;
  bool wrongAnswer = false;
  bool correctAnswer = false;

  // =========================
  // COLORS
  // =========================

  static const Color green = Color(0xFF65D523);

  static const Color red = Color(0xFFF33E42);

  // =========================
  // QUESTIONS
  // =========================

  final List<LetterQuestQuestion> questions = const [
    LetterQuestQuestion(
      question: 'A global network that connects computer and devices worldwide',
      answer: 'INTERNET',
    ),
    LetterQuestQuestion(
      question: 'An organized collection of data that can be easily accessed and managed',
      answer: 'DATABASE',
    ),
    LetterQuestQuestion(
      question: 'A step-by-step procedure used to solve a problem',
      answer: 'ALGORITHM',
    ),
    LetterQuestQuestion(
      question: 'Software that manages computer hardware and resources',
      answer: 'OPERATING',
    ),
  ];

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();

    controller = LetterQuestController(questions: questions);

    controller.onUpdate = () {
      if (mounted) {
        setState(() {});
      }
    };

    controller.onGameOver = () {
      if (mounted) {
        _showGameOverDialog();
      }
    };

    controller.onGameComplete = () {
      if (mounted) {
        _showCompleteDialog();
      }
    };

    // Shake animation
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    controller.startGame();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // =========================
  // SUBMIT
  // =========================

  Future<void> _submitAnswer() async {
    if (!controller.answerComplete || checkingAnswer) {
      return;
    }

    checkingAnswer = true;

    final bool isCorrect = controller.checkAnswer();

    // =========================
    // CORRECT
    // =========================

    if (isCorrect) {
      setState(() {
        correctAnswer = true;
      });

      controller.handleCorrectAnswer();

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      setState(() {
        correctAnswer = false;
        checkingAnswer = false;
      });

      controller.nextQuestion();

      return;
    }

    // =========================
    // WRONG
    // =========================

    setState(() {
      wrongAnswer = true;
    });

    // Shake answer slots.
    await _shakeController.forward(from: 0);

    // Keep red feedback visible.
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    controller.handleWrongAnswer();

    if (!mounted) return;

    if (controller.lives > 0) {
      controller.clearAnswer();
    }

    setState(() {
      wrongAnswer = false;
      checkingAnswer = false;
    });
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white54,
            size: 28,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              // =========================
              // LIVES
              // =========================
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      final bool active = index < controller.lives;

                      return Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : 5),
                        child: Icon(
                          active ? Icons.favorite : Icons.favorite_border,
                          color: active
                              ? const Color(0xFFF33E42)
                              : Colors.grey.shade400,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                ),
              ),

              SizedBox(height: 56),

              // =========================
              // GAME CONTENT
              // =========================

              // QUESTION NUMBER
              Text(
                'Question ${controller.currentQuestionIndex + 1}',
                style: const TextStyle(
                  color: green,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 18),

              // QUESTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Text(
                  controller.currentQuestion.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const Spacer(),

              // LETTER BANK
              _buildLetterBank(),

              const SizedBox(height: 75),

              // ANSWER SLOTS
              _buildAnswerSlots(),

              const SizedBox(height: 65),

              // SUBMIT
              _buildSubmitButton(),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // LETTER BANK
  // =========================

  Widget _buildLetterBank() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int count = controller.shuffledLetters.length;

        const double spacing = 5;

        // Calculate the largest tile size that
        // allows every letter to fit on one line.
        double tileSize =
            (constraints.maxWidth - (spacing * (count - 1))) / count;

        // Prevent tiles from becoming larger
        // than the original design.
        tileSize = tileSize.clamp(20.0, 40.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            final String letter = controller.shuffledLetters[index];

            final bool used = letter.isEmpty;

            return Padding(
              padding: EdgeInsets.only(right: index == count - 1 ? 0 : spacing),
              child: GestureDetector(
                onTap: used || checkingAnswer
                    ? null
                    : () {
                        controller.selectLetter(index);
                      },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: used ? 0.25 : 1,
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: used ? Colors.grey.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFD2D2D2),
                        width: tileSize < 28 ? 1.5 : 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          offset: Offset(0, 3),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: (tileSize * 0.52).clamp(12.0, 22.0),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // =========================
  // ANSWER SLOTS
  // =========================

  Widget _buildAnswerSlots() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(wrongAnswer ? _shakeAnimation.value : 0, 0),
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int count = controller.selectedLetters.length;

          const double spacing = 5;

          double tileSize =
              (constraints.maxWidth - (spacing * (count - 1))) / count;

          tileSize = tileSize.clamp(20.0, 40.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == count - 1 ? 0 : spacing,
                ),
                child: GestureDetector(
                  onTap: checkingAnswer
                      ? null
                      : () {
                          controller.removeLetter(index);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: wrongAnswer
                          ? const Color(0xFFFFCDD2)
                          : correctAnswer
                          ? const Color(0xFFC8E6C9)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                      border: wrongAnswer
                          ? Border.all(color: red, width: 2)
                          : correctAnswer
                          ? Border.all(color: green, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.selectedLetters[index] ?? '',
                      style: TextStyle(
                        fontSize: (tileSize * 0.52).clamp(12.0, 22.0),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // =========================
  // SUBMIT
  // =========================

  Widget _buildSubmitButton() {
    final bool enabled = controller.answerComplete && !checkingAnswer;

    return SizedBox(
      height: 47,
      child: ElevatedButton(
        onPressed: enabled ? _submitAnswer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: enabled ? 4 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // =========================
  // GAME OVER
  // =========================

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Game Over',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border, color: red, size: 65),

              const SizedBox(height: 15),

              const Text('You ran out of lives.'),

              const SizedBox(height: 10),

              Text(
                'Score: ${controller.score}/${questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  checkingAnswer = false;
                  wrongAnswer = false;
                  correctAnswer = false;
                });

                controller.restartGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
              ),
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // COMPLETE
  // =========================

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Great Job!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: green, size: 65),

              const SizedBox(height: 15),

              const Text(
                'You completed Letter Quest!',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                'Score: ${controller.score}/${questions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
              ),
              child: const Text('Finish'),
            ),
          ],
        );
      },
    );
  }
}
