/// Content of a pack: rooms, colours and items to hunt.
///
/// Words are keyed by language code (`pl`, `en`, ...). Adding a language is a
/// matter of adding a key to the pack file and the matching audio, not code.
library;

typedef Words = Map<String, String>;

Words _words(Object? json) =>
    Map<String, String>.from(json as Map<String, dynamic>);

class Room {
  const Room({required this.id, required this.words});

  factory Room.fromJson(Map<String, dynamic> json) =>
      Room(id: json['id'] as String, words: _words(json['words']));

  final String id;
  final Words words;
}

class HuntColor {
  const HuntColor({required this.id, required this.words});

  factory HuntColor.fromJson(Map<String, dynamic> json) =>
      HuntColor(id: json['id'] as String, words: _words(json['words']));

  /// One of the ids understood by `ColorClassifier` (red, orange, ...).
  final String id;
  final Words words;
}

class Item {
  const Item({
    required this.id,
    required this.room,
    required this.words,
    required this.labels,
    this.detect = const [],
    this.difficulty = 1,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as String,
    room: json['room'] as String,
    words: _words(json['words']),
    labels: List<String>.from(json['labels'] as List<dynamic>? ?? const []),
    detect: List<String>.from(json['detect'] as List<dynamic>? ?? const []),
    difficulty: (json['difficulty'] as int?) ?? 1,
  );

  final String id;
  final String room;
  final Words words;

  /// ML Kit image labels that count as finding this item.
  final List<String> labels;

  /// Object detector (COCO) classes that count as finding this item.
  final List<String> detect;

  /// 1 = easy, 3 = hard. Easy items come first for new players.
  final int difficulty;
}

class ContentPack {
  const ContentPack({
    required this.id,
    required this.rooms,
    required this.colors,
    required this.items,
  });

  factory ContentPack.fromJson(Map<String, dynamic> json) => ContentPack(
    id: json['id'] as String,
    rooms: [
      for (final r in json['rooms'] as List<dynamic>)
        Room.fromJson(r as Map<String, dynamic>),
    ],
    colors: [
      for (final c in json['colors'] as List<dynamic>)
        HuntColor.fromJson(c as Map<String, dynamic>),
    ],
    items: [
      for (final i in json['items'] as List<dynamic>)
        Item.fromJson(i as Map<String, dynamic>),
    ],
  );

  final String id;
  final List<Room> rooms;
  final List<HuntColor> colors;
  final List<Item> items;

  List<Item> itemsIn(String roomId) =>
      items.where((i) => i.room == roomId).toList();
}

/// What the child is asked to find: an item or a colour.
sealed class Target {
  const Target();
  String get id;
  Words get words;
}

class ItemTarget extends Target {
  const ItemTarget(this.item);
  final Item item;
  @override
  String get id => item.id;
  @override
  Words get words => item.words;
}

class ColorTarget extends Target {
  const ColorTarget(this.color);
  final HuntColor color;
  @override
  String get id => color.id;
  @override
  Words get words => color.words;
}

extension PackIds on ContentPack {
  /// Ids of every target in the pack, to ignore finds of items that a newer
  /// pack no longer has.
  Set<String> get targetIds => {
    for (final c in colors) c.id,
    for (final i in items) i.id,
  };
}
