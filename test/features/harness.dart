import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/app/app.dart';
import 'package:foxaboo/content/content_repository.dart';
import 'package:foxaboo/content/models.dart';
import 'package:foxaboo/data/app_data.dart';
import 'package:foxaboo/data/app_store.dart';
import 'package:foxaboo/narrator/narrator.dart';
import 'package:foxaboo/purchase/purchase_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePurchase extends PurchaseService {
  @override
  PurchaseState build() => const PurchaseState();
}

class RecordingNarrator implements Narrator {
  final said = <String>[];
  @override
  Future<void> say(List<Phrase> phrases) async =>
      said.addAll(phrases.map((p) => p.text));
  @override
  Future<void> stop() async {}
}

ContentPack loadPack() => ContentPack.fromJson(
      jsonDecode(File('assets/content/base/pack.json').readAsStringSync())
          as Map<String, dynamic>,
    );

const zosia = AppData(
  profiles: [Profile(id: 'z', name: 'Zosia', age: 6)],
  activeProfileId: 'z',
  settings: GameSettings(nativeLang: 'pl', learnLang: 'en'),
);

/// Pumps the whole app on a phone-sized screen with [data] already saved.
Future<RecordingNarrator> pumpApp(WidgetTester tester, {AppData? data}) async {
  tester.view
    ..physicalSize = const Size(1080, 2340)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    if (data != null) 'foxaboo.data.v1': jsonEncode(data.toJson()),
  });
  final prefs = await SharedPreferences.getInstance();
  final narrator = RecordingNarrator();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      contentPackProvider.overrideWithValue(loadPack()),
      narratorProvider.overrideWithValue(narrator),
      purchaseProvider.overrideWith(FakePurchase.new),
    ],
    child: const FoxabooApp(),
  ));
  await tester.pumpAndSettle();
  return narrator;
}
