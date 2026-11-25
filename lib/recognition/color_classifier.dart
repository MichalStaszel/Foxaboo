import 'dart:math' as math;

import 'recognition_result.dart';

/// Colour ids the game can ask for, plus neutrals it can recognise.
const huntColors = [
  'red',
  'orange',
  'yellow',
  'green',
  'blue',
  'purple',
  'pink',
  'brown',
];
const neutralColors = ['white', 'gray', 'black'];

class ColorThresholds {
  const ColorThresholds({this.hit = 0.30, this.almost = 0.15});

  /// Share of the centre of the frame the target colour must cover.
  final double hit;

  /// Share for "almost": the colour is there, but small.
  final double almost;
}

/// Names the colour of one RGB pixel (0..255 per channel).
String classifyPixel(int r, int g, int b) {
  final rf = r / 255, gf = g / 255, bf = b / 255;
  final maxC = math.max(rf, math.max(gf, bf));
  final minC = math.min(rf, math.min(gf, bf));
  final v = maxC;
  final d = maxC - minC;
  final s = maxC == 0 ? 0.0 : d / maxC;

  if (v < 0.18) return 'black';
  if (s < 0.18) return v > 0.80 ? 'white' : 'gray';

  double h;
  if (d == 0) {
    h = 0;
  } else if (maxC == rf) {
    h = 60 * (((gf - bf) / d) % 6);
  } else if (maxC == gf) {
    h = 60 * (((bf - rf) / d) + 2);
  } else {
    h = 60 * (((rf - gf) / d) + 4);
  }
  if (h < 0) h += 360;

  // Dark, warm and not very saturated reads as brown (wood, chocolate, soil).
  if (h >= 10 && h < 50 && v < 0.60) return 'brown';
  if (h < 12 || h >= 345) {
    // Light, washed-out red is what children call pink.
    return (s < 0.50 && v > 0.75) ? 'pink' : 'red';
  }
  if (h < 40) return 'orange';
  if (h < 68) return 'yellow';
  if (h < 165) return 'green';
  if (h < 255) return 'blue';
  if (h < 290) return 'purple';
  return 'pink';
}

/// Shares of each colour among [pixels] (packed as 0xRRGGBB), strongest first.
List<Signal> colorShares(Iterable<int> pixels) {
  final counts = <String, int>{};
  var total = 0;
  for (final p in pixels) {
    final name = classifyPixel((p >> 16) & 0xff, (p >> 8) & 0xff, p & 0xff);
    counts[name] = (counts[name] ?? 0) + 1;
    total++;
  }
  if (total == 0) return const [];
  final shares = [
    for (final e in counts.entries) Signal(e.key, e.value / total),
  ]..sort((a, b) => b.score.compareTo(a.score));
  return shares;
}

/// Decides hit / almost / miss for a colour target.
RecognitionResult matchColor({
  required List<Signal> shares,
  required String targetColor,
  ColorThresholds thresholds = const ColorThresholds(),
}) {
  final match = shares.where((s) => s.name == targetColor).firstOrNull;
  final score = match?.score ?? 0;
  final verdict = score >= thresholds.hit
      ? Verdict.hit
      : score >= thresholds.almost
          ? Verdict.almost
          : Verdict.miss;
  return RecognitionResult(verdict: verdict, signals: shares, matched: match);
}
