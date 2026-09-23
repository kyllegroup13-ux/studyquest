import 'package:flutter/material.dart';

import '../models/mind_rush_question.dart';
import '../controllers/mind_rush_controller.dart';

class MindRushPage extends StatefulWidget {
  const MindRushPage({super.key});

  @override
  State<MindRushPage> createState() => _MindRushPageState();
}

class _MindRushPageState extends State<MindRushPage> {
  late MindRushController controller;

  String? selectedAnswer;
  bool answerLocked = false;

  // =========================
  // SAMPLE QUESTIONS
  // =========================

  final List<MindRushQuestion> questions = [
    MindRushQuestion(
      question: 'What kind of data type is\ncomprised of whole\nnumber?',
      choices: ['int', 'String', 'char', 'float'],
      correctAnswer: 'int',
    ),

    MindRushQuestion(
      question: 'Which data type stores\ntext values?',
      choices: ['String', 'int', 'double', 'bool'],
      correctAnswer: 'String',
    ),

    MindRushQuestion(
      question: 'Which data type stores\ntrue or false values?',
      choices: ['bool', 'String', 'int', 'char'],
      correctAnswer: 'bool',
    ),

    MindRushQuestion(
      question: 'Which data type can store\ndecimal numbers?',
      choices: ['double', 'int', 'String', 'bool'],
      correctAnswer: 'double',
    ),
  ];

  // Colors based on your design
  static const Color coral = Color(0xFFF45F61);
  static const Color purple = Color(0xFF7776F5);
  static const Color blue = Color(0xFF55BCEB);
  static const Color orange = Color(0xFFF6AB2B);
  static const Color red = Color(0xFFF35F61);

  @override
  void initState() {
    super.initState();

    controller = MindRushController(questions: questions);

    controller.onUpdate = () {
      if (mounted) {
        setState(() {});
      }
    };

    controller.onGameFinished = () {
      if (mounted) {
        _showGameResult();
      }
    };

    controller.startGame();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // =========================
  // ANSWER HANDLER
  // =========================

  Future<void> _selectAnswer(String answer) async {
    if (answerLocked) return;

    setState(() {
      selectedAnswer = answer;
      answerLocked = true;
    });

    controller.checkAnswer(answer);

    controller.answerQuestion(answer);

    // Wait so the user can see the result
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (controller.lives <= 0 || controller.isLastQuestion) {
      controller.finishGame();
      return;
    }

    setState(() {
      selectedAnswer = null;
      answerLocked = false;
    });

    controller.nextQuestion();
  }

  // =========================
  // ANSWER COLOR
  // =========================

  Color _getBorderColor(String answer, int index) {
    if (selectedAnswer != null) {
      if (answer == controller.currentQuestion.correctAnswer) {
        return Colors.green;
      }

      if (answer == selectedAnswer) {
        return Colors.red;
      }
    }

    final colors = [red, blue, orange, purple];

    return colors[index % colors.length];
  }

  // =========================
  // RESULT DIALOG
  // =========================

  void _showGameResult() {
    final bool noLives = controller.lives <= 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            noLives ? 'Game Over' : 'Great Job!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                noLives ? Icons.favorite_border : Icons.emoji_events_rounded,
                size: 60,
                color: noLives ? coral : orange,
              ),

              const SizedBox(height: 16),

              Text(
                'Your Score',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 5),

              Text(
                '${controller.score}/${controller.questions.length}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: coral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  selectedAnswer = null;
                  answerLocked = false;
                });

                controller.restartGame();
              },
              child: const Text(
                'Play Again',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final question = controller.currentQuestion;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: coral,
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
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                                : Colors.white70,
                            size: 30,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // QUESTION NUMBER
                  Text(
                    'Question ${controller.currentQuestionIndex + 1}',
                    style: const TextStyle(
                      color: coral,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // QUESTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // TIMER
                  _buildTimer(),

                  const SizedBox(height: 20),

                  // ANSWERS
                  _buildAnswers(),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // TOP BAR
  // =========================

  // =========================
  // TIMER BAR
  // =========================

  Widget _buildTimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 22,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: controller.progress,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(purple),
            minHeight: 14,
          ),
        ),
      ),
    );
  }

  // =========================
  // ANSWER GRID
  // =========================

  Widget _buildAnswers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.currentQuestion.choices.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3.1,
        ),
        itemBuilder: (context, index) {
          final answer = controller.currentQuestion.choices[index];

          return _answerButton(answer, index);
        },
      ),
    );
  }

  // =========================
  // ANSWER BUTTON
  // =========================

  Widget _answerButton(String answer, int index) {
    final borderColor = _getBorderColor(answer, index);

    return GestureDetector(
      onTap: answerLocked ? null : () => _selectAnswer(answer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 5),
              blurRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          answer,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
