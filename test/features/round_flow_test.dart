import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

void main() {
  testWidgets('a round: task card, hunt, time up, next task, end', (
    tester,
  ) async {
    final narrator = await pumpApp(tester, data: zosia);
    await tester.tap(find.text('Polujemy!'));
    await tester.pumpAndSettle();

    // Task card for a colour, spoken in Polish then English.
    expect(find.text('ZNAJDŹ'), findsOneWidget);
    expect(narrator.said.first, startsWith('Znajdź: '));

    await tester.tap(find.text('Szukam!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Wyceluj w ramkę i pstryk!'), findsOneWidget);

    // Pause stops the clock.
    await tester.tap(find.byTooltip('Pauza'));
    await tester.pump();
    expect(find.text('Graj dalej'), findsOneWidget);
    await tester.pump(const Duration(seconds: 90));
    expect(find.text('Czas minął!'), findsNothing);
    await tester.tap(find.text('Graj dalej'));
    await tester.pump();

    // 60 s per item by default.
    for (var i = 0; i < 62; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();
    expect(find.text('Czas minął!'), findsOneWidget);
    expect(narrator.said.any((t) => t.startsWith('Czas minął')), isTrue);

    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();
    expect(find.text('ZNAJDŹ'), findsOneWidget);

    await tester.tap(find.byTooltip('Zamknij'));
    await tester.pumpAndSettle();
    expect(find.text('Na co polujemy?'), findsOneWidget);
  });

  testWidgets('"pick something else" swaps the target', (tester) async {
    await pumpApp(tester, data: zosia);
    await tester.tap(find.text('Polujemy!'));
    await tester.pumpAndSettle();

    String word() =>
        tester.widget<Text>(find.byKey(const Key('task-word'))).data!;
    final before = word();
    await tester.tap(find.text('Wylosuj coś innego'));
    await tester.pumpAndSettle();
    expect(word(), isNot(before));
  });
}
