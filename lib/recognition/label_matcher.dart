import 'recognition_result.dart';

/// Thresholds for turning model labels into a game verdict.
///
/// These are starting values. The spike exists to calibrate them on photos
/// from a real home, so keep them in one place.
class LabelThresholds {
  const LabelThresholds({
    this.hit = 0.60,
    this.almost = 0.30,
    this.topK = 5,
  });

  /// Minimum confidence of a matching label, within the top [topK], to count
  /// as found.
  final double hit;

  /// Minimum confidence of a matching label anywhere in the results to say
  /// "almost".
  final double almost;

  /// How many of the strongest labels are considered for a hit.
  final int topK;
}

/// Decides hit / almost / miss from the labels a model returned.
///
/// Pure function so it can be unit tested without a model or a camera.
RecognitionResult matchLabels({
  required List<Signal> labels,
  required List<String> acceptedLabels,
  LabelThresholds thresholds = const LabelThresholds(),
}) {
  final sorted = [...labels]..sort((a, b) => b.score.compareTo(a.score));
  final accepted = {for (final l in acceptedLabels) l.toLowerCase()};

  Signal? best;
  var bestRank = -1;
  for (var i = 0; i < sorted.length; i++) {
    if (accepted.contains(sorted[i].name.toLowerCase())) {
      best = sorted[i];
      bestRank = i;
      break;
    }
  }

  final Verdict verdict;
  if (best == null) {
    verdict = Verdict.miss;
  } else if (bestRank < thresholds.topK && best.score >= thresholds.hit) {
    verdict = Verdict.hit;
  } else if (best.score >= thresholds.almost) {
    verdict = Verdict.almost;
  } else {
    verdict = Verdict.miss;
  }

  return RecognitionResult(verdict: verdict, signals: sorted, matched: best);
}
