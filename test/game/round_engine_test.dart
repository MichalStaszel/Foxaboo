import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/content/models.dart';
import 'package:foxaboo/game/round_engine.dart';

void main() {
  late ContentPack pack;

  setUpAll(() {
    final raw = File('assets/content/base/pack.json').readAsStringSync();
    pack = ContentPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  int difficulty(Target t) => (t as ItemTarget).item.difficulty;

  group('pickTargets', () {
    test('picks five different targets from the chosen room', () {
      final picked = pickTargets(
        pack: pack,
        mode: 'kitchen',
        alreadyFound: const {},
        random: Random(1),
      );
      expect(picked, hasLength(5));
      expect(picked.map((t) => t.id).toSet(), hasLength(5));
      for (final t in picked) {
        expect((t as ItemTarget).item.room, 'kitchen');
      }
    });

    test('colour mode picks colours', () {
      final picked = pickTargets(
        pack: pack,
        mode: colorsMode,
        alreadyFound: const {},
        random: Random(2),
      );
      expect(picked, everyElement(isA<ColorTarget>()));
    });

    test('a round goes from easy to hard', () {
      for (var seed = 0; seed < 20; seed++) {
        final d = pickTargets(
          pack: pack,
          mode: 'kitchen',
          alreadyFound: const {},
          random: Random(seed),
        ).map(difficulty).toList();
        expect(d, orderedEquals([...d]..sort()));
      }
    });

    test('new players get easy targets first', () {
      final picked = pickTargets(
        pack: pack,
        mode: 'kitchen',
        alreadyFound: const {},
        random: Random(3),
      );
      // The kitchen has more than five easy items.
      expect(picked.map(difficulty), everyElement(1));
    });

    test('targets not found yet come before ones already found', () {
      final kitchen = pack.itemsIn('kitchen').map((i) => i.id).toList();
      final found = kitchen.take(kitchen.length - 5).toSet();
      final picked = pickTargets(
        pack: pack,
        mode: 'kitchen',
        alreadyFound: found,
        random: Random(4),
      );
      expect(picked.map((t) => t.id).toSet(), kitchen.skip(found.length).toSet());
    });

    test('a room with fewer than five targets gives all of them', () {
      final picked = pickTargets(
        pack: pack,
        mode: colorsMode,
        alreadyFound: const {},
        random: Random(5),
        count: 20,
      );
      expect(picked, hasLength(pack.colors.length));
    });
  });

  test('replacementTarget avoids targets already in the round', () {
    final exclude = pack.colors.take(7).map((c) => c.id).toSet();
    final next = replacementTarget(
      pack: pack,
      mode: colorsMode,
      exclude: exclude,
      random: Random(6),
    );
    expect(next?.id, pack.colors.last.id);
    expect(
      replacementTarget(
        pack: pack,
        mode: colorsMode,
        exclude: {for (final c in pack.colors) c.id},
        random: Random(6),
      ),
      isNull,
    );
  });

  group('HuntClock', () {
    test('only counts while running', () {
      final clock = HuntClock(const Duration(seconds: 30));
      clock.tick(const Duration(seconds: 5));
      expect(clock.elapsed, Duration.zero);
      clock
        ..running = true
        ..tick(const Duration(seconds: 10));
      expect(clock.remaining, const Duration(seconds: 20));
      expect(clock.fractionLeft, closeTo(2 / 3, 1e-9));
      clock
        ..running = false
        ..tick(const Duration(seconds: 10));
      expect(clock.remaining, const Duration(seconds: 20));
    });

    test('stops at the limit', () {
      final clock = HuntClock(const Duration(seconds: 30))..running = true;
      clock.tick(const Duration(seconds: 45));
      expect(clock.isOver, isTrue);
      expect(clock.elapsed, const Duration(seconds: 30));
      expect(clock.fractionLeft, 0);
    });
  });

  group('GateChallenge', () {
    test('uses three different digits', () {
      for (var seed = 0; seed < 50; seed++) {
        final c = GateChallenge.random(Random(seed));
        expect(c.digits, hasLength(3));
        expect(c.digits.toSet(), hasLength(3));
        expect(c.digits, everyElement(inInclusiveRange(0, 9)));
      }
    });

    test('accepts only the digits in order', () {
      final c = GateChallenge([4, 9, 2]);
      expect(c.accepts([4, 9, 2]), isTrue);
      expect(c.accepts([2, 9, 4]), isFalse);
      expect(c.accepts([4, 9]), isFalse);
    });
  });
}
