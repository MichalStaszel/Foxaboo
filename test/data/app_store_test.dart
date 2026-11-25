import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/data/app_data.dart';
import 'package:foxaboo/data/app_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  var now = DateTime(2026, 11, 25, 10);

  Future<ProviderContainer> container() async {
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      clockProvider.overrideWithValue(() => now),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 11, 25, 10);
  });

  test('starts empty, then setup creates a child and languages', () async {
    final c = await container();
    expect(c.read(appStoreProvider).isSetUp, isFalse);
    c.read(appStoreProvider.notifier).completeSetup(
          name: 'Zosia',
          age: 6,
          nativeLang: 'pl',
          learnLang: 'en',
        );
    final data = c.read(appStoreProvider);
    expect(data.isSetUp, isTrue);
    expect(data.activeProfile?.name, 'Zosia');
    expect(data.settings.nativeLang, 'pl');
    expect(data.settings.learnLang, 'en');
  });

  test('finds and rounds are saved and survive a restart', () async {
    final c = await container();
    final store = c.read(appStoreProvider.notifier)
      ..completeSetup(name: 'Zosia', nativeLang: 'pl', learnLang: 'en');
    expect(store.recordFind('cup', const Duration(seconds: 18)), isTrue);
    now = now.add(const Duration(minutes: 1));
    expect(store.recordFind('cup', const Duration(seconds: 9)), isFalse);
    store.recordRound(found: 2, total: 5, foundTime: const Duration(seconds: 27));

    final again = await container();
    final progress = again.read(appStoreProvider).activeProgress;
    expect(progress.finds['cup']!.count, 2);
    expect(progress.finds['cup']!.bestMs, 9000);
    expect(progress.rounds, hasLength(1));
    expect(progress.averageSeconds, 13.5);
    expect(progress.roundsSince(now.subtract(const Duration(days: 7))), 1);
  });

  test('each child has their own progress; at most three children', () async {
    final c = await container();
    final store = c.read(appStoreProvider.notifier)
      ..completeSetup(name: 'Zosia', nativeLang: 'pl', learnLang: 'en');
    store.recordFind('cup', const Duration(seconds: 5));
    now = now.add(const Duration(seconds: 1));
    store.addProfile('Antek', 4);
    expect(c.read(appStoreProvider).activeProfile?.name, 'Antek');
    expect(c.read(appStoreProvider).activeProgress.finds, isEmpty);
    now = now.add(const Duration(seconds: 1));
    store.addProfile('Ola', 8);
    now = now.add(const Duration(seconds: 1));
    store.addProfile('Too many', 5);
    expect(c.read(appStoreProvider).profiles, hasLength(3));

    final zosia = c.read(appStoreProvider).profiles.first;
    store.selectProfile(zosia.id);
    expect(c.read(appStoreProvider).activeProgress.finds.keys, ['cup']);
  });

  test('free play covers colours and the kitchen only', () {
    const free = AppData();
    expect(free.isModeUnlocked('colors'), isTrue);
    expect(free.isModeUnlocked('kitchen'), isTrue);
    expect(free.isModeUnlocked('living'), isFalse);
    expect(const AppData(fullUnlock: true).isModeUnlocked('living'), isTrue);
  });

  test('round history is capped', () {
    var p = const Progress();
    for (var i = 0; i < Progress.maxRounds + 10; i++) {
      p = p.withRound(RoundRecord(
        at: DateTime(2026, 1, 1).add(Duration(hours: i)),
        found: 1,
        total: 5,
        foundMs: 1000,
      ));
    }
    expect(p.rounds, hasLength(Progress.maxRounds));
  });

  test('JSON round trip', () {
    final data = AppData(
      profiles: const [Profile(id: 'a', name: 'Zosia', age: 6)],
      activeProfileId: 'a',
      settings: const GameSettings(
          roundSeconds: 45, nativeLang: 'de', learnLang: 'fr', narrator: false),
      progress: {
        'a': const Progress()
            .withFind('red', const Duration(seconds: 3), DateTime(2026)),
      },
      fullUnlock: true,
    );
    final back = AppData.fromJson(
        jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>);
    expect(back.toJson(), data.toJson());
  });
}
