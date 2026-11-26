import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/recognition/detector_classes.dart';
import 'package:foxaboo/recognition/object_detector.dart';
import 'package:foxaboo/recognition/recognition_result.dart';
import 'package:foxaboo/recognition/recognizer.dart';

void main() {
  final classes = detectorClasses.length;
  final couch = detectorClasses.indexOf('couch');
  final laptop = detectorClasses.indexOf('laptop');

  Float32List anchors(List<Map<int, double>> rows) {
    final out = Float32List(rows.length * classes);
    for (var a = 0; a < rows.length; a++) {
      rows[a].forEach((c, s) => out[a * classes + c] = s);
    }
    return out;
  }

  test('the model has the 90 COCO slots', () {
    expect(classes, 90);
    expect(detectorClasses.first, 'person');
    expect(detectorClasses.last, 'toothbrush');
  });

  test('keeps the best score of each class over all anchors', () {
    final scores = maxScorePerClass(
      anchors([
        {couch: 0.2, laptop: 0.7},
        {couch: 0.55},
        {couch: 0.01},
      ]),
    );
    expect(scores['couch'], closeTo(0.55, 1e-6));
    expect(scores['laptop'], closeTo(0.7, 1e-6));
    expect(scores.keys, unorderedEquals(['couch', 'laptop']));
  });

  test('detector thresholds: hit, almost, miss', () {
    Verdict v(double s) => matchDetections(
      scores: {'couch': s},
      acceptedClasses: ['couch'],
    ).verdict;
    expect(v(0.45), Verdict.hit);
    expect(v(0.30), Verdict.almost);
    expect(v(0.10), Verdict.miss);
    // A strong different object does not count.
    expect(
      matchDetections(
        scores: {'chair': 0.9},
        acceptedClasses: ['couch'],
      ).verdict,
      Verdict.miss,
    );
  });

  test('the better of two recognisers wins', () {
    const miss = RecognitionResult(
      verdict: Verdict.miss,
      signals: [Signal('Room', 0.9)],
    );
    const hit = RecognitionResult(
      verdict: Verdict.hit,
      signals: [Signal('couch', 0.6)],
      matched: Signal('couch', 0.6),
    );
    final combined = combineResults([miss, hit]);
    expect(combined.verdict, Verdict.hit);
    expect(combined.matched?.name, 'couch');
    expect(combined.signals.map((s) => s.name), ['Room', 'couch']);
    expect(combineResults([]).verdict, Verdict.miss);
  });
}
