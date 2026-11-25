import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/data/app_data.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Reads the three digits from the gate's instruction and taps them.
Future<void> passGate(WidgetTester tester, List<String> digitWords) async {
  final text =
      tester.widget<Text>(find.byKey(const Key('gate-instruction'))).data!;
  final words = text.split(':').last.split(',').map((w) => w.trim());
  for (final w in words) {
    await tester.tap(find.text('${digitWords.indexOf(w)}'));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

const plDigits = [
  'zero', 'jeden', 'dwa', 'trzy', 'cztery',
  'pięć', 'sześć', 'siedem', 'osiem', 'dziewięć',
];

void main() {
  testWidgets('first launch asks for setup, then opens the start screen',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('Welcome to Foxaboo!'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Zosia');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Zosia'), findsOneWidget);
    expect(find.text("Let's hunt!"), findsOneWidget);
  });

  testWidgets('start screen in Polish shows modes and locks paid rooms',
      (tester) async {
    final narrator = await pumpApp(tester, data: zosia);
    expect(find.text('Na co polujemy?'), findsOneWidget);
    expect(find.text('Kolory'), findsOneWidget);
    expect(find.text('Kuchnia'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);

    await tester.tap(find.text('Salon'));
    await tester.pump();
    expect(narrator.said, containsAllInOrder(['Salon', 'Living room']));
    expect(narrator.said.last, 'Ten pokój odblokuje rodzic');
  });

  testWidgets('parent gate lets an adult into the parent zone',
      (tester) async {
    await pumpApp(tester, data: zosia);
    await tester.tap(find.byTooltip('Strefa rodzica'));
    await tester.pumpAndSettle();
    expect(find.text('Tylko dla rodzica'), findsOneWidget);

    await passGate(tester, plDigits);
    expect(find.text('Strefa rodzica'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('Wszystkie pokoje i kolory'), 300);
    expect(find.text('Wszystkie pokoje i kolory'), findsOneWidget);
  });

  testWidgets('a wrong code keeps the gate closed', (tester) async {
    await pumpApp(tester, data: zosia);
    await tester.tap(find.byTooltip('Strefa rodzica'));
    await tester.pumpAndSettle();

    final text =
        tester.widget<Text>(find.byKey(const Key('gate-instruction'))).data!;
    final first = plDigits.indexOf(text.split(':').last.split(',').first.trim());
    final wrong = (first + 1) % 10;
    for (final d in [wrong, wrong, wrong]) {
      await tester.tap(find.text('$d').last);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Tylko dla rodzica'), findsOneWidget);
    expect(find.text('Spróbuj jeszcze raz'), findsOneWidget);
  });

  testWidgets('album shows found stickers and placeholders', (tester) async {
    final data = zosia.copyWith(progress: {
      'z': const Progress()
          .withFind('red', const Duration(seconds: 4), DateTime(2026)),
    });
    final narrator = await pumpApp(tester, data: data);
    await tester.tap(find.text('Album'));
    await tester.pumpAndSettle();

    expect(find.text('Album: Zosia'), findsOneWidget);
    expect(find.text('czerwony'), findsOneWidget);
    expect(find.text('?'), findsNWidgets(7));

    await tester.tap(find.text('czerwony'));
    await tester.pump();
    expect(narrator.said, ['czerwony', 'red']);
  });

  testWidgets('parent zone changes the language pair', (tester) async {
    await pumpApp(tester, data: zosia);
    await tester.tap(find.byTooltip('Strefa rodzica'));
    await tester.pumpAndSettle();
    await passGate(tester, plDigits);

    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch').last);
    await tester.pumpAndSettle();
    expect(find.text('Deutsch'), findsOneWidget);
  });
}
