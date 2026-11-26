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
///
/// All phrases go into the engine's queue at once, each with its language,
/// so "widelec" is followed by "fork" with no gap. Waiting for each phrase
/// to finish before sending the next (the old way) cost 2–3 seconds per
/// language switch.
class TtsNarrator implements Narrator {
  TtsNarrator() {
    _tts.awaitSpeakCompletion(false);
    _tts.setQueueMode(1); // QUEUE_ADD on Android.
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.1);
  }

  final _tts = FlutterTts();
  final _available = <String, bool>{};
  int _generation = 0;

  Future<bool> _isAvailable(String code) async {
    final locale = languageOf(code).ttsLocale;
    return _available[locale] ??=
        (await _tts.isLanguageAvailable(locale)) == true;
  }

  /// Looks up the voices ahead of time so the first phrase starts quickly.
  Future<void> warmUp(Iterable<String> langs) async {
    for (final l in langs) {
      await _isAvailable(l);
    }
  }

  @override
  Future<void> say(List<Phrase> phrases) async {
    final generation = ++_generation;
    await _tts.stop();
    for (final p in phrases) {
      if (generation != _generation) return;
      if (!await _isAvailable(p.lang)) continue;
      // The engine keeps each queued phrase's language, so set it, queue the
      // phrase, and move on without waiting for it to be spoken.
      await _tts.setLanguage(languageOf(p.lang).ttsLocale);
      await _tts.speak(p.text);
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
  final settings = ref.watch(appStoreProvider.select((d) => d.settings));
  if (!settings.narrator) return const SilentNarrator();
  final narrator = ref.watch(_ttsProvider);
  if (narrator is TtsNarrator) {
    narrator.warmUp([settings.nativeLang, settings.learnLang]);
  }
  return narrator;
});
