import 'dart:math';

import '../content/models.dart';

/// Pure game rules, kept apart from widgets so they can be tested.

/// Round modes: `colors` or a room id.
const colorsMode = 'colors';

List<Target> targetsFor(ContentPack pack, String mode) => mode == colorsMode
    ? [for (final c in pack.colors) ColorTarget(c)]
    : [for (final i in pack.itemsIn(mode)) ItemTarget(i)];

int _difficulty(Target t) => switch (t) {
      ItemTarget(:final item) => item.difficulty,
      ColorTarget() => 1,
    };

/// Picks [count] targets for a round. Targets the child has not found yet
/// come first, then easier before harder; ties are random. The round itself
/// goes easy to hard.
List<Target> pickTargets({
  required ContentPack pack,
  required String mode,
  required Set<String> alreadyFound,
  required Random random,
  int count = 5,
}) {
  final pool = targetsFor(pack, mode)..shuffle(random);
  int priority(Target t) =>
      (alreadyFound.contains(t.id) ? 10 : 0) + _difficulty(t);
  pool.sort((a, b) => priority(a).compareTo(priority(b)));
  final picked = pool.take(count).toList()
    ..sort((a, b) => _difficulty(a).compareTo(_difficulty(b)));
  return picked;
}

/// Another target for "pick something else", not already in the round.
Target? replacementTarget({
  required ContentPack pack,
  required String mode,
  required Set<String> exclude,
  required Random random,
}) {
  final pool =
      targetsFor(pack, mode).where((t) => !exclude.contains(t.id)).toList();
  if (pool.isEmpty) return null;
  return pool[random.nextInt(pool.length)];
}

enum TaskOutcome { found, foundByParent, timedOut }

class TaskResult {
  const TaskResult(this.target, this.outcome, this.time, {this.isNew = false});
  final Target target;
  final TaskOutcome outcome;
  final Duration time;

  /// First time this child found it: a new sticker.
  final bool isNew;

  bool get found => outcome != TaskOutcome.timedOut;
}

/// Countdown for one target. It only moves while running, so it stands still
/// while the child reads "almost", while a photo is checked, and while the
/// app is in the background.
class HuntClock {
  HuntClock(this.limit);

  final Duration limit;
  Duration _elapsed = Duration.zero;
  bool running = false;

  Duration get elapsed => _elapsed;
  Duration get remaining => limit - _elapsed;
  bool get isOver => _elapsed >= limit;

  /// 1.0 at the start, 0.0 when time is up.
  double get fractionLeft =>
      1 - _elapsed.inMicroseconds / limit.inMicroseconds;

  void tick(Duration delta) {
    if (!running || isOver) return;
    _elapsed += delta;
    if (_elapsed > limit) _elapsed = limit;
  }

  void reset() {
    _elapsed = Duration.zero;
    running = false;
  }
}

/// "Tap 4, 9, 2": three different digits read out as words. Young children
/// can tap digits but not read number words; adults can.
class GateChallenge {
  GateChallenge(this.digits);

  factory GateChallenge.random(Random random) {
    final all = List.generate(10, (i) => i)..shuffle(random);
    return GateChallenge(all.take(3).toList());
  }

  final List<int> digits;

  bool accepts(List<int> entered) =>
      entered.length == digits.length &&
      Iterable.generate(digits.length).every((i) => entered[i] == digits[i]);
}
