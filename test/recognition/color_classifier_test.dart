import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/recognition/color_classifier.dart';
import 'package:foxaboo/recognition/recognition_result.dart';

int rgb(int r, int g, int b) => (r << 16) | (g << 8) | b;

void main() {
  group('classifyPixel', () {
    final cases = <String, List<int>>{
      'red': [220, 30, 40],
      'orange': [240, 140, 30],
      'yellow': [250, 210, 40],
      'green': [40, 160, 70],
      'blue': [30, 110, 220],
      'purple': [130, 50, 200],
      'pink': [240, 120, 190],
      'brown': [120, 70, 30],
      'white': [245, 245, 240],
      'gray': [128, 128, 130],
      'black': [15, 15, 20],
    };
    cases.forEach((name, c) {
      test(name, () => expect(classifyPixel(c[0], c[1], c[2]), name));
    });

    test('washed-out light red reads as pink', () {
      expect(classifyPixel(250, 170, 170), 'pink');
    });
  });

  test('colorShares returns shares strongest first', () {
    final pixels = [
      ...List.filled(6, rgb(30, 110, 220)),
      ...List.filled(4, rgb(220, 30, 40)),
    ];
    final shares = colorShares(pixels);
    expect(shares.first.name, 'blue');
    expect(shares.first.score, closeTo(0.6, 1e-9));
    expect(shares[1].name, 'red');
  });

  test('colorShares of nothing is empty', () {
    expect(colorShares(const []), isEmpty);
  });

  group('matchColor', () {
    const shares = [
      Signal('blue', 0.5),
      Signal('red', 0.2),
      Signal('white', 0.3),
    ];

    test('large share is a hit', () {
      expect(
        matchColor(shares: shares, targetColor: 'blue').verdict,
        Verdict.hit,
      );
    });

    test('small share is almost', () {
      expect(
        matchColor(shares: shares, targetColor: 'red').verdict,
        Verdict.almost,
      );
    });

    test('absent colour is a miss', () {
      final r = matchColor(shares: shares, targetColor: 'green');
      expect(r.verdict, Verdict.miss);
      expect(r.matched, isNull);
    });
  });
}
