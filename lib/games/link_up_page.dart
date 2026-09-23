import 'package:flutter/material.dart';

import 'dart:async';

import '../controllers/link_up_controller.dart';
import '../models/link_up_question.dart';

class LinkUpPage extends StatefulWidget {
  const LinkUpPage({super.key});

  @override
  State<LinkUpPage> createState() => _LinkUpPageState();
}

class _LinkUpPageState extends State<LinkUpPage>
    with SingleTickerProviderStateMixin {
  late LinkUpController controller;

  static const int maxTime = 8;
  int remainingTime = maxTime;

  Timer? _gameTimer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  String? wrongTerm;
  String? wrongDefinition;

  bool checkingAnswer = false;
  bool timerProcessing = false;

  // =========================
  // COLORS
  // =========================

  static const Color orange = Color(0xFFFCAF2D);

  static const Color purple = Color(0xFFA7A8F3);
  static const Color yellow = Color(0xFFF8CE86);
  static const Color pink = Color(0xFFF39A9D);
  static const Color blue = Color(0xFF8BD2F0);

  static const Color green = Color(0xFF58D927);

  // =========================
  // SAMPLE QUESTIONS
  // =========================

  final List<LinkUpQuestion> questions = const [
    LinkUpQuestion(
      term: 'Database',
      definition:
          'A collection of data organized for easy access and management',
    ),
    LinkUpQuestion(
      term: 'Internet',
      definition:
          'A global network that connects computer and devices worldwide',
    ),
    LinkUpQuestion(
      term: 'Algorithm',
      definition:
          'A step-by-step procedure or set of instructions to solve a problem',
    ),
    LinkUpQuestion(
      term: 'Operating\nSystem',
      definition: 'Software that manages the computer hardware and resources',
    ),
  ];

  // =========================
  // INITIALIZATION
  // =========================

  @override
  void initState() {
    super.initState();

    // Initialize Link Up controller
    controller = LinkUpController(questions: questions);

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

    controller.onRoundComplete = () {
      _gameTimer?.cancel();

      if (mounted) {
        setState(() {});
      }
    };

    // =========================
    // SHAKE ANIMATION
    // =========================

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
          TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    controller.startGame();
    _startTimer();
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _gameTimer?.cancel();
    _shakeController.dispose();

    super.dispose();
  }

  // =========================
  // TIMER
  // =========================

  void _startTimer() {
    _gameTimer?.cancel();

    remainingTime = maxTime;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (remainingTime > 1) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();

        setState(() {
          remainingTime = 0;
        });

        _handleTimeout();
      }
    });
  }

  void _resetTimer() {
    _gameTimer?.cancel();

    if (!mounted) return;

    setState(() {
      remainingTime = maxTime;
    });

    _startTimer();
  }

  Future<void> _handleTimeout() async {
    if (timerProcessing ||
        checkingAnswer ||
        controller.allMatched ||
        controller.lives <= 0) {
      return;
    }

    timerProcessing = true;

    // Clear any half-completed selection.
    controller.clearSelection();

    // Deduct one life.
    controller.loseLife();

    if (!mounted) return;

    if (controller.lives > 0) {
      setState(() {
        remainingTime = maxTime;
        timerProcessing = false;
      });

      _startTimer();
    } else {
      timerProcessing = false;
    }
  }

  // =========================
  // CHECK PAIR
  // =========================

  Future<void> _checkPair() async {
    if (controller.selectedTerm == null ||
        controller.selectedDefinition == null) {
      return;
    }

    if (checkingAnswer) return;

    checkingAnswer = true;

    // Stop timer while showing answer feedback.
    _gameTimer?.cancel();

    final bool? result = controller.checkSelectedPair();

    // =========================
    // CORRECT
    // =========================

    if (result == true) {
      checkingAnswer = false;

      if (!mounted) return;

      setState(() {});

      // Don't restart timer if everything
      // has already been completed.
      if (!controller.allMatched) {
        _resetTimer();
      }

      return;
    }

    // =========================
    // WRONG
    // =========================

    if (result == false) {
      setState(() {
        wrongTerm = controller.selectedTerm;
        wrongDefinition = controller.selectedDefinition;
      });

      // Shake wrong pair
      await _shakeController.forward(from: 0);

      // Keep cards red briefly
      await Future.delayed(const Duration(milliseconds: 250));

      if (!mounted) return;

      controller.handleWrongAnswer();

      if (!mounted) return;

      setState(() {
        wrongTerm = null;
        wrongDefinition = null;
        checkingAnswer = false;
      });

      // Restart only when player
      // still has lives.
      if (controller.lives > 0) {
        _resetTimer();
      }
    }
  }

  // =========================
  // TERM COLORS
  // =========================

  Color _getTermColor(String term) {
    switch (term.replaceAll('\n', ' ')) {
      case 'Database':
        return purple;

      case 'Internet':
        return yellow;

      case 'Algorithm':
        return pink;

      case 'Operating System':
        return blue;

      default:
        return Colors.grey.shade300;
    }
  }

  // =========================
  // GAME OVER DIALOG
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
              const Icon(Icons.favorite_border, size: 65, color: Colors.red),

              const SizedBox(height: 15),

              const Text('You ran out of lives.'),

              const SizedBox(height: 10),

              Text(
                'Matches: ${controller.score}/${questions.length}',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  wrongTerm = null;
                  wrongDefinition = null;
                  checkingAnswer = false;
                  timerProcessing = false;
                  remainingTime = maxTime;
                });

                controller.restartGame();

                _startTimer();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // COMPLETE DIALOG
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
              const Icon(Icons.emoji_events_rounded, size: 65, color: orange),

              const SizedBox(height: 15),

              Text(
                'You matched all ${questions.length} terms!',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Finish',
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: orange,
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
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(3, (index) {
                        final bool active = index < controller.lives;

                        return Padding(
                          padding: EdgeInsets.only(left: index == 0 ? 0 : 5),
                          child: Icon(
                            active ? Icons.favorite : Icons.favorite_border,
                            color: active
                                ? const Color(0xFFF33E42)
                                : Colors.grey,
                            size: 30,
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // =========================
                          // HEADERS
                          // =========================
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Terms',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),

                              SizedBox(width: 45),

                              Expanded(
                                child: Text(
                                  'Definitions',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // =========================
                          // GAME CONTENT
                          // =========================
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildTerms()),

                                const SizedBox(width: 45),

                                Expanded(child: _buildDefinitions()),
                              ],
                            ),
                          ),

                          // =========================
                          // TIMER
                          // =========================
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildPieTimer(),
                            
                                const SizedBox(width: 45),
                            
                                _buildNextButton(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // TERMS
  // =========================

  Widget _buildTerms() {
    return Column(
      children: controller.shuffledTerms.map((question) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildTermCard(question),
        );
      }).toList(),
    );
  }

  // =========================
  // TERM CARD
  // =========================

  Widget _buildTermCard(LinkUpQuestion question) {
    final bool matched = controller.isTermMatched(question.term);

    final bool selected = controller.isTermSelected(question.term);

    final bool isWrong = wrongTerm == question.term;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(isWrong ? _shakeAnimation.value : 0, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: matched || checkingAnswer
            ? null
            : () async {
                controller.selectTerm(question.term);

                await _checkPair();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 88,
          width: double.infinity,
          decoration: BoxDecoration(
            // Wrong = red
            // Matched = green
            // Normal = original color
            color: isWrong
                ? const Color(0xFFFFCDD2)
                : matched
                ? Colors.green.shade100
                : _getTermColor(question.term),
            borderRadius: BorderRadius.circular(12),
            border: selected || isWrong
                ? Border.all(
                    color: isWrong ? const Color(0xFFE53935) : Colors.black,
                    width: 3,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            question.term,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: matched ? Colors.green.shade800 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // DEFINITIONS
  // =========================

  Widget _buildDefinitions() {
    return Column(
      children: controller.shuffledDefinitions.map((question) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildDefinitionCard(question),
        );
      }).toList(),
    );
  }

  // =========================
  // DEFINITION CARD
  // =========================

  Widget _buildDefinitionCard(LinkUpQuestion question) {
    final bool matched = controller.isDefinitionMatched(question.definition);

    final bool selected = controller.isDefinitionSelected(question.definition);

    final bool isWrong = wrongDefinition == question.definition;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(isWrong ? _shakeAnimation.value : 0, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: matched || checkingAnswer
            ? null
            : () async {
                controller.selectDefinition(question.definition);

                await _checkPair();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 88,
          width: double.infinity,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isWrong
                ? const Color(0xFFFFCDD2)
                : matched
                ? Colors.green.shade100
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isWrong
                  ? const Color(0xFFE53935)
                  : selected
                  ? Colors.greenAccent
                  : Colors.black,
              width: selected || isWrong ? 3 : 2,
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            question.definition,
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: matched ? Colors.green.shade800 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // PIE TIMER
  // =========================

  Widget _buildPieTimer() {
    final double progress = remainingTime / maxTime;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    remainingTime <= 3 ? Colors.red : Colors.greenAccent,
                  ),
                ),
              ),

              Text(
                '$remainingTime',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: remainingTime <= 3 ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Time',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // =========================
  // NEXT BUTTON
  // =========================

  Widget _buildNextButton() {
    final bool enabled = controller.allMatched;

    return SizedBox(
      width: 92,
      height: 44,
      child: ElevatedButton(
        onPressed: enabled ? _showCompleteDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          elevation: enabled ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
