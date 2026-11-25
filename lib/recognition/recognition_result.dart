/// The three outcomes the game shows the child.
enum Verdict {
  /// Found it: reward screen.
  hit,

  /// Close, but not sure: "Almost! Get closer" and try again.
  almost,

  /// Nothing matching: keep searching.
  miss,
}

/// One label or colour the recogniser saw, with its confidence or share (0..1).
class Signal {
  const Signal(this.name, this.score);
  final String name;
  final double score;

  @override
  String toString() => '$name ${(score * 100).round()}%';
}

class RecognitionResult {
  const RecognitionResult({
    required this.verdict,
    required this.signals,
    this.matched,
    this.elapsed = Duration.zero,
  });

  final Verdict verdict;

  /// What the recogniser saw, strongest first. Shown on the spike screen.
  final List<Signal> signals;

  /// The signal that decided the verdict, if any.
  final Signal? matched;

  /// Time spent recognising (not counting the camera shot).
  final Duration elapsed;

  RecognitionResult withElapsed(Duration d) => RecognitionResult(
        verdict: verdict,
        signals: signals,
        matched: matched,
        elapsed: d,
      );
}
