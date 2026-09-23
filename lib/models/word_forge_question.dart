class WordForgeQuestion {
  final String template;
  final List<String> correctAnswers;
  final List<String> choices;

  const WordForgeQuestion({
    required this.template,
    required this.correctAnswers,
    required this.choices,
  });
}