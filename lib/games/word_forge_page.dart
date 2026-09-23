import 'package:flutter/material.dart';

import '../controllers/word_forge_controller.dart';
import '../models/word_forge_question.dart';

class WordForgePage extends StatefulWidget {
  const WordForgePage({super.key});

  @override
  State<WordForgePage> createState() => _WordForgePageState();
}

class _WordForgePageState extends State<WordForgePage> {
  late WordForgeController controller;

  bool showingFeedback = false;
  bool wrongAnswer = false;

  // =========================
  // COLORS
  // =========================

  static const Color purple = Color(0xFF7776F5);

  static const Color green = Color(0xFF65D523);

  static const Color red = Color(0xFFF33E42);

  // =========================
  // SAMPLE QUESTIONS
  // =========================

  final List<WordForgeQuestion> questions = const [
    WordForgeQuestion(
      template: 'An {} is a {} network that connects {} and devices {}.',
      correctAnswers: ['internet', 'global', 'computer', 'worldwide'],
      choices: [
        'internet',
        'Wi-Fi',
        'nationwide',
        'worldwide',
        'global',
        'computer',
      ],
    ),

    WordForgeQuestion(
      template: 'A {} is an organized collection of {}.',
      correctAnswers: ['database', 'data'],
      choices: [
        'database',
        'internet',
        'data',
        'computer',
        'network',
        'algorithm',
      ],
    ),

    WordForgeQuestion(
      template: 'An {} is a step-by-step set of {} used to solve a problem.',
      correctAnswers: ['algorithm', 'instructions'],
      choices: [
        'algorithm',
        'instructions',
        'database',
        'internet',
        'hardware',
        'software',
      ],
    ),
  ];

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();

    controller = WordForgeController(questions: questions);

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

    controller.startGame();
  }

  // =========================
  // SELECT WORD
  // =========================

  void _selectWord(String word) {
    if (showingFeedback) return;

    if (controller.isSelected(word)) {
      controller.removeWord(word);
    } else {
      controller.selectWord(word);
    }
  }

  // =========================
  // SUBMIT ANSWER
  // =========================

  Future<void> _submitAnswer() async {
    if (!controller.answerComplete || showingFeedback) {
      return;
    }

    final bool correct = controller.checkAnswer();

    // =========================
    // CORRECT
    // =========================

    if (correct) {
      setState(() {
        showingFeedback = true;
        wrongAnswer = false;
      });

      controller.handleCorrectAnswer();

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      setState(() {
        showingFeedback = false;
      });

      controller.nextQuestion();

      return;
    }

    // =========================
    // WRONG
    // =========================

    setState(() {
      showingFeedback = true;
      wrongAnswer = true;
    });

    // Keep wrong answer red briefly.
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    controller.handleWrongAnswer();

    if (!mounted) return;

    setState(() {
      showingFeedback = false;
      wrongAnswer = false;
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
        backgroundColor: purple,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white.withValues(alpha: 0.5),
            size: 27,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            children: [
              // =========================
              // LIVES
              // =========================
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final bool active = index < controller.lives;

                    return Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                      child: Icon(
                        active ? Icons.favorite : Icons.favorite_border,
                        color: active ? red : Colors.grey,
                        size: 28,
                      ),
                    );
                  }),
                ),
              ),

              // Space between lives and statement title
              const SizedBox(height: 65),

              // =========================
              // STATEMENT NUMBER
              // =========================
              Text(
                'Statement ${controller.currentQuestionIndex + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: purple,
                ),
              ),

              // Space between title and statement
              const SizedBox(height: 22),

              // =========================
              // STATEMENT
              // =========================
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildStatement(),
              ),

              // Space between statement and choices
              const SizedBox(height: 55),

              // =========================
              // WORD CHOICES
              // =========================
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildWordChoices(),
              ),

              // Space between choices and button
              const SizedBox(height: 28),

              // =========================
              // SUBMIT BUTTON
              // =========================
              _buildSubmitButton(),

              // All remaining empty space goes here
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // STATEMENT
  // =========================

  Widget _buildStatement() {
    final question = controller.currentQuestion;

    final List<String> parts = question.template.split('{}');

    final List<InlineSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));

      if (i < question.correctAnswers.length) {
        String answer = '_______';

        if (i < controller.selectedWords.length) {
          answer = controller.selectedWords[i];
        }

        spans.add(
          TextSpan(
            text: answer,
            style: TextStyle(
              color: wrongAnswer
                  ? red
                  : i < controller.selectedWords.length
                  ? purple
                  : Colors.black,
              fontWeight: FontWeight.w800,
              decoration: wrongAnswer
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        );
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: wrongAnswer ? const Color(0xFFFFEBEE) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 23,
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
          children: spans,
        ),
      ),
    );
  }

  // =========================
  // WORD CHOICES
  // =========================

  Widget _buildWordChoices() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 14,
      children: controller.shuffledChoices.map((word) {
        return _buildWordButton(word);
      }).toList(),
    );
  }

  // =========================
  // WORD BUTTON
  // =========================

  Widget _buildWordButton(String word) {
    final bool selected = controller.isSelected(word);

    return GestureDetector(
      onTap: showingFeedback
          ? null
          : () {
              _selectWord(word);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? purple.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? purple : const Color(0xFFD2D2D2),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 4),
              blurRadius: 1,
            ),
          ],
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: selected ? purple : Colors.black,
          ),
        ),
      ),
    );
  }

  // =========================
  // SUBMIT BUTTON
  // =========================

  Widget _buildSubmitButton() {
    final bool enabled = controller.answerComplete && !showingFeedback;

    return SizedBox(
      height: 47,
      child: ElevatedButton(
        onPressed: enabled ? _submitAnswer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: enabled ? 4 : 0,
          shadowColor: green,
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
                  showingFeedback = false;
                  wrongAnswer = false;
                });

                controller.restartGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
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
              const Icon(Icons.emoji_events_rounded, color: purple, size: 65),

              const SizedBox(height: 15),

              const Text(
                'You completed Word Forge!',
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
                backgroundColor: purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Finish'),
            ),
          ],
        );
      },
    );
  }
}
