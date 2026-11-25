/// Languages the app can show and speak. Any two can be paired: the child's
/// own language (UI and instructions) and the language being learned.
class Language {
  const Language(this.code, this.name, this.ttsLocale);

  /// Key used in content packs and strings (`pl`, `en`, ...).
  final String code;

  /// The language's own name, so nobody needs a translation to find theirs.
  final String name;

  /// Locale asked of the phone's text-to-speech engine.
  final String ttsLocale;
}

const languages = [
  Language('pl', 'Polski', 'pl-PL'),
  Language('en', 'English', 'en-US'),
  Language('de', 'Deutsch', 'de-DE'),
  Language('es', 'Español', 'es-ES'),
  Language('fr', 'Français', 'fr-FR'),
];

Language languageOf(String code) =>
    languages.firstWhere((l) => l.code == code, orElse: () => languages[1]);

/// Picks the child's language from the phone's locale, English otherwise.
String defaultNativeLanguage(String deviceLanguageCode) =>
    languages.any((l) => l.code == deviceLanguageCode)
        ? deviceLanguageCode
        : 'en';

/// English for most people; Polish for English speakers is not a sensible
/// default, so they get Spanish.
String defaultLearnLanguage(String native) => native == 'en' ? 'es' : 'en';
