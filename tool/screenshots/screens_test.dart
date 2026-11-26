// Renders every screen to PNG with the real fonts, for design review.
// Run: flutter test tool/screenshots --update-goldens
// Output: tool/screenshots/out/*.png (not checked in).
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/app/theme.dart';
import 'package:foxaboo/content/models.dart';
import 'package:foxaboo/data/app_data.dart';
import 'package:foxaboo/features/round/round_views.dart';
import 'package:foxaboo/game/round_engine.dart';
import 'package:foxaboo/l10n/strings.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/features/harness.dart';

Future<void> _font(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(
      Future.value(ByteData.sublistView(File(f).readAsBytesSync())),
    );
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _font('Baloo2', [
      'assets/fonts/Baloo2-SemiBold.ttf',
      'assets/fonts/Baloo2-Bold.ttf',
    ]);
    await _font('Nunito', [
      'assets/fonts/Nunito-SemiBold.ttf',
      'assets/fonts/Nunito-Bold.ttf',
      'assets/fonts/Nunito-ExtraBold.ttf',
    ]);
    final sdk =
        Platform.environment['FLUTTER_ROOT'] ?? '/home/user/sdk/flutter';
    await _font('MaterialIcons', [
      '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  });

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp).first,
      matchesGoldenFile('out/$name.png'),
    );
  }

  final pack = loadPack();
  final cup = ItemTarget(pack.items.firstWhere((i) => i.id == 'laptop'));
  final red = ColorTarget(pack.colors.first);
  const s = Strings('pl');

  final played = zosia.copyWith(
    progress: {
      'z': const Progress()
          .withFind('red', const Duration(seconds: 4), DateTime(2026, 11, 24))
          .withFind('cup', const Duration(seconds: 18), DateTime(2026, 11, 25))
          .withFind('blue', const Duration(seconds: 9), DateTime(2026, 11, 25))
          .withRound(
            RoundRecord(at: DateTime.now(), found: 3, total: 5, foundMs: 31000),
          ),
    },
  );

  testWidgets('setup', (t) async {
    await pumpApp(t);
    await shot(t, '00-setup');
  });

  testWidgets('home', (t) async {
    await pumpApp(t, data: played);
    await shot(t, '01-start');
  });

  testWidgets('album', (t) async {
    await pumpApp(t, data: played);
    await t.tap(find.text('Album'));
    await shot(t, '06-album');
  });

  testWidgets('gate and parent', (t) async {
    await pumpApp(t, data: played);
    await t.tap(find.byTooltip('Strefa rodzica'));
    await shot(t, '07-gate');
    const words = [
      'zero',
      'jeden',
      'dwa',
      'trzy',
      'cztery',
      'pięć',
      'sześć',
      'siedem',
      'osiem',
      'dziewięć',
    ];
    final text = t
        .widget<Text>(find.byKey(const Key('gate-instruction')))
        .data!;
    for (final w in text.split(':').last.split(',')) {
      await t.tap(find.text('${words.indexOf(w.trim())}'));
      await t.pump();
    }
    await shot(t, '08-parent');
    await t.drag(find.byType(ListView), const Offset(0, -700));
    await shot(t, '09-parent-bottom');
  });

  Future<void> view(WidgetTester t, String name, Widget child) async {
    t.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildTheme(),
          debugShowCheckedModeBanner: false,
          home: child,
        ),
      ),
    );
    await shot(t, name);
  }

  void nop() {}
  void nopS(String _) {}

  testWidgets(
    'task',
    (t) => view(
      t,
      '02-task',
      TaskView(
        target: cup,
        strings: s,
        nativeLang: 'pl',
        learnLang: 'en',
        index: 1,
        total: 5,
        seconds: 60,
        onClose: nop,
        onSpeak: nop,
        onStart: nop,
        onSwap: nop,
      ),
    ),
  );

  HuntView hunt(HuntSheet? sheet) => HuntView(
    camera: null,
    cameraError: null,
    target: cup,
    strings: s,
    nativeLang: 'pl',
    learnLang: 'en',
    fractionLeft: 0.62,
    checking: false,
    paused: false,
    sheet: sheet,
    onShoot: nop,
    onPause: nop,
    onResume: nop,
    onEnd: nop,
    onSpeak: nop,
    onTryAgain: nop,
    onParentOverride: nop,
  );

  testWidgets('hunt', (t) async {
    t.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: hunt(null),
      ),
    );
    await t.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('out/03-hunt.png'),
    );
  });

  testWidgets('almost', (t) async {
    t.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: hunt(HuntSheet.almost),
      ),
    );
    await t.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('out/04-almost.png'),
    );
  });

  testWidgets(
    'reward',
    (t) => view(
      t,
      '05-reward',
      RewardView(
        result: TaskResult(
          cup,
          TaskOutcome.found,
          const Duration(seconds: 18),
          isNew: true,
        ),
        strings: s,
        nativeLang: 'pl',
        learnLang: 'en',
        onSpeak: nopS,
        onNext: nop,
      ),
    ),
  );

  testWidgets(
    'time up',
    (t) => view(
      t,
      '05b-time-up',
      TimeUpView(
        target: red,
        strings: s,
        nativeLang: 'pl',
        learnLang: 'en',
        onSpeak: nopS,
        onNext: nop,
      ),
    ),
  );

  testWidgets(
    'summary',
    (t) => view(
      t,
      '05c-summary',
      SummaryView(
        results: [
          TaskResult(cup, TaskOutcome.found, const Duration(seconds: 9)),
          TaskResult(red, TaskOutcome.timedOut, const Duration(seconds: 60)),
          for (final i in pack.itemsIn('kitchen').skip(1).take(3))
            TaskResult(
              ItemTarget(i),
              TaskOutcome.found,
              const Duration(seconds: 12),
            ),
        ],
        strings: s,
        learnLang: 'en',
        onAgain: nop,
        onHome: nop,
      ),
    ),
  );
}
