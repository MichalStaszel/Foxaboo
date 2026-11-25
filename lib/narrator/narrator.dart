import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/app_store.dart';
import '../l10n/languages.dart';

/// One phrase in one language.
typedef Phrase = ({String text, String lang});

/// Speaks instructions and words. Screens only see this interface, so the
/// phone's text-to-speech can later be swapped for recorded audio.
abstract class Narrator {
  /// Stops whatever is playing, then says the phrases in order.
  Future<void> say(List<Phrase> phrases);
  Future<void> stop();
}

/// Uses the phone's own text-to-speech engine, which works offline once the
/// voice is installed. Languages without a voice are skipped silently.
class TtsNarrator implements Narrator {
  TtsNarrator() {
    _tts.awaitSpeakCompletion(true);
    _tts.setSpeechRate(0.42);
    _tts.setPitch(1.1);
  }

  final _tts = FlutterTts();
  final _available = <String, bool>{};
  int _generation = 0;

  Future<bool> _setLanguage(String code) async {
    final locale = languageOf(code).ttsLocale;
    final ok = _available[locale] ??=
        (await _tts.isLanguageAvailable(locale)) == true;
    if (ok) await _tts.setLanguage(locale);
    return ok;
  }

  @override
  Future<void> say(List<Phrase> phrases) async {
    final generation = ++_generation;
    await _tts.stop();
    for (final p in phrases) {
      if (generation != _generation) return;
      if (await _setLanguage(p.lang)) await _tts.speak(p.text);
    }
  }

  @override
  Future<void> stop() {
    _generation++;
    return _tts.stop();
  }
}

class SilentNarrator implements Narrator {
  const SilentNarrator();
  @override
  Future<void> say(List<Phrase> phrases) async {}
  @override
  Future<void> stop() async {}
}

final _ttsProvider = Provider<Narrator>((ref) {
  final narrator = TtsNarrator();
  ref.onDispose(narrator.stop);
  return narrator;
});

/// Silent when the parent turned the narrator off.
final narratorProvider = Provider<Narrator>((ref) {
  final on = ref.watch(appStoreProvider.select((d) => d.settings.narrator));
  return on ? ref.watch(_ttsProvider) : const SilentNarrator();
});
