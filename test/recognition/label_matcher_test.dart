import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/recognition/label_matcher.dart';
import 'package:foxaboo/recognition/recognition_result.dart';

void main() {
  const cup = ['Cup', 'Coffee', 'Cappuccino'];

  test('confident matching label in top 5 is a hit', () {
    final r = matchLabels(
      labels: const [Signal('Tableware', 0.9), Signal('Cup', 0.82)],
      acceptedLabels: cup,
    );
    expect(r.verdict, Verdict.hit);
    expect(r.matched?.name, 'Cup');
  });

  test('matching is case-insensitive and sorts by confidence', () {
    final r = matchLabels(
      labels: const [Signal('coffee', 0.7), Signal('Desk', 0.95)],
      acceptedLabels: cup,
    );
    expect(r.verdict, Verdict.hit);
    expect(r.signals.first.name, 'Desk');
  });

  test('weak matching label is almost', () {
    final r = matchLabels(
      labels: const [Signal('Desk', 0.9), Signal('Cup', 0.4)],
      acceptedLabels: cup,
    );
    expect(r.verdict, Verdict.almost);
  });

  test('confident match outside top K is only almost', () {
    final r = matchLabels(
      labels: const [
        Signal('A', 0.99),
        Signal('B', 0.98),
        Signal('C', 0.97),
        Signal('Cup', 0.7),
      ],
      acceptedLabels: cup,
      thresholds: const LabelThresholds(topK: 3),
    );
    expect(r.verdict, Verdict.almost);
  });

  test('very weak or missing label is a miss', () {
    expect(
      matchLabels(
        labels: const [Signal('Cup', 0.2)],
        acceptedLabels: cup,
      ).verdict,
      Verdict.miss,
    );
    expect(
      matchLabels(
        labels: const [Signal('Dog', 0.9)],
        acceptedLabels: cup,
      ).verdict,
      Verdict.miss,
    );
    expect(
      matchLabels(labels: const [], acceptedLabels: cup).verdict,
      Verdict.miss,
    );
  });
}
