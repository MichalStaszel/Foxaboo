import 'package:flutter_test/flutter_test.dart';
import 'package:foxaboo/l10n/languages.dart';
import 'package:foxaboo/l10n/strings.dart';

Set<String> _placeholders(String text) =>
    {for (final m in RegExp(r'\{(\w+)\}').allMatches(text)) m.group(1)!};

void main() {
  test('every app language has strings', () {
    expect(strings.keys.toSet(), {for (final l in languages) l.code});
  });

  for (final lang in languages) {
    test('${lang.code} has every key with the same placeholders as English',
        () {
      final en = strings['en']!;
      final other = strings[lang.code]!;
      expect(other.keys.toSet(), en.keys.toSet());
      for (final key in en.keys) {
        expect(other[key], isNotEmpty, reason: key);
        expect(_placeholders(other[key]!), _placeholders(en[key]!),
            reason: '${lang.code}/$key');
      }
      expect(Strings(lang.code).digits, hasLength(10));
    });
  }

  test('placeholders are filled in', () {
    expect(const Strings('pl').t('foundCount', {'n': 4, 'total': 5}),
        'Znalezione: 4 z 5');
  });

  test('default language pair', () {
    expect(defaultNativeLanguage('pl'), 'pl');
    expect(defaultNativeLanguage('ja'), 'en');
    expect(defaultLearnLanguage('pl'), 'en');
    expect(defaultLearnLanguage('en'), isNot('en'));
  });
}
