sealed class AiAnalysisResult {
  const AiAnalysisResult();
}

class AiAnalysisSuccess extends AiAnalysisResult {
  final String summary;
  final List<String> insights;
  final String advice;
  const AiAnalysisSuccess({
    required this.summary,
    required this.insights,
    required this.advice,
  });
}

class AiAnalysisFailure extends AiAnalysisResult {
  final String message;
  const AiAnalysisFailure(this.message);
}
