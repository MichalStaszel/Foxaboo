import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recognition/recognition_result.dart';

/// One photo taken during the spike.
class Attempt {
  const Attempt({required this.verdict, required this.elapsed, this.matched});
  final Verdict verdict;
  final Duration elapsed;
  final Signal? matched;
}

/// Results of the spike, kept in memory only (nothing is saved or sent).
///
/// Keyed by `kind/id`, e.g. `item/cup` or `color/red`.
class SpikeResults {
  const SpikeResults(this.attempts);
  final Map<String, List<Attempt>> attempts;

  /// The game counts a target as working if it was found in at most two
  /// photos, as a child would get a second try after "Almost!".
  bool foundWithinTwo(String key) =>
      (attempts[key] ?? const []).take(2).any((a) => a.verdict == Verdict.hit);

  int get tested => attempts.length;
  int get found => attempts.keys.where(foundWithinTwo).length;
  double get hitRate => tested == 0 ? 0 : found / tested;

  Duration get averageTime {
    final all = attempts.values.expand((a) => a).toList();
    if (all.isEmpty) return Duration.zero;
    final micros = all.fold<int>(0, (sum, a) => sum + a.elapsed.inMicroseconds);
    return Duration(microseconds: micros ~/ all.length);
  }

  /// Best verdict so far for a target, or null if never tried.
  Verdict? best(String key) {
    final list = attempts[key];
    if (list == null || list.isEmpty) return null;
    if (list.any((a) => a.verdict == Verdict.hit)) return Verdict.hit;
    if (list.any((a) => a.verdict == Verdict.almost)) return Verdict.almost;
    return Verdict.miss;
  }
}

class SpikeResultsNotifier extends Notifier<SpikeResults> {
  @override
  SpikeResults build() => const SpikeResults({});

  void record(String key, RecognitionResult result) {
    final next = {
      for (final e in state.attempts.entries) e.key: [...e.value],
    };
    (next[key] ??= []).add(Attempt(
      verdict: result.verdict,
      elapsed: result.elapsed,
      matched: result.matched,
    ));
    state = SpikeResults(next);
  }

  void reset() => state = const SpikeResults({});
}

final spikeResultsProvider =
    NotifierProvider<SpikeResultsNotifier, SpikeResults>(
  SpikeResultsNotifier.new,
);
