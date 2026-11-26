import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/content/models.dart';
import 'package:foxaboo/l10n/languages.dart';
import 'package:foxaboo/recognition/color_classifier.dart';
import 'package:foxaboo/recognition/detector_classes.dart';

import 'ml_kit_labels.dart';

void main() {
  late ContentPack pack;

  setUpAll(() {
    final raw = File('assets/content/base/pack.json').readAsStringSync();
    pack = ContentPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  test('base pack has 46 items in known rooms', () {
    expect(pack.items, hasLength(46));
    final rooms = {for (final r in pack.rooms) r.id};
    for (final item in pack.items) {
      expect(rooms, contains(item.room), reason: item.id);
    }
  });

  test('item ids are unique', () {
    final ids = pack.items.map((i) => i.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('every item can be recognised by at least one model', () {
    for (final item in pack.items) {
      expect([...item.labels, ...item.detect], isNotEmpty, reason: item.id);
      for (final label in item.labels) {
        expect(mlKitLabels, contains(label), reason: '${item.id}: $label');
      }
      for (final c in item.detect) {
        expect(detectorClasses, contains(c), reason: '${item.id}: $c');
      }
    }
  });

  test('every item has an illustration', () {
    for (final item in pack.items) {
      expect(
        File('assets/illustrations/${item.id}.svg').existsSync(),
        isTrue,
        reason: item.id,
      );
    }
  });

  test('every colour is one the classifier knows', () {
    for (final c in pack.colors) {
      expect(huntColors, contains(c.id));
    }
  });

  test('rooms, colours and items have words in every app language', () {
    final all = <String, Words>{
      for (final r in pack.rooms) 'room ${r.id}': r.words,
      for (final c in pack.colors) 'colour ${c.id}': c.words,
      for (final i in pack.items) 'item ${i.id}': i.words,
    };
    for (final MapEntry(:key, :value) in all.entries) {
      for (final lang in languages) {
        expect(value[lang.code], isNotEmpty, reason: '$key/${lang.code}');
      }
    }
  });
}
