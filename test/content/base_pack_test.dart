import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/content/models.dart';
import 'package:foxaboo/recognition/color_classifier.dart';

/// Labels of the ML Kit base image-labeling model that the pack may use.
/// Source: developers.google.com/ml-kit/vision/image-labeling/label-map
/// (only the ones relevant to homes; extend when adding items).
const mlKitLabels = {
  'Aquarium', 'Bag', 'Balloon', 'Beanie', 'Bicycle', 'Blazer', 'Bread',
  'Cabinetry', 'Cake', 'Cap', 'Cappuccino', 'Car', 'Cat', 'Chair', 'Clock',
  'Coffee', 'Computer', 'Cookie', 'Cookware and bakeware', 'Couch', 'Cup',
  'Curtain', 'Cushion', 'Cutlery', 'Denim', 'Desk', 'Dog', 'Drawer', 'Flora',
  'Flower', 'Flowerpot', 'Fruit', 'Glasses', 'Goggles', 'Handbag', 'Handrail',
  'Hat', 'Helmet', 'Icing', 'Jacket', 'Jeans', 'Jewellery', 'Juice',
  'Lampshade', 'Lego', 'Loveseat', 'Miniature', 'Mobile phone', 'Money',
  'Musical instrument', 'Necklace', 'News', 'Newspaper', 'Outerwear', 'Paper',
  'Petal', 'Piano', 'Pie', 'Pillow', 'Plant', 'Plush', 'Porcelain', 'Poster',
  'Saucer', 'Scarf', 'Shoe', 'Sink', 'Skateboard', 'Sneakers', 'Stairs',
  'Stuffed toy', 'Sunglasses', 'Tableware', 'Television', 'Toy', 'Umbrella',
  'Vegetable', 'Vehicle', 'Wheel',
};

void main() {
  late ContentPack pack;

  setUpAll(() {
    final raw = File('assets/content/base/pack.json').readAsStringSync();
    pack = ContentPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  test('base pack has 50 items in known rooms', () {
    expect(pack.items, hasLength(50));
    final rooms = {for (final r in pack.rooms) r.id};
    for (final item in pack.items) {
      expect(rooms, contains(item.room), reason: item.id);
    }
  });

  test('item ids are unique', () {
    final ids = pack.items.map((i) => i.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('every item has Polish and English words and model labels', () {
    for (final item in pack.items) {
      expect(item.words['pl'], isNotEmpty, reason: item.id);
      expect(item.words['en'], isNotEmpty, reason: item.id);
      expect(item.labels, isNotEmpty, reason: item.id);
      for (final label in item.labels) {
        expect(mlKitLabels, contains(label), reason: '${item.id}: $label');
      }
    }
  });

  test('every colour is one the classifier knows', () {
    for (final c in pack.colors) {
      expect(huntColors, contains(c.id));
    }
  });
}
